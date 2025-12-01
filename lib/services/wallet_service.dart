import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../services/local_cache_service.dart';

/// Service pour gérer le portefeuille (calcul du solde)
class WalletService {
  final TransactionRepository _transactionRepository;

  WalletService(this._transactionRepository);

  /// Calculer le solde réel basé sur les transactions
  /// Solde = dépôts - achats + gains des ventes - retraits
  Future<double> calculateBalance() async {
    try {
      final transactions = await _transactionRepository.getTransactions();
      
      double balance = 0.0;

      for (final transaction in transactions) {
        // On utilise amountInXOF qui retourne la valeur correcte selon le type
        balance += transaction.amountInXOF;
      }

      // Sauvegarder le dernier solde calculé pour mode hors ligne
      await LocalCacheService.saveLastBalance(balance);

      return balance;
    } catch (e) {
      // En cas d'erreur, retourner le dernier solde connu
      return await LocalCacheService.getLastBalance();
    }
  }

  /// Récupérer le dernier solde connu (mode hors ligne)
  Future<double> getLastKnownBalance() async {
    return await LocalCacheService.getLastBalance();
  }

  /// Calculer le solde depuis le cache uniquement (rapide)
  Future<double> calculateBalanceFromCache() async {
    try {
      final transactions = await LocalCacheService.getTransactions();
      
      double balance = 0.0;

      for (final transaction in transactions) {
        balance += transaction.amountInXOF;
      }

      return balance;
    } catch (e) {
      return 0.0;
    }
  }

  /// Valider un montant avant transaction
  Future<ValidationResult> validateAmount({
    required double amount,
    required TransactionType type,
  }) async {
    if (amount <= 0) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Le montant doit être supérieur à 0',
      );
    }

    // Pour les achats, retraits et ventes, vérifier le solde disponible
    if (type == TransactionType.BUY || type == TransactionType.WITHDRAWAL) {
      final balance = await calculateBalance();
      
      if (type == TransactionType.WITHDRAWAL && amount > balance) {
        return ValidationResult(
          isValid: false,
          errorMessage: 'Solde insuffisant. Solde disponible: ${balance.toStringAsFixed(0)} XOF',
        );
      }

      if (type == TransactionType.BUY) {
        // Pour les achats, amount est en XOF
        if (amount > balance) {
          return ValidationResult(
            isValid: false,
            errorMessage: 'Solde insuffisant. Solde disponible: ${balance.toStringAsFixed(0)} XOF',
          );
        }
      }
    }

    // Montants minimaux
    const minDeposit = 500.0; // 500 XOF minimum
    const minWithdrawal = 1000.0; // 1000 XOF minimum
    const minBuy = 2500.0; // 2500 XOF minimum pour achat

    if (type == TransactionType.DEPOSIT && amount < minDeposit) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Le montant minimum de dépôt est $minDeposit XOF',
      );
    }

    if (type == TransactionType.WITHDRAWAL && amount < minWithdrawal) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Le montant minimum de retrait est $minWithdrawal XOF',
      );
    }

    if (type == TransactionType.BUY && amount < minBuy) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Le montant minimum d\'achat est $minBuy XOF',
      );
    }

    return ValidationResult(isValid: true);
  }

  /// Obtenir le résumé du portefeuille
  Future<WalletSummary> getWalletSummary() async {
    final transactions = await _transactionRepository.getTransactions();
    final balance = await calculateBalance();

    double totalDeposits = 0;
    double totalWithdrawals = 0;
    double totalSpent = 0; // Achats
    double totalEarned = 0; // Ventes

    for (final transaction in transactions) {
      switch (transaction.type) {
        case TransactionType.DEPOSIT:
          totalDeposits += transaction.amount;
          break;
        case TransactionType.WITHDRAWAL:
          totalWithdrawals += transaction.amount;
          break;
        case TransactionType.BUY:
          totalSpent += transaction.amountXOF ?? 0;
          break;
        case TransactionType.SELL:
          totalEarned += transaction.amountXOF ?? 0;
          break;
      }
    }

    return WalletSummary(
      balance: balance,
      totalDeposits: totalDeposits,
      totalWithdrawals: totalWithdrawals,
      totalSpent: totalSpent,
      totalEarned: totalEarned,
      transactionCount: transactions.length,
    );
  }
}

/// Résultat de validation
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}

/// Résumé du portefeuille
class WalletSummary {
  final double balance;
  final double totalDeposits;
  final double totalWithdrawals;
  final double totalSpent;
  final double totalEarned;
  final int transactionCount;

  WalletSummary({
    required this.balance,
    required this.totalDeposits,
    required this.totalWithdrawals,
    required this.totalSpent,
    required this.totalEarned,
    required this.transactionCount,
  });
}

