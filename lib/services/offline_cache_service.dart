import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coin.dart';

/// Service pour gérer le cache offline des données de cryptomonnaies
class OfflineCacheService {
  static const Duration _cacheValidityDuration = Duration(hours: 1); // Cache valide 1 heure

  /// Sauvegarder les données des cryptomonnaies en cache
  static Future<void> saveCoinsCache(List<Coin> coins, String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coinsJson = coins.map((coin) => coin.toJson()).toList();
      await prefs.setString(cacheKey, jsonEncode(coinsJson));
      await prefs.setString('${cacheKey}_timestamp', DateTime.now().toIso8601String());
      debugPrint("✅ Cache sauvegardé pour $cacheKey: ${coins.length} monnaies");
    } catch (e) {
      debugPrint("❌ Erreur sauvegarde cache: $e");
    }
  }

  /// Charger les données des cryptomonnaies depuis le cache
  static Future<List<Coin>?> loadCoinsCache(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(cacheKey);
      final timestampStr = prefs.getString('${cacheKey}_timestamp');

      if (cachedData == null || timestampStr == null) {
        return null;
      }

      // Vérifier si le cache est encore valide
      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      if (now.difference(timestamp) > _cacheValidityDuration) {
        debugPrint("⚠️ Cache expiré pour $cacheKey");
        return null;
      }

      final List<dynamic> coinsList = jsonDecode(cachedData);
      final coins = coinsList.map((json) => Coin.fromJson(json)).toList();
      debugPrint("✅ Cache chargé pour $cacheKey: ${coins.length} monnaies");
      return coins;
    } catch (e) {
      debugPrint("❌ Erreur chargement cache: $e");
      return null;
    }
  }

  /// Vérifier si le cache est disponible et valide
  static Future<bool> isCacheAvailable(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(cacheKey);
      final timestampStr = prefs.getString('${cacheKey}_timestamp');

      if (cachedData == null || timestampStr == null) {
        return false;
      }

      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      return now.difference(timestamp) <= _cacheValidityDuration;
    } catch (e) {
      return false;
    }
  }

  /// Nettoyer le cache
  static Future<void> clearCache(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(cacheKey);
      await prefs.remove('${cacheKey}_timestamp');
      debugPrint("✅ Cache nettoyé pour $cacheKey");
    } catch (e) {
      debugPrint("❌ Erreur nettoyage cache: $e");
    }
  }
}

