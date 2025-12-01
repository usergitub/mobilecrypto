import 'package:flutter/material.dart';
import '/utils/app_theme.dart';
import '../../services/coingecko_service.dart';
import '../../models/coin.dart';
import '../transactions/buy_sell_screen.dart';

class AllCoinsScreen extends StatefulWidget {
  const AllCoinsScreen({super.key});
  @override
  State<AllCoinsScreen> createState() => _AllCoinsScreenState();
}

class _AllCoinsScreenState extends State<AllCoinsScreen> {
  int _page = 1;
  final int _perPage = 30;
  bool _loading = false;
  final List<Coin> _coins = [];

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading) return;
    setState(() => _loading = true);

    final fetched = await CoinGeckoService.fetchTopCoins(
      perPage: _perPage,
      page: _page,
    );

    setState(() {
      _coins.addAll(fetched);
      _page++;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: const Text(
          'Toutes les cryptos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: _coins.length + 1,
        itemBuilder: (c, i) {
          if (i == _coins.length) {
            _loadMore();
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final coin = _coins[i];
          final isPos = coin.priceChangePct24h >= 0;

          return ListTile(
            onTap: () {
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
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage(coin.image),
            ),
            title: Text(coin.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              coin.symbol.toUpperCase(),
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$${coin.currentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  '${isPos ? '+' : ''}${coin.priceChangePct24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: isPos ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

