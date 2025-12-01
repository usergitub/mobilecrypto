class Coin {
  // Propriétés (champs) que nous allons stocker pour chaque crypto
  final String id;
  final String symbol;
  final String name;
  final String image; // L'URL de l'image (le logo)
  final double currentPrice;
  final double priceChangePct24h; // Pourcentage de changement sur 24h

  // Constructeur pour créer un nouvel objet Coin
  Coin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.priceChangePct24h,
  });

  // Constructeur Factory pour convertir le JSON de l'API en objet Dart (Coin)
  factory Coin.fromJson(Map<String, dynamic> j) {
    // Le '?' et le '?? 0' gèrent les valeurs manquantes ou nulles
    return Coin(
      id: j['id'] ?? '',
      symbol: j['symbol'] ?? '',
      name: j['name'] ?? '',
      image: j['image'] ?? '',
      currentPrice: (j['current_price'] as num? ?? 0).toDouble(),
      priceChangePct24h:
          (j['price_change_percentage_24h'] as num? ?? 0).toDouble(),
    );
  }

  // Convertir en Map pour le cache offline
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'image': image,
      'current_price': currentPrice,
      'price_change_percentage_24h': priceChangePct24h,
    };
  }
}