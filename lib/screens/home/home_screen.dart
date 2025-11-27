import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/utils/app_theme.dart';
import '/screens/market/market_screen.dart';
import '/screens/home/transactions_screen.dart';
import '/screens/home/settings_screen.dart';
import '/services/coingecko_service.dart';
import '/models/coin.dart';
import '/screens/transactions/buy_sell_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _userFullName;
  double _balance = 0.0;
  List<Coin> _watchlistCoins = [];
  bool _loadingWatchlist = true;

  // Liste des écrans de la barre de navigation
  final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(), // Index 0: Accueil
    const MarketScreen(), // Index 1: Marché
    const TransactionsScreen(), // Index 2: Historique/Reçus
    const SettingsScreen(), // Index 3: Paramètres
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadWatchlist();
  }

  Future<void> _fetchUserData() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId != null) {
        final data = await supabase
            .from('Users')
            .select('first_name, last_name')
            .eq('id', userId)
            .single();
        
      setState(() {
        final firstName = data['first_name'] ?? '';
        final lastName = data['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        _userFullName = fullName.isEmpty ? 'Utilisateur' : fullName;
      });
    } else {
      setState(() {
        _userFullName = 'Utilisateur';
      });
    }
    } catch (e) {
      // En cas d'erreur, charger depuis SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString("userName");
      setState(() {
        _userFullName = savedName ?? 'Utilisateur';
      });
    }
  }

  Future<void> _loadWatchlist() async {
    try {
      // Charger Bitcoin et Binance Coin par défaut
      final coins = await CoinGeckoService.fetchCoinsByIds(['bitcoin', 'binancecoin']);
      setState(() {
        _watchlistCoins = coins;
        _loadingWatchlist = false;
      });
    } catch (e) {
      setState(() {
        _loadingWatchlist = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // Si l'index est 0, on affiche le contenu de l'accueil
    if (_selectedIndex == 0) {
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
                  // --- HEADER AVEC AVATAR ET NOTIFICATION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Avatar et nom
                      Row(
                        children: [
                          // Avatar circulaire
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.text,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AKWABA',
                                style: AppTextStyles.bodyFaded.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _userFullName ?? 'Utilisateur',
                                style: AppTextStyles.heading2.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Bouton Notification
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notifications_none,
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Notification',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // --- CARTE SOLDE AVEC DÉGRADÉ VERT ---
                  Stack(
                    children: [
                      // Carte avec dégradé vert et motif de vague
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF10B981),
                              Color(0xFF059669),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          children: [
                            // Contenu principal
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Solde actuel',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '=00.0',
                                          style: AppTextStyles.heading1.copyWith(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'XOF',
                                      style: AppTextStyles.heading1.copyWith(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Motif de vague en bas
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: CustomPaint(
                                size: const Size(double.infinity, 40),
                                painter: WavePainter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Conteneur blanc qui chevauche le bas de la carte
                      Positioned(
                        bottom: -30,
                        left: 0,
                        right: 0,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Bouton Depot
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // TODO: Implémenter le dépôt
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_downward,
                                          color: AppColors.primaryGreen,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Depot',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Ligne verticale
                              Container(
                                width: 1,
                                height: 50,
                                color: Colors.grey[300],
                              ),
                              // Bouton Retraits
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // TODO: Implémenter le retrait
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryRed.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_upward,
                                          color: AppColors.primaryRed,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Retraits',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
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
                  ),
                  const SizedBox(height: 50),
                  
                  // --- BOUTONS D'ACTION RAPIDE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Acheter',
                        onTap: () {
                          if (_watchlistCoins.isNotEmpty) {
                            final coin = _watchlistCoins[0];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BuySellScreen(
                                  isBuying: true,
                                  coinName: coin.name,
                                  coinSymbol: coin.symbol,
                                  coinPrice: coin.currentPrice,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      _buildQuickActionButton(
                        icon: Icons.call_received,
                        label: 'Recevoir',
                        onTap: () {
                          // TODO: Implémenter recevoir
                        },
                      ),
                      _buildQuickActionButton(
                        icon: Icons.send,
                        label: 'Envoyer',
                        onTap: () {
                          // TODO: Implémenter envoyer
                        },
                      ),
                      _buildQuickActionButton(
                        icon: Icons.swap_horiz,
                        label: 'Vendre',
                        onTap: () {
                          if (_watchlistCoins.isNotEmpty) {
                            final coin = _watchlistCoins[0];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BuySellScreen(
                                  isBuying: false,
                                  coinName: coin.name,
                                  coinSymbol: coin.symbol,
                                  coinPrice: coin.currentPrice,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // --- SECTION WATCHLIST ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Watchlist',
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: 24,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add,
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Ajouter',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 14,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // --- CARTES DE CRYPTOMONNAIES ---
                  if (_loadingWatchlist)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Row(
                      children: _watchlistCoins.map((coin) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                              right: coin == _watchlistCoins.first
                                  ? 8
                                  : 0,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icône de la crypto
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.orange.withOpacity(0.2),
                                  child: coin.image.isNotEmpty
                                      ? ClipOval(
                                          child: Image.network(
                                            coin.image,
                                            width: 40,
                                            height: 40,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.currency_bitcoin,
                                                color: Colors.orange,
                                                size: 24,
                                              );
                                            },
                                          ),
                                        )
                                      : const Icon(
                                          Icons.currency_bitcoin,
                                          color: Colors.orange,
                                          size: 24,
                                        ),
                                ),
                                const SizedBox(height: 12),
                                // Nom de la crypto
                                Text(
                                  coin.name,
                                  style: AppTextStyles.heading2.copyWith(
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  coin.symbol.toUpperCase(),
                                  style: AppTextStyles.bodyFaded.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Prix
                                Text(
                                  '\$ ${coin.currentPrice.toStringAsFixed(2)}',
                                  style: AppTextStyles.heading2.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Variation
                                Row(
                                  children: [
                                    Icon(
                                      coin.priceChangePct24h >= 0
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      size: 14,
                                      color: coin.priceChangePct24h >= 0
                                          ? AppColors.primaryGreen
                                          : AppColors.primaryRed,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${coin.priceChangePct24h >= 0 ? '+' : ''}${coin.priceChangePct24h.toStringAsFixed(2)}%',
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 12,
                                        color: coin.priceChangePct24h >= 0
                                            ? AppColors.primaryGreen
                                            : AppColors.primaryRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Espace flexible pour pousser le contenu vers le haut
                    const Spacer(),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      );
    }

    // Si l'index n'est pas 0 (Accueil), on affiche l'écran sélectionné
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Widget pour les boutons d'action rapide
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.textFaded,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodyFaded.copyWith(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour la barre de navigation inférieure
  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Index 0: Home
            _buildNavItem(
              index: 0,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'Home',
            ),
            // Index 1: Market
            _buildNavItem(
              index: 1,
              icon: Icons.currency_bitcoin,
              selectedIcon: Icons.currency_bitcoin,
              label: 'Marche',
            ),
            // Index 2: Historique
            _buildNavItem(
              index: 2,
              icon: Icons.receipt_long_outlined,
              selectedIcon: Icons.receipt_long,
              label: 'Historique',
            ),
            // Index 3: Profile
            _buildNavItem(
              index: 3,
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: isSelected ? 10 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? selectedIcon : icon,
                key: ValueKey('$index-$isSelected'),
                color: isSelected ? Colors.black87 : AppColors.textFaded,
                size: isSelected ? 20 : 24,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- CONTENU PRINCIPAL DE L'ACCUEIL ---
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Peintre pour le motif de vague sur la carte de solde
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF047857).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.3,
      size.width * 0.5,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.5,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
