import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/utils/app_theme.dart';
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

  // Liste des écrans
  final List<Widget> _screens = [
    const HomeContent(),
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
                      color: Colors.black.withOpacity(0.4),
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
    _fetchUserData();
    _loadData();
    _checkNotifications();
    // Lance l'animation des prix
    _startLiveSimulation();
    // Vérifier les notifications contextuelles périodiquement
    _startContextualNotificationsCheck();
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
      // Charger les 2 monnaies par défaut (Bitcoin et Binance Coin)
      final defaultCoins = await CoinGeckoService.fetchCoinsByIds(['bitcoin', 'binancecoin']);
      
      // Charger toutes les monnaies disponibles
      final allCoins = await CoinGeckoService.fetchCoinsByIds(_availableCoinIds);
      
      if (mounted) {
        setState(() {
          _watchlistCoins = defaultCoins;
          _availableCoins = allCoins;
          _loading = false;
      });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 20),
        _buildHeader(),
        const SizedBox(height: 24),
        _buildBalanceCard(),
        const SizedBox(height: 32),
        _buildQuickActions(),
        const SizedBox(height: 32),
        _buildWatchlistHeader(),
        const SizedBox(height: 16),
        _buildWatchlist(),
        const SizedBox(height: 120), // Espace pour la navbar
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.card,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AKWABA", style: AppTextStyles.bodyFaded.copyWith(fontSize: 10, letterSpacing: 1.5)),
                Text(_userFullName, style: AppTextStyles.heading2),
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
              _checkNotifications();
            });
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.notifications_none, color: AppColors.primaryGreen, size: 18),
                    SizedBox(width: 6),
                    Text("Notification", style: TextStyle(color: Colors.white, fontSize: 12)),
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

  Widget _buildBalanceCard() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Carte Verte
                Container(
          margin: const EdgeInsets.only(bottom: 30),
          width: double.infinity,
          height: 160,
                  decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.3),
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
                padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text("Solde actuel", style: AppTextStyles.body.copyWith(color: Colors.white.withOpacity(0.9))),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        const Text("=00.0", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'SpaceGrotesk')),
                        Text("XOF", style: AppTextStyles.heading1.copyWith(color: Colors.white.withOpacity(0.9))),
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
            width: 240,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: const Offset(0, 5))],
                    ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _showDevPopup("Dépôt"),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_downward, color: AppColors.primaryGreen, size: 20),
                        Text("Depot", style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.2)),
                Expanded(
                  child: InkWell(
                    onTap: () => _showDevPopup("Retraits"),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_upward, color: AppColors.primaryRed, size: 20),
                        Text("Retraits", style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold, fontSize: 12)),
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

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionBtn(Icons.account_balance_wallet_outlined, "Acheter", () {
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
        _actionBtn(Icons.call_received, "Recevoir", () => _showDevPopup("Recevoir")),
        _actionBtn(Icons.send_outlined, "Envoyer", () => _showDevPopup("Envoyer")),
        _actionBtn(Icons.swap_horiz, "Vendre", () {
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

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: Icon(icon, color: Colors.grey, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.bodyFaded.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildWatchlistHeader() {
    final isModifyMode = _watchlistCoins.length >= 3;
    final buttonText = isModifyMode ? "Modifier" : "Ajouter";
    final buttonIcon = isModifyMode ? Icons.edit : Icons.add;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Watchlist", style: AppTextStyles.heading2),
        GestureDetector(
          onTap: () => _showWatchlistManager(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFF1E2D3B), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Icon(buttonIcon, color: AppColors.textFaded, size: 16),
                const SizedBox(width: 4),
                Text(buttonText, style: TextStyle(color: AppColors.textFaded, fontSize: 12)),
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
                    color: AppColors.textFaded.withOpacity(0.3),
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
                                    onPressed: () {
                                      setState(() {
                                        _watchlistCoins.remove(coin);
                                      });
                                      _reloadWatchlistCoins();
                                      if (_watchlistCoins.length < 2) {
                                        Navigator.pop(context);
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
                            onTap: () {
                              if (_watchlistCoins.length < 4) {
                                setState(() {
                                  _watchlistCoins.add(coin);
                                });
                                _reloadWatchlistCoins();
                                if (_watchlistCoins.length >= 4) {
                                  Navigator.pop(context);
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

  Widget _buildWatchlist() {
    if (_loading) return Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
    if (_watchlistCoins.isEmpty) return const Center(child: Text("Erreur chargement", style: TextStyle(color: Colors.white)));

    // Afficher les 2 premières monnaies côte à côte
    final firstTwoCoins = _watchlistCoins.take(2).toList();
    final remainingCoins = _watchlistCoins.skip(2).toList();

    return Column(
      children: [
        // Les 2 premières monnaies côte à côte
        Row(
          children: firstTwoCoins.map((coin) {
            return Expanded(
              child: GestureDetector(
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
                  margin: EdgeInsets.only(
                    right: coin != firstTwoCoins.last ? 16 : 0,
                  ),
                  padding: const EdgeInsets.all(16),
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
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Image.network(coin.image, width: 24, height: 24, errorBuilder: (_, __, ___) => const Icon(Icons.currency_bitcoin, color: Colors.orange, size: 24)),
                      ),
                      const SizedBox(height: 12),
                      Text(coin.name, style: AppTextStyles.heading2.copyWith(fontSize: 14)),
                      Text(coin.symbol.toUpperCase(), style: AppTextStyles.bodyFaded.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("\$ ${coin.currentPrice.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            // Pourcentage coloré
                            Text(
                              "${coin.priceChangePct24h >= 0 ? '+' : ''}${coin.priceChangePct24h.toStringAsFixed(2)}%",
                              style: TextStyle(
                                color: coin.priceChangePct24h >= 0 ? AppColors.primaryGreen : AppColors.primaryRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
          ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        // Les monnaies supplémentaires (3ème et 4ème) en dessous, scrollable
        if (remainingCoins.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 120, // Hauteur fixe pour la zone scrollable
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: remainingCoins.map((coin) {
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
                    width: MediaQuery.of(context).size.width / 2 - 36, // Largeur pour 2 colonnes avec espacement
                    margin: EdgeInsets.only(
                      right: coin != remainingCoins.last ? 16 : 0,
                    ),
                    padding: const EdgeInsets.all(16),
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
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Image.network(coin.image, width: 24, height: 24, errorBuilder: (_, __, ___) => const Icon(Icons.currency_bitcoin, color: Colors.orange, size: 24)),
                        ),
                        const SizedBox(height: 12),
                        Text(coin.name, style: AppTextStyles.heading2.copyWith(fontSize: 14)),
                        Text(coin.symbol.toUpperCase(), style: AppTextStyles.bodyFaded.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("\$ ${coin.currentPrice.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              // Pourcentage coloré
                              Text(
                                "${coin.priceChangePct24h >= 0 ? '+' : ''}${coin.priceChangePct24h.toStringAsFixed(2)}%",
                                style: TextStyle(
                                  color: coin.priceChangePct24h >= 0 ? AppColors.primaryGreen : AppColors.primaryRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}