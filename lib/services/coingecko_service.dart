import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/coin.dart';
import 'offline_cache_service.dart'; 

class CoinGeckoService {
  static const _base = 'https://api.coingecko.com/api/v3';

  /// Fetch par liste personnalisée (id exacts) avec support offline
  static Future<List<Coin>> fetchCoinsByIds(List<String> ids) async {
    final cacheKey = 'coins_${ids.join('_')}';
    
    // Vérifier la connexion internet
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);
    
    if (isOnline) {
      try {
        final joined = ids.join(',');
        final url = Uri.parse(
          '$_base/coins/markets?vs_currency=usd&ids=$joined&order=market_cap_desc&sparkline=false&price_change_percentage=24h',
        );

        final res = await http.get(url);
        if (res.statusCode == 200) {
          final List data = jsonDecode(res.body);
          final coins = data.map((e) => Coin.fromJson(e)).toList();
          
          // Sauvegarder en cache pour le mode offline
          await OfflineCacheService.saveCoinsCache(coins, cacheKey);
          
          return coins;
        } else {
          debugPrint('CoinGecko error fetching by IDs: ${res.statusCode}');
          // En cas d'erreur, essayer de charger depuis le cache
          final cachedCoins = await OfflineCacheService.loadCoinsCache(cacheKey);
          if (cachedCoins != null) {
            debugPrint('📱 Mode offline: Chargement depuis le cache');
            return cachedCoins;
          }
          throw Exception('Erreur CoinGecko: ${res.statusCode}');
        }
      } catch (e) {
        debugPrint('❌ Erreur réseau: $e - Tentative de chargement depuis le cache');
        // En cas d'erreur réseau, charger depuis le cache
        final cachedCoins = await OfflineCacheService.loadCoinsCache(cacheKey);
        if (cachedCoins != null) {
          debugPrint('📱 Mode offline: Chargement depuis le cache');
          return cachedCoins;
        }
        rethrow;
      }
    } else {
      // Mode offline : charger depuis le cache
      debugPrint('📱 Mode offline détecté');
      final cachedCoins = await OfflineCacheService.loadCoinsCache(cacheKey);
      if (cachedCoins != null && cachedCoins.isNotEmpty) {
        debugPrint('✅ Données chargées depuis le cache offline');
        return cachedCoins;
      } else {
        throw Exception('Pas de connexion internet et aucun cache disponible');
      }
    }
  }

  /// Fetch général (utilisé pour scroll dans AllCoins) avec support offline
  static Future<List<Coin>> fetchTopCoins({
    int perPage = 20,
    int page = 1,
  }) async {
    final cacheKey = 'top_coins_${perPage}_$page';
    
    // Vérifier la connexion internet
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);
    
    if (isOnline) {
      try {
        final url = Uri.parse(
          '$_base/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=$perPage&page=$page&sparkline=false&price_change_percentage=24h',
        );

        final res = await http.get(url);

        if (res.statusCode == 200) {
          final List data = jsonDecode(res.body);
          final coins = data.map((e) => Coin.fromJson(e)).toList();
          
          // Sauvegarder en cache pour le mode offline
          await OfflineCacheService.saveCoinsCache(coins, cacheKey);
          
          return coins;
        } else {
          debugPrint('CoinGecko error fetching top coins: ${res.statusCode}');
          // En cas d'erreur, essayer de charger depuis le cache
          final cachedCoins = await OfflineCacheService.loadCoinsCache(cacheKey);
          if (cachedCoins != null) {
            debugPrint('📱 Mode offline: Chargement depuis le cache');
            return cachedCoins;
          }
          throw Exception('Erreur CoinGecko: ${res.statusCode}');
        }
      } catch (e) {
        debugPrint('❌ Erreur réseau: $e - Tentative de chargement depuis le cache');
        // En cas d'erreur réseau, charger depuis le cache
        final cachedCoins = await OfflineCacheService.loadCoinsCache(cacheKey);
        if (cachedCoins != null) {
          debugPrint('📱 Mode offline: Chargement depuis le cache');
          return cachedCoins;
        }
        rethrow;
      }
    } else {
      // Mode offline : charger depuis le cache
      debugPrint('📱 Mode offline détecté');
      final cachedCoins = await OfflineCacheService.loadCoinsCache(cacheKey);
      if (cachedCoins != null && cachedCoins.isNotEmpty) {
        debugPrint('✅ Données chargées depuis le cache offline');
        return cachedCoins;
      } else {
        throw Exception('Pas de connexion internet et aucun cache disponible');
      }
    }
  }
  
  // Méthode pour l'écran d'accueil (méthode d'instance)
  Future<List<Coin>> fetchCoins() async {
      // ✅ CORRECTION : on appelle la méthode STATIQUE en utilisant le nom de la CLASSE
      return CoinGeckoService.fetchTopCoins(perPage: 10); 
  }
}