import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "Utilisateur";
  String userPhone = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("userName") ?? "Utilisateur";
      userPhone = prefs.getString("userPhone") ?? "";
    });
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) return "U";
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  // Formater le numéro de téléphone pour l'affichage
  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return "";
    // Enlever le +225 si présent
    String cleaned = phone.replaceAll('+225', '').replaceAll(' ', '');
    if (cleaned.length == 10) {
      // Formater comme +225 058 683 6054
      return '+225 ${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
    }
    return phone;
  }

  void _performLogout(BuildContext context) async {
    // Afficher une confirmation
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
              _executeLogout(context);
            },
            child: Text("Déconnexion", style: AppTextStyles.link.copyWith(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _executeLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // --- HEADER AVEC PROFIL UTILISATEUR ---
                  Row(
                    children: [
                      // Avatar circulaire
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: AppColors.card,
                        child: Text(
                          _initialsFromName(userName),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Nom et téléphone
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: AppTextStyles.heading2.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatPhoneNumber(userPhone),
                              style: AppTextStyles.body.copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Drapeau de la Côte d'Ivoire
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: ClipOval(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFF77F00), // Orange
                                  Color(0xFFFFFFFF), // Blanc
                                  Color(0xFF009639), // Vert
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // --- SECTION MENU ---
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Mon Compte
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Mon Compte',
                          onTap: () {
                            // TODO: Naviguer vers la page Mon Compte
                          },
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        
                        // Paramètres
                        _buildMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Paramètres',
                          onTap: () {
                            // TODO: Naviguer vers les paramètres
                          },
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        
                        // Centre d'aide
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Centre d\'aide',
                          onTap: () {
                            // TODO: Naviguer vers le centre d'aide
                          },
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        
                        // Contact
                        _buildMenuItem(
                          icon: Icons.phone_outlined,
                          title: 'Contact',
                          onTap: () {
                            // TODO: Ouvrir les options de contact
                          },
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        
                        // Deconnexion (en rouge)
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Deconnexion',
                          isLogout: true,
                          onTap: () => _performLogout(context),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // --- BLOC DE TEXTE INFORMATIF ---
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: '1 mois avec '),
                        TextSpan(
                          text: 'MobileCrypto',
                          style: AppTextStyles.body.copyWith(
                            color: const Color(0xFF4A90E2), // Bleu clair
                            fontSize: 14,
                          ),
                        ),
                        const TextSpan(
                          text: ', et toujours la même mission: acheter et vendre tes cryptos en toute simplicité.',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  // Espace flexible
                  Expanded(child: Container()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          children: [
            // Icône
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLogout
                    ? AppColors.primaryRed
                    : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    color: isLogout ? Colors.white : AppColors.text,
                    size: 20,
                  ),
                  if (isLogout)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.primaryRed,
                          size: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Titre
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  color: isLogout ? AppColors.primaryRed : AppColors.text,
                  fontWeight: isLogout ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            
            // Flèche
            Icon(
              Icons.arrow_forward_ios,
              color: isLogout ? AppColors.primaryRed : AppColors.textFaded,
              size: isLogout ? 20 : 18,
            ),
          ],
        ),
      ),
    );
  }
}
