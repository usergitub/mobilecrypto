// ignore_for_file: constant_identifier_names

enum TransactionType {
  DEPOSIT, // Dépôt Mobile Money
  WITHDRAWAL, // Retrait Mobile Money
  BUY, // Achat crypto
  SELL, // Vente crypto
}

enum TransactionStatus {
  PENDING, // En attente
  COMPLETED, // Terminé
  FAILED, // Échoué
}

class Transaction {
  final String id;
  final TransactionType type;
  final double amount; // Montant en XOF (pour dépôt/retrait) ou quantité crypto
  final String? cryptoId;
  final String? cryptoSymbol;
  final double? cryptoPrice;
  final double? amountXOF; // Montant en XOF (pour BUY/SELL)
  final String paymentMethod; // WAVE, MTN, Orange, Moov
  final DateTime timestamp;
  final TransactionStatus status;
  final String? transactionId; // ID de transaction Mobile Money
  final bool syncedWithCloud; // Si synchronisé avec Supabase
  final String? errorMessage;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    this.cryptoId,
    this.cryptoSymbol,
    this.cryptoPrice,
    this.amountXOF,
    required this.paymentMethod,
    required this.timestamp,
    required this.status,
    this.transactionId,
    this.syncedWithCloud = false,
    this.errorMessage,
  });

  // Créer une transaction de dépôt
  factory Transaction.deposit({
    required String id,
    required double amountXOF,
    required String paymentMethod,
    String? transactionId,
  }) {
    return Transaction(
      id: id,
      type: TransactionType.DEPOSIT,
      amount: amountXOF,
      amountXOF: amountXOF,
      paymentMethod: paymentMethod,
      timestamp: DateTime.now(),
      status: TransactionStatus.COMPLETED,
      transactionId: transactionId,
    );
  }

  // Créer une transaction de retrait
  factory Transaction.withdrawal({
    required String id,
    required double amountXOF,
    required String paymentMethod,
    String? transactionId,
  }) {
    return Transaction(
      id: id,
      type: TransactionType.WITHDRAWAL,
      amount: amountXOF,
      amountXOF: amountXOF,
      paymentMethod: paymentMethod,
      timestamp: DateTime.now(),
      status: TransactionStatus.PENDING,
      transactionId: transactionId,
    );
  }

  // Créer une transaction d'achat
  factory Transaction.buy({
    required String id,
    required double amountXOF,
    required String cryptoId,
    required String cryptoSymbol,
    required double cryptoPrice,
    required double cryptoAmount,
    required String paymentMethod,
  }) {
    return Transaction(
      id: id,
      type: TransactionType.BUY,
      amount: cryptoAmount,
      cryptoId: cryptoId,
      cryptoSymbol: cryptoSymbol,
      cryptoPrice: cryptoPrice,
      amountXOF: amountXOF,
      paymentMethod: paymentMethod,
      timestamp: DateTime.now(),
      status: TransactionStatus.COMPLETED,
    );
  }

  // Créer une transaction de vente
  factory Transaction.sell({
    required String id,
    required double cryptoAmount,
    required double amountXOF,
    required String cryptoId,
    required String cryptoSymbol,
    required double cryptoPrice,
    required String paymentMethod,
    String? transactionId,
  }) {
    return Transaction(
      id: id,
      type: TransactionType.SELL,
      amount: cryptoAmount,
      cryptoId: cryptoId,
      cryptoSymbol: cryptoSymbol,
      cryptoPrice: cryptoPrice,
      amountXOF: amountXOF,
      paymentMethod: paymentMethod,
      timestamp: DateTime.now(),
      status: TransactionStatus.PENDING,
      transactionId: transactionId,
    );
  }

  // Convertir en Map pour Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'crypto_id': cryptoId,
      'crypto_symbol': cryptoSymbol,
      'crypto_price': cryptoPrice,
      'amount_xof': amountXOF,
      'payment_method': paymentMethod,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'transaction_id': transactionId,
      'error_message': errorMessage,
      'synced_with_cloud': syncedWithCloud,
    };
  }

  // Créer depuis un Map (Supabase ou cache)
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.DEPOSIT,
      ),
      amount: (json['amount'] as num).toDouble(),
      cryptoId: json['crypto_id'] as String?,
      cryptoSymbol: json['crypto_symbol'] as String?,
      cryptoPrice: json['crypto_price'] != null
          ? (json['crypto_price'] as num).toDouble()
          : null,
      amountXOF: json['amount_xof'] != null
          ? (json['amount_xof'] as num).toDouble()
          : null,
      paymentMethod: json['payment_method'] as String,
      timestamp: DateTime.parse(json['timestamp']),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.PENDING,
      ),
      transactionId: json['transaction_id'] as String?,
      syncedWithCloud: json['synced_with_cloud'] ?? true,
      errorMessage: json['error_message'] as String?,
    );
  }

  // Copie avec modifications
  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? cryptoId,
    String? cryptoSymbol,
    double? cryptoPrice,
    double? amountXOF,
    String? paymentMethod,
    DateTime? timestamp,
    TransactionStatus? status,
    String? transactionId,
    bool? syncedWithCloud,
    String? errorMessage,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      cryptoId: cryptoId ?? this.cryptoId,
      cryptoSymbol: cryptoSymbol ?? this.cryptoSymbol,
      cryptoPrice: cryptoPrice ?? this.cryptoPrice,
      amountXOF: amountXOF ?? this.amountXOF,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      syncedWithCloud: syncedWithCloud ?? this.syncedWithCloud,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Formater le montant pour l'affichage
  String get formattedAmount {
    switch (type) {
      case TransactionType.DEPOSIT:
      case TransactionType.WITHDRAWAL:
        return '${amount.toStringAsFixed(0)} XOF';
      case TransactionType.BUY:
      case TransactionType.SELL:
        return '$amount ${cryptoSymbol ?? ""}';
    }
  }

  // Obtenir le montant en XOF (pour calcul du solde)
  double get amountInXOF {
    switch (type) {
      case TransactionType.DEPOSIT:
        return amount; // Dépôt : positif
      case TransactionType.WITHDRAWAL:
        return -amount; // Retrait : négatif
      case TransactionType.BUY:
        return -(amountXOF ?? 0); // Achat : négatif (on dépense XOF)
      case TransactionType.SELL:
        return amountXOF ?? 0; // Vente : positif (on reçoit XOF)
    }
  }

  // Titre pour l'affichage
  String get title {
    switch (type) {
      case TransactionType.DEPOSIT:
        return 'Dépôt';
      case TransactionType.WITHDRAWAL:
        return 'Retrait';
      case TransactionType.BUY:
        return 'Achat ${cryptoSymbol ?? ""}';
      case TransactionType.SELL:
        return 'Vente ${cryptoSymbol ?? ""}';
    }
  }
}
