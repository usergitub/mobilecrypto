import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '/utils/app_theme.dart';
import '/models/transaction.dart';
import '/repositories/transaction_repository.dart';
import '/screens/transactions/transaction_detail_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionRepository _repository = TransactionRepository();
  List<Transaction> _transactions = [];
  bool _loading = true;
  bool _isOnline = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadTransactions();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = !connectivityResults.contains(ConnectivityResult.none);
    });
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _checkConnectivity();
      final transactions = await _repository.getTransactions();
      
      setState(() {
        _transactions = transactions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des transactions';
        _loading = false;
      });
    }
  }

  Future<void> _refreshTransactions() async {
    await _checkConnectivity();
    await _loadTransactions();
    
    // Synchroniser les transactions en attente si en ligne
    if (_isOnline) {
      await _repository.syncPendingTransactions();
      await _loadTransactions(); // Recharger après sync
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Mes Reçus', style: AppTextStyles.heading2),
        centerTitle: true,
        actions: [
          // Indicateur de connexion
          if (!_isOnline)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.wifi_off,
                color: AppColors.textFaded,
                size: 20,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Message hors ligne
            if (!_isOnline && _transactions.isNotEmpty) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGreen.withAlpha(51)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off, color: AppColors.textFaded, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Mode hors ligne - Données mises en cache',
                            style: AppTextStyles.bodyFaded.copyWith(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildTransactionsList()),
                ],
              );
            }

            // État de chargement
            if (_loading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            // Erreur
            if (_error != null && _transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.primaryRed, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: AppTextStyles.bodyFaded,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadTransactions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                      ),
                      child: Text('Réessayer', style: AppTextStyles.body),
                    ),
                  ],
                ),
              );
            }

            // Liste vide
            if (_transactions.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refreshTransactions,
                color: AppColors.primaryGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_long,
                              color: AppColors.textFaded,
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Effectuez un achat pour commencer",
                            style: AppTextStyles.heading2,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Vos transactions et reçus apparaîtront ici.",
                            style: AppTextStyles.bodyFaded,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            // Liste des transactions
            return RefreshIndicator(
              onRefresh: _refreshTransactions,
              color: AppColors.primaryGreen,
              child: _buildTransactionsList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    // Grouper par date
    final grouped = <String, List<Transaction>>{};
    
    for (final transaction in _transactions) {
      final dateKey = _formatDate(transaction.timestamp);
      grouped.putIfAbsent(dateKey, () => []).add(transaction);
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final transactions = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de date
            Padding(
              padding: EdgeInsets.only(bottom: 12, top: index > 0 ? 24 : 0),
              child: Text(
                date,
                style: AppTextStyles.bodyFaded.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Transactions du jour
            ...transactions.map((transaction) => _buildTransactionItem(transaction)),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isPositive = transaction.type == TransactionType.DEPOSIT ||
        transaction.type == TransactionType.SELL;
    
    final color = isPositive ? AppColors.primaryGreen : AppColors.primaryRed;
    final icon = _getTransactionIcon(transaction.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailScreen(transaction: transaction),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icône
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              
              // Détails
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(transaction.timestamp),
                      style: AppTextStyles.bodyFaded.copyWith(fontSize: 12),
                    ),
                    if (transaction.cryptoSymbol != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        transaction.cryptoSymbol!,
                        style: AppTextStyles.bodyFaded.copyWith(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Montant
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isPositive ? '+${transaction.formattedAmount}' : '-${transaction.formattedAmount}',
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 16,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (transaction.amountXOF != null && 
                      (transaction.type == TransactionType.BUY || 
                       transaction.type == TransactionType.SELL)) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${transaction.amountXOF!.toStringAsFixed(0)} XOF',
                      style: AppTextStyles.bodyFaded.copyWith(fontSize: 12),
                    ),
                  ],
                  // Statut
                  if (transaction.status != TransactionStatus.COMPLETED) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: transaction.status == TransactionStatus.FAILED
                            ? AppColors.primaryRed.withAlpha(25)
                            : AppColors.textFaded.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction.status == TransactionStatus.FAILED
                            ? 'Échoué'
                            : 'En attente',
                        style: AppTextStyles.bodyFaded.copyWith(
                          fontSize: 10,
                          color: transaction.status == TransactionStatus.FAILED
                              ? AppColors.primaryRed
                              : AppColors.textFaded,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.DEPOSIT:
        return Icons.arrow_downward;
      case TransactionType.WITHDRAWAL:
        return Icons.arrow_upward;
      case TransactionType.BUY:
        return Icons.shopping_cart;
      case TransactionType.SELL:
        return Icons.sell;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Aujourd\'hui';
    } else if (transactionDate == today.subtract(const Duration(days: 1))) {
      return 'Hier';
    } else {
      final months = [
        'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
