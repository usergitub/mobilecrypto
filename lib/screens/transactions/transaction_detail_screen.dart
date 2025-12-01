import 'package:flutter/material.dart';
import '/utils/app_theme.dart';
import '/models/transaction.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.type == TransactionType.DEPOSIT ||
        transaction.type == TransactionType.SELL;
    
    final color = isPositive ? AppColors.primaryGreen : AppColors.primaryRed;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Détails de la transaction', style: AppTextStyles.heading2),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte principale
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Icône et montant
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getTransactionIcon(transaction.type),
                        color: color,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      transaction.title,
                      style: AppTextStyles.heading2.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      isPositive ? '+${transaction.formattedAmount}' : '-${transaction.formattedAmount}',
                      style: AppTextStyles.heading1.copyWith(
                        color: color,
                        fontSize: 32,
                      ),
                    ),
                    
                    if (transaction.amountXOF != null &&
                        (transaction.type == TransactionType.BUY ||
                         transaction.type == TransactionType.SELL)) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${transaction.amountXOF!.toStringAsFixed(0)} XOF',
                        style: AppTextStyles.bodyFaded.copyWith(fontSize: 16),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Statut
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction.status).withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(transaction.status),
                        style: AppTextStyles.body.copyWith(
                          color: _getStatusColor(transaction.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Informations détaillées
              Text(
                'Informations',
                style: AppTextStyles.heading2.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Date',
                      _formatDateTime(transaction.timestamp),
                      Icons.calendar_today,
                    ),
                    const Divider(color: AppColors.border, height: 24),
                    
                    _buildDetailRow(
                      'Méthode de paiement',
                      transaction.paymentMethod,
                      Icons.payment,
                    ),
                    
                    if (transaction.cryptoSymbol != null) ...[
                      const Divider(color: AppColors.border, height: 24),
                      _buildDetailRow(
                        'Cryptomonnaie',
                        transaction.cryptoSymbol!,
                        Icons.currency_bitcoin,
                      ),
                    ],
                    
                    if (transaction.cryptoPrice != null) ...[
                      const Divider(color: AppColors.border, height: 24),
                      _buildDetailRow(
                        'Prix unitaire',
                        '${transaction.cryptoPrice!.toStringAsFixed(2)} USD',
                        Icons.attach_money,
                      ),
                    ],
                    
                    if (transaction.transactionId != null) ...[
                      const Divider(color: AppColors.border, height: 24),
                      _buildDetailRow(
                        'ID Transaction',
                        transaction.transactionId!,
                        Icons.tag,
                      ),
                    ],
                    
                    if (transaction.errorMessage != null) ...[
                      const Divider(color: AppColors.border, height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline, color: AppColors.primaryRed, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Erreur',
                                  style: AppTextStyles.bodyFaded.copyWith(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  transaction.errorMessage!,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.primaryRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textFaded, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyFaded.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
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

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.COMPLETED:
        return AppColors.primaryGreen;
      case TransactionStatus.PENDING:
        return AppColors.textFaded;
      case TransactionStatus.FAILED:
        return AppColors.primaryRed;
    }
  }

  String _getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.COMPLETED:
        return 'Terminé';
      case TransactionStatus.PENDING:
        return 'En attente';
      case TransactionStatus.FAILED:
        return 'Échoué';
    }
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

