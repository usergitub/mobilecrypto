import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: AppTextStyles.heading2.copyWith(color: AppColors.text)),
        content: Text(message, style: AppTextStyles.body.copyWith(color: AppColors.textFaded)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: AppTextStyles.link.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ✅ FONCTION DE DÉCONNEXION
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Déconnexion", style: AppTextStyles.heading2.copyWith(color: AppColors.text)),
        content: Text("Êtes-vous sûr de vouloir vous déconnecter ?", style: AppTextStyles.body.copyWith(color: AppColors.textFaded)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler", style: AppTextStyles.body.copyWith(color: AppColors.textFaded)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout(context);
            },
            child: Text("Déconnexion", style: AppTextStyles.link.copyWith(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ✅ EXÉCUTION DE LA DÉCONNEXION
  void _performLogout(BuildContext context) async {
    // ✅ SUPPRIMER LES DONNÉES DE SESSION
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Marquer comme déconnecté
    // On garde userPhone et userName pour faciliter la reconnexion
    // mais on met isLoggedIn à false pour forcer la reconnexion complète

    // ✅ REDIRECTION VERS L'ÉCRAN DE CONNEXION
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    bool hasToggle = false,
    VoidCallback? onTap,
    Color iconColor = AppColors.textFaded,
  }) {
    final VoidCallback finalOnTap = onTap ?? 
      () => _showDialog(context, title, "Fonctionnalité '$title' en cours de développement.");

    return InkWell(
      onTap: hasToggle ? null : finalOnTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.text, 
                  fontSize: 16,
                ),
              ),
            ),
            if (hasToggle)
              Switch(
                value: true,
                onChanged: (value) => _showDialog(context, title, "Basculement des notifications (Simulé) : $value"),
                activeColor: AppColors.primaryGreen,
              )
            else
              const Icon(Icons.arrow_forward_ios, color: AppColors.textFaded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 16.0),
          child: Text(
            title,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textFaded,
              fontSize: 14,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Paramètres',
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 40.0),
                    child: Column(
                      children: [
                        _buildSection(
                          context,
                          'Mon Compte',
                          [
                            _buildSettingItem(context, title: 'Profil', icon: Icons.person_outline),
                            _buildSettingItem(context, title: 'Sécurité', icon: Icons.lock_outline),
                            _buildSettingItem(context, title: 'Notifications', icon: Icons.notifications_none, hasToggle: true),
                            _buildSettingItem(context, title: 'Mon Portefeuille', icon: Icons.account_balance_wallet_outlined),
                          ],
                        ),
                        _buildSection(
                          context,
                          'Général',
                          [
                            _buildSettingItem(context, title: 'Devise Préférée', icon: Icons.currency_exchange),
                            _buildSettingItem(context, title: 'Langue', icon: Icons.language),
                            const Divider(color: AppColors.border, height: 1),
                            _buildSettingItem(context, title: 'Thème (Clair/Sombre)', icon: Icons.light_mode_outlined),
                          ],
                        ),
                        _buildSection(
                          context,
                          'Aide & Infos',
                          [
                            _buildSettingItem(context, title: 'Conditions Générales', icon: Icons.description_outlined),
                            _buildSettingItem(context, title: 'Aide et Support', icon: Icons.help_outline),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
                          child: TextButton(
                            onPressed: () => _logout(context),
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.card,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: Text(
                              'Déconnexion',
                              style: AppTextStyles.heading2.copyWith(color: AppColors.primaryRed, fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
