import 'package:flutter/material.dart';
import '../services/coingecko_service.dart';
import '../models/coin.dart';
import '../screens/market/all_coins_screen.dart'; // page "Voir tous"

class TopMoversWidget extends StatefulWidget {
  final int count;
  const TopMoversWidget({super.key, this.count = 4});

  @override
  State<TopMoversWidget> createState() => _TopMoversWidgetState();
}

class _TopMoversWidgetState extends State<TopMoversWidget> {
  late Future<List<Coin>> _future;

  @override
  void initState() {
    super.initState();
    _future = CoinGeckoService.fetchTopCoins(perPage: widget.count);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("En pleine hausse", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AllCoinsScreen()));
              },
              child: const Text("Voir tous"),
            )
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Coin>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }
            if (snap.hasError) {
              return Text('Erreur: ${snap.error}');
            }
            final coins = snap.data ?? [];
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: coins.map((c) {
                final isPos = c.priceChangePct24h >= 0;
                return Column(
                  children: [
                    CircleAvatar(backgroundImage: NetworkImage(c.image), radius: 24, backgroundColor: Colors.transparent),
                    const SizedBox(height: 8),
                    Text('${isPos ? '+' : ''}${c.priceChangePct24h.toStringAsFixed(2)}%', style: TextStyle(color: isPos ? Colors.green : Colors.red)),
                    const SizedBox(height: 4),
                    Text('\$${c.currentPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                  ],
                );
              }).toList(),
            );
          },
        )
      ],
    );
  }
}
