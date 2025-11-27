import 'package:flutter/material.dart';
import '/utils/app_theme.dart';
import '/services/coingecko_service.dart';
import '/models/coin.dart';
import '/screens/transactions/buy_sell_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _selectedCategory = 'Coins';
  String _searchQuery = '';
  List<Coin> _allCoins = [];
  List<Coin> _filteredCoins = [];
  bool _loading = true;

  // Valeurs minimales de vente par crypto (en symboles)
  final Map<String, double> _minSellAmounts = {
    'bitcoin': 5.0,
    'ethereum': 3.0,
    'tether': 2.0,
    'ripple': 5.0,
    'binancecoin': 5.0,
    'usd-coin': 5.0,
  };

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    try {
      // Charger les principales cryptomonnaies
      final coins = await CoinGeckoService.fetchCoinsByIds([
        'bitcoin',
        'ethereum',
        'tether',
        'ripple',
        'binancecoin',
        'usd-coin',
      ]);
      setState(() {
        _allCoins = coins;
        _filteredCoins = coins;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _filterCoins() {
    setState(() {
      _filteredCoins = _allCoins.where((coin) {
        final matchesSearch = _searchQuery.isEmpty ||
            coin.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            coin.symbol.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
            // --- BARRE DE RECHERCHE ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          hintText: 'Rechercher une pièce',
                          hintStyle: AppTextStyles.bodyFaded.copyWith(
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          _searchQuery = value;
                          _filterCoins();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- FILTRES DE CATÉGORIES ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildCategoryButton('Coins', _selectedCategory == 'Coins'),
                  const SizedBox(width: 8),
                  _buildCategoryButton('Stablecoins', _selectedCategory == 'Stablecoins'),
                  const SizedBox(width: 8),
                  _buildCategoryButton('Tokens DeFi', _selectedCategory == 'Tokens DeFi'),
                  const SizedBox(width: 8),
                  _buildCategoryButton('NFT', _selectedCategory == 'NFT'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- LISTE DES CRYPTOMONNAIES ---
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCoins.isEmpty
                      ? Center(
                          child: Text(
                            'Aucune cryptomonnaie trouvée',
                            style: AppTextStyles.bodyFaded,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredCoins.length,
                          itemBuilder: (context, index) {
                            final coin = _filteredCoins[index];
                            final minSell = _minSellAmounts[coin.id.toLowerCase()] ?? 5.0;
                            
                            return _buildCoinCard(coin, minSell);
                          },
                        ),
            ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : AppColors.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              color: isSelected ? Colors.white : AppColors.text,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoinCard(Coin coin, double minSell) {
    return GestureDetector(
      onTap: () {
        // Convertir le prix USD en XOF (approximativement 1 USD = 600 XOF)
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icône de la crypto
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              child: coin.image.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        coin.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getCoinColor(coin.symbol),
                            ),
                            child: Center(
                              child: Text(
                                coin.symbol.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getCoinColor(coin.symbol),
                      ),
                      child: Center(
                        child: Text(
                          coin.symbol.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            
            // Nom et symbole
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name,
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coin.symbol.toUpperCase(),
                    style: AppTextStyles.bodyFaded.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Min Vente et Min Achat
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Min Vente : ${minSell.toStringAsFixed(0)} ${coin.symbol.toUpperCase()}',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: AppColors.primaryRed,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Min Achat : 2500 XOF',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCoinColor(String symbol) {
    switch (symbol.toLowerCase()) {
      case 'btc':
        return Colors.orange;
      case 'eth':
        return Colors.purple;
      case 'usdt':
        return Colors.green;
      case 'xrp':
        return Colors.black;
      case 'bnb':
        return Colors.yellow.shade700;
      case 'usdc':
        return Colors.blue.shade700;
      default:
        return AppColors.primaryGreen;
    }
  }
}
