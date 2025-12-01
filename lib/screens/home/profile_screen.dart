import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '/utils/app_theme.dart';
import '/screens/home/settings_screen.dart';
import '/screens/home/account_screen.dart';
import '/screens/home/help_center_screen.dart';

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
    if (!mounted) return;
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

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Contact',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 20),
              
              // WhatsApp
              _buildContactItem(
                icon: Icons.chat,
                title: 'WhatsApp',
                subtitle: '+225 07 08 09 10 11',
                color: const Color(0xFF25D366),
                onTap: () async {
                  final url = Uri.parse('https://wa.me/2250708091011');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              
              const SizedBox(height: 12),
              
              // Numéro d'appel
              _buildContactItem(
                icon: Icons.phone,
                title: 'Appeler',
                subtitle: '+225 07 08 09 10 11',
                color: AppColors.primaryGreen,
                onTap: () async {
                  final url = Uri.parse('tel:+2250708091011');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              
              const SizedBox(height: 12),
              
              // Email
              _buildContactItem(
                icon: Icons.email,
                title: 'Email',
                subtitle: 'support@mobilecrypto.com',
                color: AppColors.primaryGreen,
                onTap: () async {
                  final url = Uri.parse('mailto:support@mobilecrypto.com');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
              ),
              
              const SizedBox(height: 12),
              
              // Réseaux sociaux
              Text(
                'Réseaux sociaux',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textFaded,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSocialIcon(Icons.chat, 'Telegram', () async {
                    final url = Uri.parse('https://t.me/mobilecrypto');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  }),
                  _buildSocialIcon(Icons.alternate_email, 'Twitter/X', () async {
                    final url = Uri.parse('https://twitter.com/mobilecrypto');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  }),
                  _buildSocialIcon(Icons.facebook, 'Facebook', () async {
                    final url = Uri.parse('https://facebook.com/mobilecrypto');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  }),
                  _buildSocialIcon(Icons.camera_alt, 'Instagram', () async {
                    final url = Uri.parse('https://instagram.com/mobilecrypto');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  }),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading2.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyFaded.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.textFaded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodyFaded.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
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
    await prefs.remove('userPhone'); // Supprimer le numéro de téléphone
    await prefs.remove('userName'); // Supprimer le nom d'utilisateur
    await prefs.remove('pinCreated'); // Supprimer l'indicateur de PIN créé
    debugPrint("✅ Déconnexion effectuée - toutes les données de session supprimées");
    
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AccountScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        
                        // Paramètres
                        _buildMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Paramètres',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        
                        // Centre d'aide
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Centre d\'aide',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HelpCenterScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        
                        // Contact
                        _buildMenuItem(
                          icon: Icons.phone_outlined,
                          title: 'Contact',
                          onTap: () => _showContactOptions(context),
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
