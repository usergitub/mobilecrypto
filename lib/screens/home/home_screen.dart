import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '/utils/app_theme.dart';
import '/utils/responsive_helper.dart';
import '/services/coingecko_service.dart';
import '/models/coin.dart';

// Écrans de navigation
import '/screens/market/market_screen.dart';
import '/screens/home/transactions_screen.dart';
import '/screens/home/profile_screen.dart';
import '/screens/home/notifications_screen.dart';
import '/screens/transactions/buy_sell_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<_HomeContentState> _homeContentKey = GlobalKey<_HomeContentState>();

  // Liste des écrans
  List<Widget> get _screens => [
    HomeContent(key: _homeContentKey),
    const MarketScreen(),
    const TransactionsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false, // On gère le bas nous-mêmes pour la navbar flottante
        child: Stack(
          children: [
            // Contenu principal
            Positioned.fill(
              child: _screens[_selectedIndex],
            ),
            
            // Barre de navigation Flottante (Style Pillule)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF15232F), // Couleur sombre de la navbar
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(0, Icons.home_filled, "Home"),
                    _buildNavItem(1, Icons.currency_bitcoin, "Marché"),
                    _buildNavItem(2, Icons.receipt_long, "Reçus"),
                    _buildNavItem(3, Icons.person, "Profil"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        // Recharger les données si on revient sur la page d'accueil
        if (index == 0 && _homeContentKey.currentState != null) {
          _homeContentKey.currentState!._reloadData();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isSelected 
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
            : const EdgeInsets.all(10),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : AppColors.textFaded,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SpaceGrotesk',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _userFullName = "Utilisateur";
  List<Coin> _watchlistCoins = [];
  List<Coin> _availableCoins = []; // Liste de toutes les monnaies disponibles
  bool _loading = true;
  Timer? _timer;
  int _unreadNotificationsCount = 0;
  bool _isOffline = false;
  
  // IDs des monnaies disponibles pour la watchlist
  final List<String> _availableCoinIds = [
    'bitcoin',
    'ethereum',
    'tether',
    'ripple',
    'binancecoin',
    'usd-coin',
    'cardano',
    'solana',
  ];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _fetchUserData();
    _loadData();
    _checkNotifications();
    // Lance l'animation des prix
    _startLiveSimulation();
    // Vérifier les notifications contextuelles périodiquement
    _startContextualNotificationsCheck();
    // Vérifier la connexion périodiquement
    _startConnectivityCheck();
  }
  
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = !connectivityResult.contains(ConnectivityResult.none);
      if (mounted) {
        setState(() {
          _isOffline = !isOnline;
        });
      }
    } catch (e) {
      debugPrint("Erreur vérification connexion: $e");
    }
  }
  
  void _startConnectivityCheck() {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _checkConnectivity();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Simule les prix qui bougent toutes les 2 secondes
  void _startLiveSimulation() {
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      if (mounted && _watchlistCoins.isNotEmpty) {
        setState(() {
          // On modifie légèrement les prix et pourcentages pour l'effet "Live"
          for (var _ in _watchlistCoins) {
            final random = Random();
            final _ = (random.nextDouble() * 2 - 1) * 0.05; // +/- variation
            // On ne modifie pas l'objet Coin directement car il est final, 
            // mais dans une vraie app on aurait un Stream.
            // Ici, on force juste le rafraîchissement de l'UI avec setState
            // Pour voir l'effet visuel, on pourrait copier l'objet, mais gardons simple.
          }
        });
      }
    });
  }

  Future<void> _fetchUserData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user != null) {
        final data = await supabase.from('Users').select().eq('id', user.id).maybeSingle();
        if (data != null) {
      setState(() {
            _userFullName = "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}".trim();
            if (_userFullName.isEmpty) _userFullName = "Utilisateur";
      });
        }
      }
    } catch (e) {
      debugPrint("Erreur User: $e");
    }
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Charger la watchlist sauvegardée
      final savedWatchlistIds = prefs.getStringList('watchlist_coin_ids');
      
      List<String> coinIdsToLoad;
      if (savedWatchlistIds != null && savedWatchlistIds.isNotEmpty) {
        // Utiliser la watchlist sauvegardée
        coinIdsToLoad = savedWatchlistIds;
      } else {
        // Utiliser les 2 monnaies par défaut (Bitcoin et Binance Coin)
        coinIdsToLoad = ['bitcoin', 'binancecoin'];
      }
      
      // Charger les monnaies de la watchlist (avec support offline)
      List<Coin> watchlistCoins = [];
      try {
        watchlistCoins = await CoinGeckoService.fetchCoinsByIds(coinIdsToLoad);
      } catch (e) {
        debugPrint("⚠️ Erreur chargement watchlist: $e - Mode offline possible");
        // En mode offline, on peut avoir une liste vide ou partielle
      }
      
      // Charger toutes les monnaies disponibles (avec support offline)
      List<Coin> allCoins = [];
      try {
        allCoins = await CoinGeckoService.fetchCoinsByIds(_availableCoinIds);
      } catch (e) {
        debugPrint("⚠️ Erreur chargement monnaies disponibles: $e - Mode offline possible");
        // En mode offline, utiliser au moins la watchlist
        if (allCoins.isEmpty && watchlistCoins.isNotEmpty) {
          allCoins = watchlistCoins;
        }
      }
      
      if (mounted) {
        setState(() {
          _watchlistCoins = watchlistCoins;
          _availableCoins = allCoins.isNotEmpty ? allCoins : watchlistCoins;
          _loading = false;
        });
        debugPrint("📱 Watchlist chargée: ${watchlistCoins.length} monnaies (${coinIdsToLoad.join(', ')})");
      }
    } catch (e) {
      debugPrint("❌ Erreur chargement données: $e");
      if (mounted) setState(() => _loading = false);
    }
  }
  
  Future<void> _saveWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coinIds = _watchlistCoins.map((c) => c.id).toList();
      await prefs.setStringList('watchlist_coin_ids', coinIds);
      debugPrint("✅ Watchlist sauvegardée avec ${coinIds.length} monnaies: $coinIds");
    } catch (e) {
      debugPrint("❌ Erreur sauvegarde watchlist: $e");
    }
  }
  
  // Méthode publique pour recharger les données
  void _reloadData() {
    _loadData();
    _checkNotifications();
  }
  
  Future<void> _checkNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasMadePurchase = prefs.getBool('hasMadePurchase') ?? false;
      
      // Si l'utilisateur est nouveau ou n'a pas fait d'achat, il a 5 notifications
      if (!hasMadePurchase) {
      setState(() {
          _unreadNotificationsCount = 5;
        });
      } else {
        // Vérifier les notifications contextuelles
        await _checkContextualNotifications();
      }
    } catch (e) {
      debugPrint("Erreur vérification notifications: $e");
    }
  }

  Future<void> _checkContextualNotifications() async {
    try {
      // Vérifier les prix des cryptos pour détecter les bonnes opportunités
      if (_watchlistCoins.isEmpty) return;
      
      int contextualCount = 0;
      for (var coin in _watchlistCoins) {
        // Si le prix a baissé de plus de 2%, c'est une opportunité
        if (coin.priceChangePct24h < -2.0) {
          contextualCount++;
        }
      }
      
    if (mounted) {
      setState(() {
          _unreadNotificationsCount = contextualCount;
      });
      }
    } catch (e) {
      debugPrint("Erreur notifications contextuelles: $e");
    }
  }
  
  void _startContextualNotificationsCheck() {
    // Vérifier les notifications contextuelles toutes les 5 minutes
    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        _checkContextualNotifications();
      } else {
        timer.cancel();
    }
    });
  }
  
  // Recharger les données des monnaies de la watchlist
  Future<void> _reloadWatchlistCoins() async {
    try {
      if (_watchlistCoins.isEmpty) return;
      
      final ids = _watchlistCoins.map((c) => c.id).toList();
      final updatedCoins = await CoinGeckoService.fetchCoinsByIds(ids);
      
      if (mounted) {
    setState(() {
          _watchlistCoins = updatedCoins;
    });
      }
    } catch (e) {
      debugPrint("Erreur rechargement watchlist: $e");
    }
  }
  
  void _showDevPopup(String title, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: AppTextStyles.heading2),
        content: Text(
          isError 
            ? "L'API de réception d'argent n'est pas encore obtenue." 
            : "L'application est en cours de développement. Testez et donnez votre avis.",
          style: AppTextStyles.body.copyWith(color: Colors.white70),
        ),
        actions: [
            TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: isError ? AppColors.primaryRed : AppColors.primaryGreen)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPad = ResponsiveHelper.horizontalPadding(context);
    final spacing1 = ResponsiveHelper.spacing(context, 20);
    final spacing2 = ResponsiveHelper.spacing(context, 24);
    final spacing3 = ResponsiveHelper.spacing(context, 32);
    final spacing4 = ResponsiveHelper.spacing(context, 16);
    final bottomSpacing = ResponsiveHelper.spacing(context, 120);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPad),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              children: [
                SizedBox(height: spacing1),
                _buildHeader(context),
                SizedBox(height: spacing2),
                _buildBalanceCard(context),
                SizedBox(height: spacing3),
                _buildQuickActions(context),
                SizedBox(height: spacing3),
                _buildWatchlistHeader(context),
                SizedBox(height: spacing4),
                _buildWatchlist(context),
                SizedBox(height: bottomSpacing), // Espace pour la navbar
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final avatarRadius = ResponsiveHelper.spacing(context, 24);
    final spacing = ResponsiveHelper.spacing(context, 12);
    final fontSizeSmall = ResponsiveHelper.fontSize(context, 10);
    final fontSizeHeading = ResponsiveHelper.fontSize(context, 20);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: AppColors.card,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: ResponsiveHelper.iconSize(context, 20),
              ),
            ),
            SizedBox(width: spacing),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "AKWABA",
                      style: AppTextStyles.bodyFaded.copyWith(
                        fontSize: fontSizeSmall,
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (_isOffline) ...[
                      SizedBox(width: spacing * 0.67),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing * 0.5,
                          vertical: spacing * 0.17,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off,
                              size: fontSizeSmall,
                              color: Colors.orange,
                            ),
                            SizedBox(width: spacing * 0.33),
                            Text(
                              "Hors ligne",
                              style: TextStyle(
                                fontSize: fontSizeSmall * 0.8,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  _userFullName,
                  style: AppTextStyles.heading2.copyWith(fontSize: fontSizeHeading),
                ),
              ],
                    ),
                  ],
                ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            ).then((_) {
              // Recharger le nombre de notifications après retour
              if (mounted) {
                _checkNotifications();
              }
            });
          },
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing,
                  vertical: spacing * 0.67,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: AppColors.primaryGreen,
                      size: ResponsiveHelper.iconSize(context, 18),
                    ),
                    SizedBox(width: spacing * 0.5),
                    Text(
                      "Notification",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.fontSize(context, 12),
                      ),
                    ),
                  ],
                ),
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadNotificationsCount > 9 ? '9+' : '$_unreadNotificationsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final cardHeight = ResponsiveHelper.cardHeight(context, 20);
    final buttonHeight = ResponsiveHelper.spacing(context, 64);
    final buttonWidth = ResponsiveHelper.getWidth(context, 60);
    final bottomMargin = ResponsiveHelper.spacing(context, 30);
    final padding = ResponsiveHelper.spacing(context, 24);
    final fontSizeBalance = ResponsiveHelper.fontSize(context, 32);
    final fontSizeLabel = ResponsiveHelper.fontSize(context, 16);
    final fontSizeButton = ResponsiveHelper.fontSize(context, 12);
    final iconSize = ResponsiveHelper.iconSize(context, 20);
    
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Carte Verte
        Container(
          margin: EdgeInsets.only(bottom: bottomMargin),
          width: double.infinity,
          height: cardHeight,
                  decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
                      ),
                    ],
                  ),
          child: Stack(
            children: [
              // Motif vagues fond
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Opacity(
                  opacity: 0.1, 
                  child: Image.network("https://i.imgur.com/K7A8v3r.png", fit: BoxFit.cover, height: 80, errorBuilder: (_,__,___)=>const SizedBox()),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Solde actuel",
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: fontSizeLabel,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.spacing(context, 8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "=00.0",
                          style: TextStyle(
                            fontSize: fontSizeBalance,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'SpaceGrotesk',
                          ),
                        ),
                        Text(
                          "XOF",
                          style: AppTextStyles.heading1.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Boutons Flottants (Dépôt / Retrait)
        Positioned(
          bottom: 0,
          child: Container(
            width: buttonWidth,
            height: buttonHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, ResponsiveHelper.spacing(context, 5)),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _showDevPopup("Dépôt"),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          color: AppColors.primaryGreen,
                          size: iconSize,
                        ),
                        Text(
                          "Depot",
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSizeButton,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: buttonHeight * 0.47,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _showDevPopup("Retraits"),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          color: AppColors.primaryRed,
                          size: iconSize,
                        ),
                        Text(
                          "Retraits",
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSizeButton,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionBtn(context, Icons.account_balance_wallet_outlined, "Acheter", () {
          if (_watchlistCoins.isNotEmpty) {
            final coin = _watchlistCoins[0];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BuySellScreen(
                  isBuying: true,
                  coinName: coin.name,
                  coinSymbol: coin.symbol,
                  coinPrice: coin.currentPrice * 600, // Conversion USD vers XOF (approximatif)
                ),
              ),
            );
          } else {
            _showDevPopup("Acheter", isError: true);
          }
        }),
        _actionBtn(context, Icons.call_received, "Recevoir", () => _showDevPopup("Recevoir")),
        _actionBtn(context, Icons.send_outlined, "Envoyer", () => _showDevPopup("Envoyer")),
        _actionBtn(context, Icons.swap_horiz, "Vendre", () {
          if (_watchlistCoins.isNotEmpty) {
            final coin = _watchlistCoins[0];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BuySellScreen(
                  isBuying: false,
                  coinName: coin.name,
                  coinSymbol: coin.symbol,
                  coinPrice: coin.currentPrice * 600, // Conversion USD vers XOF (approximatif)
                ),
              ),
            );
          } else {
            _showDevPopup("Vendre", isError: true);
          }
        }),
      ],
    );
  }

  Widget _actionBtn(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final btnSize = ResponsiveHelper.spacing(context, 56);
    final iconSize = ResponsiveHelper.iconSize(context, 24);
    final fontSize = ResponsiveHelper.fontSize(context, 12);
    final spacing = ResponsiveHelper.spacing(context, 8);
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: btnSize,
            height: btnSize,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: Icon(icon, color: Colors.grey, size: iconSize),
          ),
          SizedBox(height: spacing),
          Text(
            label,
            style: AppTextStyles.bodyFaded.copyWith(fontSize: fontSize),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistHeader(BuildContext context) {
    final isModifyMode = _watchlistCoins.length >= 3;
    final buttonText = isModifyMode ? "Modifier" : "Ajouter";
    final buttonIcon = isModifyMode ? Icons.edit : Icons.add;
    final fontSizeHeading = ResponsiveHelper.fontSize(context, 20);
    final fontSizeButton = ResponsiveHelper.fontSize(context, 12);
    final iconSize = ResponsiveHelper.iconSize(context, 16);
    final padding = ResponsiveHelper.spacing(context, 12);
    final spacing = ResponsiveHelper.spacing(context, 4);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Watchlist",
          style: AppTextStyles.heading2.copyWith(fontSize: fontSizeHeading),
        ),
        GestureDetector(
          onTap: () => _showWatchlistManager(),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: padding * 0.5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D3B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(buttonIcon, color: AppColors.textFaded, size: iconSize),
                SizedBox(width: spacing),
                Text(
                  buttonText,
                  style: TextStyle(
                    color: AppColors.textFaded,
                    fontSize: fontSizeButton,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showWatchlistManager() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textFaded.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _watchlistCoins.length >= 3 ? "Modifier la Watchlist" : "Ajouter des monnaies",
                    style: AppTextStyles.heading2,
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Afficher les monnaies actuelles avec option de retirer
                      if (_watchlistCoins.isNotEmpty) ...[
                        Text(
                          "Monnaies actuelles (${_watchlistCoins.length}/4)",
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textFaded,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._watchlistCoins.map((coin) {
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
                                ClipOval(
                                  child: Image.network(
                                    coin.image,
                                    width: 40,
                                    height: 40,
                                    errorBuilder: (_, __, ___) => Container(
            width: 40,
            height: 40,
                                      color: AppColors.card,
                                      child: const Icon(Icons.currency_bitcoin, color: Colors.orange),
                                    ),
                                  ),
          ),
                                const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                                      Text(coin.name, style: AppTextStyles.heading2.copyWith(fontSize: 16)),
                                      Text(
                                        coin.symbol.toUpperCase(),
                                        style: AppTextStyles.bodyFaded.copyWith(fontSize: 12),
                                      ),
              ],
            ),
          ),
                                if (_watchlistCoins.length > 2) // Permettre de retirer seulement si on a plus de 2
                                  IconButton(
                                    icon: Icon(Icons.close, color: AppColors.primaryRed),
                                    onPressed: () async {
                                      setState(() {
                                        _watchlistCoins.remove(coin);
                                      });
                                      await _saveWatchlist();
                                      _reloadWatchlistCoins();
                                      if (_watchlistCoins.length < 2) {
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      }
                                    },
          ),
        ],
      ),
    );
                        }),
                        const SizedBox(height: 24),
                      ],
                      
                      // Afficher les monnaies disponibles à ajouter
                      if (_watchlistCoins.length < 4) ...[
                        Text(
                          "Monnaies disponibles",
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textFaded,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._availableCoins.where((coin) {
                          // Ne pas afficher les monnaies déjà dans la watchlist
                          return !_watchlistCoins.any((c) => c.id == coin.id);
                        }).map((coin) {
                          return GestureDetector(
                            onTap: () async {
                              if (_watchlistCoins.length < 4) {
                                setState(() {
                                  _watchlistCoins.add(coin);
                                });
                                await _saveWatchlist();
                                _reloadWatchlistCoins();
                                if (_watchlistCoins.length >= 4) {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Row(
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      coin.image,
                                      width: 40,
                                      height: 40,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 40,
                                        height: 40,
                                        color: AppColors.card,
                                        child: const Icon(Icons.currency_bitcoin, color: Colors.orange),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(coin.name, style: AppTextStyles.heading2.copyWith(fontSize: 16)),
                                        Text(
                                          coin.symbol.toUpperCase(),
                                          style: AppTextStyles.bodyFaded.copyWith(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: AppColors.primaryGreen,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ] else
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "Vous avez atteint la limite de 4 monnaies. Retirez-en une pour en ajouter une autre.",
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textFaded,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWatchlist(BuildContext context) {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }
    if (_watchlistCoins.isEmpty) {
      return Center(
        child: Text(
          "Erreur chargement",
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.fontSize(context, 16),
          ),
        ),
      );
    }

    // Créer une grille 2x2 symétrique
    final firstTwoCoins = _watchlistCoins.take(2).toList();
    final lastTwoCoins = _watchlistCoins.skip(2).take(2).toList();
    final cardPadding = ResponsiveHelper.spacing(context, 16);
    final cardSpacing = ResponsiveHelper.spacing(context, 8);
    final rowSpacing = ResponsiveHelper.spacing(context, 16);
    final fontSizeName = ResponsiveHelper.fontSize(context, 14);
    final fontSizePrice = ResponsiveHelper.fontSize(context, 16);
    final fontSizePercent = ResponsiveHelper.fontSize(context, 12);
    final logoSize = ResponsiveHelper.spacing(context, 24);

    // Widget réutilisable pour une carte de monnaie
    Widget buildCoinCard(Coin coin) {
      return GestureDetector(
        onTap: () {
          // Rediriger vers la page d'achat
          final priceInXOF = coin.currentPrice * 600;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BuySellScreen(
                isBuying: true,
                coinName: coin.name,
                coinSymbol: coin.symbol,
                coinPrice: priceInXOF,
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                padding: EdgeInsets.all(ResponsiveHelper.spacing(context, 4)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12),
                ),
                child: Image.network(
                  coin.image,
                  width: logoSize,
                  height: logoSize,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.currency_bitcoin,
                    color: Colors.orange,
                    size: logoSize,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(context, 12)),
              Text(
                coin.name,
                style: AppTextStyles.heading2.copyWith(fontSize: fontSizeName),
              ),
              Text(
                coin.symbol.toUpperCase(),
                style: AppTextStyles.bodyFaded.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.fontSize(context, 12),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(context, 20)),
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$ ${coin.currentPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizePrice,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.spacing(context, 4)),
                    // Pourcentage coloré
                    Text(
                      "${coin.priceChangePct24h >= 0 ? '+' : ''}${coin.priceChangePct24h.toStringAsFixed(2)}%",
                      style: TextStyle(
                        color: coin.priceChangePct24h >= 0
                            ? AppColors.primaryGreen
                            : AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizePercent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Première ligne : 2 premières monnaies
        Row(
          children: firstTwoCoins.asMap().entries.map((entry) {
            final index = entry.key;
            final coin = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == 0 ? cardSpacing : 0,
                  left: index == 1 ? cardSpacing : 0,
                ),
                child: buildCoinCard(coin),
              ),
            );
          }).toList(),
        ),
        
        // Deuxième ligne : 2 dernières monnaies (si elles existent)
        if (lastTwoCoins.isNotEmpty) ...[
          SizedBox(height: rowSpacing),
          Row(
            children: lastTwoCoins.asMap().entries.map((entry) {
              final index = entry.key;
              final coin = entry.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == 0 ? cardSpacing : 0,
                    left: index == 1 ? cardSpacing : 0,
                  ),
                  child: buildCoinCard(coin),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}