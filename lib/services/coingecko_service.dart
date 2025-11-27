import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coin.dart'; 

class CoinGeckoService {
  static const _base = 'https://api.coingecko.com/api/v3';

  /// Fetch par liste personnalisée (id exacts)
  static Future<List<Coin>> fetchCoinsByIds(List<String> ids) async {
    final joined = ids.join(',');
    final url = Uri.parse(
      '$_base/coins/markets?vs_currency=usd&ids=$joined&order=market_cap_desc&sparkline=false&price_change_percentage=24h',
    );

    final res = await http.get(url);
    if (res.statusCode != 200) {
      print('CoinGecko error fetching by IDs: ${res.statusCode}');
      throw Exception('Erreur CoinGecko: ${res.statusCode}');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Coin.fromJson(e)).toList();
  }

  /// Fetch général (utilisé pour scroll dans AllCoins)
  static Future<List<Coin>> fetchTopCoins({
    int perPage = 20,
    int page = 1,
  }) async {
    final url = Uri.parse(
      '$_base/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=$perPage&page=$page&sparkline=false&price_change_percentage=24h',
    );

    final res = await http.get(url);

    if (res.statusCode != 200) {
      print('CoinGecko error fetching top coins: ${res.statusCode}');
      throw Exception('Erreur CoinGecko: ${res.statusCode}');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Coin.fromJson(e)).toList();
  }
  
  // Méthode pour l'écran d'accueil (méthode d'instance)
  Future<List<Coin>> fetchCoins() async {
      // ✅ CORRECTION : on appelle la méthode STATIQUE en utilisant le nom de la CLASSE
      return CoinGeckoService.fetchTopCoins(perPage: 10); 
  }
}