import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '/utils/app_theme.dart';
import 'transaction_failed_screen.dart';

/// Écran Achat/Vente d'une crypto.
/// - `coinPrice` attendu en **FCFA** (nous convertissons USD→FCFA côté HomeScreen).
/// - Achat = prix final = officiel **+ 25 FCFA**
/// - Vente = prix final = officiel **− 10 FCFA**
class BuySellScreen extends StatefulWidget {
  final bool isBuying;
  final String coinName;
  final String coinSymbol;
  final double coinPrice; // en FCFA (prix officiel reçu)

  const BuySellScreen({
    super.key,
    required this.isBuying,
    required this.coinName,
    required this.coinSymbol,
    required this.coinPrice,
  });

  @override
  State<BuySellScreen> createState() => _BuySellScreenState();
}

class _BuySellScreenState extends State<BuySellScreen> {
  final TextEditingController _payAmountController = TextEditingController();
  final TextEditingController _receiveAmountController = TextEditingController();
  
  // Méthodes de paiement Mobile Money
  final List<String> _mobileMoneyMethods = ['WAVE', 'MTN', 'Orange', 'Moov'];
  
  // Initialisation selon isBuying
  late String _selectedPayMethod;
  late String _selectedReceiveMethod;
  late bool _isMobileMoneyPay;
  
  // Flag pour éviter les boucles infinies lors des mises à jour
  bool _isUpdating = false;

  double get finalUnitPrice {
    return widget.isBuying
        ? (widget.coinPrice + 25) // Achat : +25 FCFA
        : (widget.coinPrice - 10); // Vente : -10 FCFA
  }

  @override
  void initState() {
    super.initState();
    
    // Initialisation selon le type de transaction
    if (widget.isBuying) {
      // ACHAT : Vous payez en Mobile Money, vous recevez en Crypto
      _selectedPayMethod = 'WAVE';
      _selectedReceiveMethod = widget.coinSymbol.toUpperCase();
      _isMobileMoneyPay = true;
    } else {
      // VENTE : Vous payez en Crypto, vous recevez en Mobile Money
      _selectedPayMethod = widget.coinSymbol.toUpperCase();
      _selectedReceiveMethod = 'WAVE';
      _isMobileMoneyPay = false;
    }
    
    _payAmountController.addListener(_updateReceiveAmount);
    _receiveAmountController.addListener(_updatePayAmount);
  }

  @override
  void dispose() {
    _payAmountController.removeListener(_updateReceiveAmount);
    _receiveAmountController.removeListener(_updatePayAmount);
    _payAmountController.dispose();
    _receiveAmountController.dispose();
    super.dispose();
  }

  // Conversion en temps réel : Vous payez → Vous recevez
  void _updateReceiveAmount() {
    if (_isUpdating) return;
    _isUpdating = true;
    
    setState(() {
      final payAmount = double.tryParse(_payAmountController.text) ?? 0;
      
      if (payAmount == 0) {
        if (_receiveAmountController.text.isEmpty) {
          _receiveAmountController.text = '';
        }
        _isUpdating = false;
        return;
      }

      if (widget.isBuying) {
        // ACHAT : XOF → Crypto
        final cryptoAmount = payAmount / finalUnitPrice;
        _receiveAmountController.text = cryptoAmount.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      } else {
        // VENTE : Crypto → XOF
        final xofAmount = payAmount * finalUnitPrice;
        _receiveAmountController.text = xofAmount.toStringAsFixed(2);
      }
    });
    
    _isUpdating = false;
  }

  // Conversion en temps réel : Vous recevez → Vous payez
  void _updatePayAmount() {
    if (_isUpdating) return;
    _isUpdating = true;
    
    setState(() {
      final receiveAmount = double.tryParse(_receiveAmountController.text) ?? 0;
      
      if (receiveAmount == 0) {
        if (_payAmountController.text.isEmpty) {
          _payAmountController.text = '';
        }
        _isUpdating = false;
        return;
      }

      if (widget.isBuying) {
        // ACHAT : Crypto → XOF
        final xofAmount = receiveAmount * finalUnitPrice;
        _payAmountController.text = xofAmount.toStringAsFixed(2);
      } else {
        // VENTE : XOF → Crypto
        final cryptoAmount = receiveAmount / finalUnitPrice;
        _payAmountController.text = cryptoAmount.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      }
    });
    
    _isUpdating = false;
  }

  void _swapCurrencies() {
    setState(() {
      // Échanger les méthodes
      final temp = _selectedPayMethod;
      _selectedPayMethod = _selectedReceiveMethod;
      _selectedReceiveMethod = temp;
      _isMobileMoneyPay = !_isMobileMoneyPay;
      
      // Échanger les montants
      final tempAmount = _payAmountController.text;
      _payAmountController.text = _receiveAmountController.text;
      _receiveAmountController.text = tempAmount;
      
      // Recalculer après l'échange
      _updateReceiveAmount();
    });
  }

  void _showPaymentMethodSelector(bool isPayMethod) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final methods = isPayMethod && widget.isBuying
            ? _mobileMoneyMethods
            : isPayMethod && !widget.isBuying
                ? [widget.coinSymbol.toUpperCase()]
                : !isPayMethod && widget.isBuying
                    ? [widget.coinSymbol.toUpperCase()]
                    : _mobileMoneyMethods;

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sélectionner une méthode',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 20),
              ...methods.map((method) {
                final isSelected = isPayMethod
                    ? _selectedPayMethod == method
                    : _selectedReceiveMethod == method;

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getMethodColor(method).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getMethodIcon(method),
                      color: _getMethodColor(method),
                    ),
                  ),
                  title: Text(
                    method,
                    style: AppTextStyles.body,
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check,
                          color: AppColors.primaryGreen,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      if (isPayMethod) {
                        _selectedPayMethod = method;
                      } else {
                        _selectedReceiveMethod = method;
                      }
                    });
                    Navigator.pop(context);
                    _updateReceiveAmount();
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'WAVE':
        return const Color(0xFF4A90E2);
      case 'MTN':
        return Colors.yellow.shade700;
      case 'ORANGE':
        return Colors.orange;
      case 'MOOV':
        return Colors.red;
      default:
        return const Color(0xFF26A17B); // Pour les cryptos
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method.toUpperCase()) {
      case 'WAVE':
      case 'MTN':
      case 'ORANGE':
      case 'MOOV':
        return Icons.account_balance_wallet;
      default:
        return Icons.currency_bitcoin;
    }
  }

  double get calculatedTotal {
    if (_payAmountController.text.isEmpty) return 0;
    final amount = double.tryParse(_payAmountController.text) ?? 0;
    return amount;
  }

  @override
  Widget build(BuildContext context) {
    // Déterminer les couleurs selon le type de méthode
    final payMethodColor = _isMobileMoneyPay
        ? _getMethodColor(_selectedPayMethod)
        : const Color(0xFF26A17B);
    final receiveMethodColor = !_isMobileMoneyPay && widget.isBuying
        ? _getMethodColor(_selectedReceiveMethod)
        : widget.isBuying
            ? const Color(0xFF26A17B)
            : _getMethodColor(_selectedReceiveMethod);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.text, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CARTE "VOUS PAYEZ" ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Label "Vous payez"
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Vous payez',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        // Bouton méthode de paiement
                        GestureDetector(
                          onTap: () => _showPaymentMethodSelector(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: payMethodColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _isMobileMoneyPay
                                        ? Colors.black
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getMethodIcon(_selectedPayMethod),
                                    color: _isMobileMoneyPay
                                        ? Colors.white
                                        : payMethodColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedPayMethod,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_isMobileMoneyPay) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Champ de saisie du montant
                    TextField(
                      controller: _payAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: AppTextStyles.heading1.copyWith(
                        fontSize: 36,
                      ),
                      decoration: InputDecoration(
                        hintText: '00',
                        hintStyle: TextStyle(
                          color: AppColors.text.withOpacity(0.5),
                          fontSize: 36,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        suffixText: _isMobileMoneyPay ? 'XOF' : widget.coinSymbol.toUpperCase(),
                        suffixStyle: AppTextStyles.body.copyWith(
                          fontSize: 18,
                          color: AppColors.textFaded,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- BOUTON D'ÉCHANGE ---
              Center(
                child: GestureDetector(
                  onTap: _swapCurrencies,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.swap_vert,
                      color: Color(0xFF9B59B6), // Violet
                      size: 28,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- CARTE "VOUS RECEVEZ" ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Label "Vous recevez"
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Vous recevez',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        // Bouton crypto/méthode à recevoir
                        GestureDetector(
                          onTap: () => _showPaymentMethodSelector(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: receiveMethodColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: widget.isBuying
                                        ? Colors.white
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getMethodIcon(_selectedReceiveMethod),
                                    color: widget.isBuying
                                        ? receiveMethodColor
                                        : receiveMethodColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedReceiveMethod,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Champ de montant reçu (modifiable)
                    TextField(
                      controller: _receiveAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: AppTextStyles.heading1.copyWith(
                        fontSize: 36,
                      ),
                      decoration: InputDecoration(
                        hintText: '00',
                        hintStyle: TextStyle(
                          color: AppColors.text.withOpacity(0.5),
                          fontSize: 36,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        suffixText: widget.isBuying
                            ? widget.coinSymbol.toUpperCase()
                            : 'XOF',
                        suffixStyle: AppTextStyles.body.copyWith(
                          fontSize: 18,
                          color: AppColors.textFaded,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- TAUX DE CHANGE ---
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isBuying
                        ? '1 ${widget.coinSymbol.toUpperCase()} = ${finalUnitPrice.toStringAsFixed(0)} XOF'
                        : '1 ${widget.coinSymbol.toUpperCase()} = ${finalUnitPrice.toStringAsFixed(0)} XOF',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- DÉTAILS DE TRANSACTION ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    _buildTransactionDetailRow(
                      'Frais de transaction',
                      'Gratuit',
                      isOrange: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTransactionDetailRow(
                      'Temps de transaction',
                      '1 minutes',
                    ),
                    const SizedBox(height: 12),
                    _buildTransactionDetailRow(
                      'Transaction totale',
                      '${calculatedTotal.toStringAsFixed(0)} ${_isMobileMoneyPay ? "XOF" : widget.coinSymbol.toUpperCase()}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- LIEN GESTION PAIEMENTS ---
              RichText(
                text: TextSpan(
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: 'Cliquez ici',
                      style: AppTextStyles.link.copyWith(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // TODO: Ouvrir page de gestion des paiements
                        },
                    ),
                    const TextSpan(
                      text:
                          ' pour gérer vos paiements. Vous pourrez facilement mettre à jour le numéro et l\'adresse de votre portefeuille.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- BOUTON CONTINUE ---
              GestureDetector(
                onTap: calculatedTotal > 0
                    ? () {
                        // Simuler une transaction qui échoue (car pas d'API de paiement)
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TransactionFailedScreen(
                              errorMessage: 'La transaction n\'a pas pu être complétée car l\'API de paiement n\'est pas encore intégrée. Veuillez réessayer plus tard ou contacter le support client pour plus d\'informations.',
                            ),
                          ),
                        );
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: calculatedTotal > 0
                        ? AppColors.card
                        : AppColors.card.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          'Continue',
                          style: AppTextStyles.heading2.copyWith(
                            color: calculatedTotal > 0
                                ? AppColors.text
                                : AppColors.textFaded,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chevron_right,
                              color: calculatedTotal > 0
                                  ? AppColors.text
                                  : AppColors.textFaded,
                              size: 20,
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right,
                              color: calculatedTotal > 0
                                  ? AppColors.text
                                  : AppColors.textFaded,
                              size: 20,
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right,
                              color: calculatedTotal > 0
                                  ? AppColors.text
                                  : AppColors.textFaded,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionDetailRow(String label, String value, {bool isOrange = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontSize: 14,
            color: isOrange ? Colors.orange : AppColors.text,
          ),
        ),
      ],
    );
  }

  void _showDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: AppTextStyles.heading2),
        content: Text(message, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler", style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter la logique de transaction
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.isBuying
                        ? "Transaction d'achat en cours..."
                        : "Transaction de vente en cours...",
                  ),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
            child: Text("Confirmer", style: AppTextStyles.link),
          ),
        ],
      ),
    );
  }
}
