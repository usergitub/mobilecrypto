import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/utils/app_theme.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _userName = "Utilisateur";
  String _userPhone = "";
  String _userEmail = "";
  String _country = "Côte d'Ivoire";
  String _kycLevel = "Non vérifié";
  bool _twoFactorEnabled = false;
  
  List<Map<String, String>> _paymentMethods = [
    {'type': 'MTN MoMo', 'number': '+225 07 08 09 10 11', 'verified': 'true'},
    {'type': 'Orange Money', 'number': '+225 05 12 34 56 78', 'verified': 'true'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      setState(() {
        _userName = prefs.getString("userName") ?? "Utilisateur";
        _userPhone = prefs.getString("userPhone") ?? "";
        _userEmail = user?.email ?? "";
      });
    } catch (e) {
      debugPrint("Erreur chargement données: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Mon Compte', style: AppTextStyles.heading2),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations personnelles
              _buildSection(
                'Informations personnelles',
                [
                  _buildInfoRow('Nom complet', _userName, Icons.person),
                  _buildInfoRow('Numéro de téléphone', _userPhone, Icons.phone, isEditable: false),
                  _buildInfoRow('Email', _userEmail.isEmpty ? 'Non renseigné' : _userEmail, Icons.email),
                  _buildInfoRow('Pays de résidence', _country, Icons.location_on),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Niveau de vérification KYC
              _buildSection(
                'Vérification d\'identité',
                [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _kycLevel == "Non vérifié" 
                          ? AppColors.primaryRed.withOpacity(0.1)
                          : AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _kycLevel == "Non vérifié" 
                            ? AppColors.primaryRed
                            : AppColors.primaryGreen,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _kycLevel == "Non vérifié" ? Icons.warning : Icons.verified,
                          color: _kycLevel == "Non vérifié" 
                              ? AppColors.primaryRed
                              : AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Niveau de vérification',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textFaded,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _kycLevel,
                                style: AppTextStyles.heading2.copyWith(
                                  fontSize: 16,
                                  color: _kycLevel == "Non vérifié" 
                                      ? AppColors.primaryRed
                                      : AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_kycLevel == "Non vérifié")
                          TextButton(
                            onPressed: () => _showKYCInfo(),
                            child: Text(
                              'Vérifier',
                              style: AppTextStyles.link.copyWith(
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Méthodes de paiement
              _buildSection(
                'Méthodes de paiement',
                [
                  ..._paymentMethods.map((method) => _buildPaymentMethodCard(method)),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _addPaymentMethod(),
                      icon: Icon(Icons.add, color: AppColors.primaryGreen),
                      label: Text(
                        'Ajouter une méthode de paiement',
                        style: AppTextStyles.link.copyWith(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Sécurité
              _buildSection(
                'Sécurité',
                [
                  SwitchListTile(
                    title: Text('Authentification à deux facteurs (2FA)', style: AppTextStyles.body),
                    subtitle: Text(
                      _twoFactorEnabled ? 'Activé' : 'Désactivé',
                      style: AppTextStyles.bodyFaded.copyWith(fontSize: 12),
                    ),
                    value: _twoFactorEnabled,
                    onChanged: (value) {
                      setState(() {
                        _twoFactorEnabled = value;
                      });
                    },
                    activeColor: AppColors.primaryGreen,
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading2.copyWith(
            fontSize: 18,
            color: AppColors.textFaded,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {bool isEditable = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textFaded, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textFaded,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.heading2.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          if (isEditable)
            IconButton(
              icon: Icon(Icons.edit, size: 18, color: AppColors.primaryGreen),
              onPressed: () => _editField(label, value),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, String> method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance_wallet, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method['type'] ?? '',
                  style: AppTextStyles.heading2.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  method['number'] ?? '',
                  style: AppTextStyles.bodyFaded.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          if (method['verified'] == 'true')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Vérifié',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.primaryRed, size: 20),
            onPressed: () => _removePaymentMethod(method),
          ),
        ],
      ),
    );
  }

  void _editField(String label, String currentValue) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Modifier $label', style: AppTextStyles.heading2),
        content: TextField(
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: currentValue,
            hintStyle: AppTextStyles.bodyFaded,
          ),
          controller: TextEditingController(text: currentValue),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Sauvegarder la modification
            },
            child: Text('Enregistrer', style: AppTextStyles.link.copyWith(color: AppColors.primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _showKYCInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Vérification d\'identité', style: AppTextStyles.heading2),
        content: Text(
          'Pour vérifier votre identité, vous devrez fournir:\n\n'
          '• Niveau 1: Selfie + Carte d\'identité\n'
          '• Niveau 2: Revenus + Adresse\n\n'
          'Cette fonctionnalité sera bientôt disponible.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: AppTextStyles.link.copyWith(color: AppColors.primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _addPaymentMethod() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Ajouter une méthode', style: AppTextStyles.heading2),
        content: Text(
          'Sélectionnez votre méthode de paiement Mobile Money',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter l'ajout
            },
            child: Text('Ajouter', style: AppTextStyles.link.copyWith(color: AppColors.primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _removePaymentMethod(Map<String, String> method) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Supprimer', style: AppTextStyles.heading2),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${method['type']}?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _paymentMethods.remove(method);
              });
              Navigator.pop(context);
            },
            child: Text('Supprimer', style: AppTextStyles.link.copyWith(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }
}

