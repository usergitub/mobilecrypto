import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/utils/app_theme.dart';
import '/models/notification_model.dart';
import '/screens/transactions/buy_sell_screen.dart';
import '/services/coingecko_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  bool _loading = true;
  bool _hasMadePurchase = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasMadePurchase = prefs.getBool('hasMadePurchase') ?? false;
      
      // Vérifier si l'utilisateur est nouveau ou n'a pas fait d'achat
      final isNewUser = !_hasMadePurchase;
      
      if (isNewUser) {
        // Générer les 5 notifications de bienvenue
        _notifications = _generateWelcomeNotifications();
      } else {
        // Charger les notifications contextuelles
        _notifications = await _generateContextualNotifications();
      }
      
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  List<AppNotification> _generateWelcomeNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'welcome_1',
        title: '🎉 Bienvenue sur MobileCrypto !',
        message: 'Droit à un bonus : 0% de frais sur votre première transaction ! Profitez-en maintenant.',
        type: 'welcome',
        createdAt: now.subtract(const Duration(minutes: 5)),
        actionUrl: 'buy',
      ),
      AppNotification(
        id: 'welcome_2',
        title: '📝 Complétez votre profil',
        message: 'Pour débloquer plus d\'options de retrait et sécuriser votre compte, complétez votre profil dès maintenant.',
        type: 'welcome',
        createdAt: now.subtract(const Duration(minutes: 4)),
        actionUrl: 'profile',
      ),
      AppNotification(
        id: 'welcome_3',
        title: '👥 Parrainage disponible',
        message: 'Invitez vos amis et obtenez des bonus ! Partagez votre code de parrainage et gagnez à chaque invitation.',
        type: 'welcome',
        createdAt: now.subtract(const Duration(minutes: 3)),
        actionUrl: 'referral',
      ),
      AppNotification(
        id: 'welcome_4',
        title: '🏆 Félicitations !',
        message: 'L\'app est en cours de développement et vous faites partie des premiers testeurs ! Merci de votre confiance.',
        type: 'welcome',
        createdAt: now.subtract(const Duration(minutes: 2)),
      ),
      AppNotification(
        id: 'welcome_5',
        title: '💡 Info pratique',
        message: 'Rappel : Vous pouvez acheter, vendre, déposer et retirer vos cryptos en toute simplicité via Mobile Money.',
        type: 'welcome',
        createdAt: now.subtract(const Duration(minutes: 1)),
      ),
    ];
  }

  Future<List<AppNotification>> _generateContextualNotifications() async {
    final notifications = <AppNotification>[];
    final now = DateTime.now();
    
    try {
      // Vérifier les prix des cryptos pour les notifications contextuelles
      final coins = await CoinGeckoService.fetchCoinsByIds(['bitcoin', 'ethereum', 'binancecoin', 'solana']);
      
      for (var coin in coins) {
        // Si le prix a baissé de plus de 2% dans les dernières 24h, c'est une bonne opportunité
        if (coin.priceChangePct24h < -2.0) {
          // Messages variés avec langage ivoirien familier
          final messages = [
            'Hé boss, le prix de ${coin.name} est doux en ce moment 🔥, c\'est le bon moment pour acheter ! Ne rate pas cette occasion.',
            'Walahi, ${coin.name} est en promo là ! Le prix a baissé, c\'est le moment parfait pour investir 💰',
            'Eh mon frère, ${coin.name} est à bon prix maintenant ! C\'est l\'occasion d\'acheter avant que ça remonte 📈',
            'Boss, ${coin.name} est en baisse, c\'est le bon moment ! Profite de cette opportunité pour faire du gain 🚀',
            'Hé mon pote, le prix de ${coin.name} est doux là ! C\'est le moment idéal pour acheter et faire du profit 💎',
            'Mon cher, ${coin.name} est à prix réduit ! C\'est le moment de saisir l\'opportunité et d\'acheter maintenant 🎯',
            'Eh boss, ${coin.name} est en chute libre ! C\'est le bon moment pour acheter avant la remontée 💪',
          ];
          final random = Random();
          final message = messages[random.nextInt(messages.length)];
          
          notifications.add(AppNotification(
            id: 'contextual_${coin.id}_${now.millisecondsSinceEpoch}',
            title: '🔥 Opportunité d\'achat !',
            message: message,
            type: 'contextual',
            createdAt: now,
            actionUrl: 'buy_${coin.id}',
          ));
        }
      }
    } catch (e) {
      debugPrint("Erreur génération notifications contextuelles: $e");
    }
    
    return notifications;
  }

  void _handleNotificationTap(AppNotification notification) {
    if (notification.actionUrl != null) {
      if (notification.actionUrl == 'buy') {
        // Rediriger vers l'achat
        _navigateToBuy();
      } else if (notification.actionUrl == 'profile') {
        // Rediriger vers le profil
        Navigator.pop(context);
        // TODO: Naviguer vers la page de profil
      } else if (notification.actionUrl == 'referral') {
        // Afficher le code de parrainage
        _showReferralCode();
      } else if (notification.actionUrl!.startsWith('buy_')) {
        // Acheter une crypto spécifique
        final coinId = notification.actionUrl!.replaceFirst('buy_', '');
        _navigateToBuySpecificCoin(coinId);
      }
    }
  }

  Future<void> _navigateToBuy() async {
    try {
      final coins = await CoinGeckoService.fetchCoinsByIds(['bitcoin']);
      if (coins.isNotEmpty) {
        final coin = coins[0];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BuySellScreen(
              isBuying: true,
              coinName: coin.name,
              coinSymbol: coin.symbol,
              coinPrice: coin.currentPrice * 600,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Erreur navigation achat: $e");
    }
  }

  Future<void> _navigateToBuySpecificCoin(String coinId) async {
    try {
      final coins = await CoinGeckoService.fetchCoinsByIds([coinId]);
      if (coins.isNotEmpty) {
        final coin = coins[0];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BuySellScreen(
              isBuying: true,
              coinName: coin.name,
              coinSymbol: coin.symbol,
              coinPrice: coin.currentPrice * 600,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Erreur navigation achat crypto spécifique: $e");
    }
  }

  void _showReferralCode() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Code de parrainage', style: AppTextStyles.heading2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Votre code de parrainage',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'MC2024-XXXXX',
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 24,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Partagez ce code avec vos amis et gagnez des bonus !',
              style: AppTextStyles.bodyFaded,
              textAlign: TextAlign.center,
            ),
          ],
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
        title: Text('Notifications', style: AppTextStyles.heading2),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _notifications = [];
                });
              },
              child: Text(
                'Tout effacer',
                style: AppTextStyles.link.copyWith(
                  color: AppColors.primaryRed,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: AppColors.textFaded),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune notification',
                        style: AppTextStyles.heading2.copyWith(color: AppColors.textFaded),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vous serez notifié des nouvelles opportunités',
                        style: AppTextStyles.bodyFaded,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationCard(notification);
                  },
                ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead ? Colors.transparent : AppColors.primaryGreen,
          width: notification.isRead ? 0 : 2,
        ),
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTextStyles.heading2.copyWith(
                        fontSize: 16,
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textFaded,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(notification.createdAt),
                      style: AppTextStyles.bodyFaded.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'welcome':
        return AppColors.primaryGreen;
      case 'contextual':
        return Colors.orange;
      default:
        return AppColors.textFaded;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'welcome':
        return Icons.celebration;
      case 'contextual':
        return Icons.trending_up;
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return 'Il y a ${difference.inDays} j';
    }
  }
}

