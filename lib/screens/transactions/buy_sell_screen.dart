import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

// Définition de l'écran principal BuySellScreen
class BuySellScreen extends StatefulWidget {
  // Le paramètre 'isBuying' permet de définir l'onglet initial (Acheter ou Vendre)
  final bool isBuying;
  const BuySellScreen({super.key, required this.isBuying});

  @override
  State<BuySellScreen> createState() => _BuySellScreenState();
}

class _BuySellScreenState extends State<BuySellScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialisation du TabController avec 2 onglets (Acheter et Vendre)
    _tabController = TabController(length: 2, vsync: this);
    
    // Si l'intention est d'acheter (isBuying est true), l'index initial est 0 (Acheter).
    // Sinon, l'index initial est 1 (Vendre).
    if (!widget.isBuying) {
      _tabController.index = 1;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Transaction',
          style: AppTextStyles.heading2,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: _buildTabBar(),
          ),
          // Contenu qui change entre Acheter et Vendre
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TransactionForm(
                  isBuying: true,
                  onSuccess: () {
                    // Logique pour après un achat réussi (ex: navigation, alerte)
                  },
                ),
                _TransactionForm(
                  isBuying: false,
                  onSuccess: () {
                    // Logique pour après une vente réussie (ex: navigation, alerte)
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour la barre d'onglets personnalisée (Acheter/Vendre)
  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: AppColors.primaryGreen, // Couleur de l'onglet sélectionné
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textFaded,
        labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'Acheter'),
          Tab(text: 'Vendre'),
        ],
      ),
    );
  }
}

// Composant interne pour le formulaire d'achat ou de vente
class _TransactionForm extends StatefulWidget {
  final bool isBuying;
  final VoidCallback onSuccess;

  const _TransactionForm({required this.isBuying, required this.onSuccess});

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedCoin = 'Bitcoin';
  double _coinPrice = 67000.00; // Prix simulé
  double _currentBalance = 12500.00; // Solde XOF simulé
  
  // Liste des crypto-monnaies disponibles
  final List<String> _coins = ['Bitcoin', 'Ethereum', 'Tether', 'BNB'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Fonction pour afficher un message à l'utilisateur
  void _showMessageModal(BuildContext context, String title, String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, style: AppTextStyles.heading2.copyWith(color: AppColors.text)),
          content: Text(message, style: AppTextStyles.body.copyWith(color: AppColors.textFaded)),
          actions: <Widget>[
            TextButton(
              child: Text("OK", style: AppTextStyles.body.copyWith(color: isError ? AppColors.primaryRed : AppColors.primaryGreen, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String actionLabel = widget.isBuying ? 'Acheter' : 'Vendre';
    String unit = widget.isBuying ? 'XOF' : _selectedCoin;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Sélection de la crypto-monnaie ---
            Text('Sélectionner la crypto-monnaie', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedCoin,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                dropdownColor: AppColors.card,
                style: AppTextStyles.body,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.text),
                items: _coins.map((String coin) {
                  return DropdownMenuItem<String>(
                    value: coin,
                    child: Text(coin),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCoin = newValue!;
                    // Simuler un nouveau prix pour la démo
                    _coinPrice = newValue == 'Bitcoin' ? 67000.00 : 3500.00;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // --- Champ de Montant ---
            Text('Montant en $unit', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: AppTextStyles.heading1,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: AppTextStyles.heading1.copyWith(color: AppColors.textFaded),
                suffixText: unit,
                suffixStyle: AppTextStyles.heading1.copyWith(color: AppColors.text),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Solde disponible
            Text(
              'Disponible: $_currentBalance XOF',
              style: AppTextStyles.bodyFaded,
            ),
            const SizedBox(height: 24),

            // --- Récapitulatif de la transaction ---
            _buildSummaryRow('Prix actuel du $_selectedCoin', 'XOF ${_coinPrice.toStringAsFixed(2)}'),
            _buildSummaryRow('Frais de transaction', '0.00 XOF', isGreen: true),
            
            // Ligne de conversion (cachée si le montant n'est pas saisi)
            if (_amountController.text.isNotEmpty)
              _buildSummaryRow(
                'Montant en $_selectedCoin', 
                '~ ${(double.tryParse(_amountController.text) ?? 0) / _coinPrice} ${_selectedCoin[0]}',
              ),
            
            const SizedBox(height: 40),

            // --- Bouton d'action ---
            ElevatedButton(
              onPressed: () {
                // Afficher le message d'erreur d'API demandé
                 _showMessageModal(
                  context,
                  "Erreur d'API",
                  "L'API de réception d'argent n'est pas encore obtenue. Veuillez réessayer plus tard.",
                  isError: true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isBuying ? AppColors.primaryGreen : AppColors.primaryRed,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(
                '$actionLabel ${_selectedCoin}',
                style: AppTextStyles.heading2.copyWith(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget pour les lignes de résumé
  Widget _buildSummaryRow(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyFaded),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: isGreen ? AppColors.primaryGreen : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}