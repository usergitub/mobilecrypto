import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/utils/app_theme.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
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
        title: Text('Centre d\'aide', style: AppTextStyles.heading2),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FAQ
              _buildSection(
                'Questions fréquentes',
                [
                  _buildFAQItem(
                    'Comment déposer de l\'argent?',
                    'Vous pouvez déposer via MTN MoMo, Orange Money, Moov Money ou Wave. Allez dans "Dépôt" et suivez les instructions.',
                  ),
                  _buildFAQItem(
                    'Comment retirer de l\'argent?',
                    'Allez dans "Retrait", sélectionnez votre méthode de paiement et entrez le montant. Le retrait est traité sous 24h.',
                  ),
                  _buildFAQItem(
                    'Comment acheter des cryptomonnaies?',
                    'Sélectionnez "Acheter", choisissez la crypto, entrez le montant en XOF et confirmez la transaction.',
                  ),
                  _buildFAQItem(
                    'Comment vendre des cryptomonnaies?',
                    'Sélectionnez "Vendre", choisissez la crypto à vendre, entrez le montant et confirmez. Vous recevrez le montant en XOF.',
                  ),
                  _buildFAQItem(
                    'Quelles sont les limites de transaction?',
                    'Limite minimale d\'achat: 2500 XOF. Limite minimale de vente: variable selon la crypto (voir détails).',
                  ),
                  _buildFAQItem(
                    'Combien de temps prend une transaction?',
                    'Les transactions sont généralement traitées en 1 à 5 minutes. Les retraits peuvent prendre jusqu\'à 24h.',
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Guide rapide
              _buildSection(
                'Guide rapide',
                [
                  _buildActionCard(
                    'Guide d\'utilisation',
                    'Apprenez à utiliser MobileCrypto en 5 minutes',
                    Icons.book_outlined,
                    () => _showGuide(),
                  ),
                  _buildActionCard(
                    'Tutoriels vidéo',
                    'Regardez nos tutoriels pour maîtriser l\'app',
                    Icons.video_library_outlined,
                    () => _showTutorials(),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Support
              _buildSection(
                'Support',
                [
                  _buildActionCard(
                    'Ouvrir un ticket',
                    'Contactez notre équipe support',
                    Icons.support_agent,
                    () => _openSupportTicket(),
                  ),
                  _buildActionCard(
                    'Chat en direct',
                    'Discutez avec un agent en temps réel',
                    Icons.chat_bubble_outline,
                    () => _startLiveChat(),
                  ),
                  _buildActionCard(
                    'WhatsApp Support',
                    'Contactez-nous via WhatsApp',
                    Icons.chat,
                    () async {
                      final url = Uri.parse('https://wa.me/2250708091011');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Statut du service
              _buildSection(
                'Statut du service',
                [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGreen),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tous les services sont opérationnels',
                                style: AppTextStyles.heading2.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'API CoinGecko: En ligne\nMobile Money: Disponible',
                                style: AppTextStyles.bodyFaded.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Politique & Conditions
              _buildSection(
                'Politique & Conditions',
                [
                  _buildActionCard(
                    'Conditions Générales d\'Utilisation',
                    'Lisez nos CGU',
                    Icons.description_outlined,
                    () => _showCGU(),
                  ),
                  _buildActionCard(
                    'Politique de confidentialité',
                    'Comment nous protégeons vos données',
                    Icons.privacy_tip_outlined,
                    () => _showPrivacyPolicy(),
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
        ...children,
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: AppTextStyles.heading2.copyWith(fontSize: 16)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: AppTextStyles.body.copyWith(color: AppColors.textFaded),
          ),
        ),
      ],
      iconColor: AppColors.primaryGreen,
      collapsedIconColor: AppColors.textFaded,
      backgroundColor: AppColors.card,
      collapsedBackgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryGreen),
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
                      style: AppTextStyles.bodyFaded.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppColors.textFaded, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _showGuide() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Guide d\'utilisation', style: AppTextStyles.heading2),
        content: SingleChildScrollView(
          child: Text(
            '1. Créez un compte avec votre numéro de téléphone\n'
            '2. Vérifiez votre identité (KYC)\n'
            '3. Ajoutez une méthode de paiement Mobile Money\n'
            '4. Déposez des fonds\n'
            '5. Achetez ou vendez des cryptomonnaies\n'
            '6. Retirez vos gains en XOF',
            style: AppTextStyles.body,
          ),
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

  void _showTutorials() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Tutoriels vidéo', style: AppTextStyles.heading2),
        content: Text(
          'Les tutoriels vidéo seront bientôt disponibles sur notre chaîne YouTube.',
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

  void _openSupportTicket() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Ouvrir un ticket', style: AppTextStyles.heading2),
        content: Text(
          'Cette fonctionnalité sera bientôt disponible. En attendant, contactez-nous via WhatsApp ou email.',
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

  void _startLiveChat() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Chat en direct', style: AppTextStyles.heading2),
        content: Text(
          'Le chat en direct sera bientôt disponible. Contactez-nous via WhatsApp pour une assistance immédiate.',
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

  void _showCGU() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Conditions Générales', style: AppTextStyles.heading2),
        content: SingleChildScrollView(
          child: Text(
            'Conditions Générales d\'Utilisation de MobileCrypto\n\n'
            'En utilisant MobileCrypto, vous acceptez nos conditions générales d\'utilisation...\n\n'
            '(Contenu complet des CGU à ajouter)',
            style: AppTextStyles.body,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer', style: AppTextStyles.link.copyWith(color: AppColors.primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Politique de confidentialité', style: AppTextStyles.heading2),
        content: SingleChildScrollView(
          child: Text(
            'Politique de Confidentialité de MobileCrypto\n\n'
            'Nous nous engageons à protéger vos données personnelles...\n\n'
            '(Contenu complet de la politique à ajouter)',
            style: AppTextStyles.body,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer', style: AppTextStyles.link.copyWith(color: AppColors.primaryGreen)),
          ),
        ],
      ),
    );
  }
}
