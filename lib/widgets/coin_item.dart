import 'package:flutter/material.dart';
import '../models/coin.dart';

// Un widget pour afficher les informations de base d'une seule crypto-monnaie
class CoinItem extends StatelessWidget {
  final Coin coin;

  const CoinItem({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    // Déterminer la couleur en fonction du pourcentage de changement
    final Color priceColor = coin.priceChangePct24h >= 0
        ? Colors.green
        : Colors.red;

    // Formatter le pourcentage avec un signe +/-
    final String changeText = coin.priceChangePct24h >= 0
        ? '+${coin.priceChangePct24h.toStringAsFixed(2)}%'
        : '${coin.priceChangePct24h.toStringAsFixed(2)}%';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Logo de la crypto
          ClipOval(
            child: Image.network(
              coin.image,
              width: 36,
              height: 36,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.currency_bitcoin, size: 36, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          // 2. Nom et Symbole
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coin.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  coin.symbol.toUpperCase(),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          // 3. Prix et Changement 24h
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                // Formatage simple pour le prix en USD
                '\$${coin.currentPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                changeText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: priceColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}