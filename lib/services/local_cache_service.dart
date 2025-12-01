import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

/// Service pour gérer le cache local (mode hors ligne)
class LocalCacheService {
  static const String _transactionsKey = 'cached_transactions';
  static const String _lastBalanceKey = 'last_balance';
  static const String _lastSyncKey = 'last_sync_timestamp';

  // Durée de validité du cache (24h)
  static const Duration cacheExpiry = Duration(hours: 24);

  /// Sauvegarder les transactions localement
  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await prefs.setString(_transactionsKey, jsonEncode(jsonList));
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  /// Récupérer les transactions depuis le cache
  static Future<List<Transaction>> getTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_transactionsKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Sauvegarder le dernier solde connu
  static Future<void> saveLastBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lastBalanceKey, balance);
  }

  /// Récupérer le dernier solde connu
  static Future<double> getLastBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_lastBalanceKey) ?? 0.0;
  }

  /// Vérifier si le cache est encore valide
  static Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncString = prefs.getString(_lastSyncKey);
      
      if (lastSyncString == null) {
        return false;
      }

      final lastSync = DateTime.parse(lastSyncString);
      final now = DateTime.now();
      
      return now.difference(lastSync) < cacheExpiry;
    } catch (e) {
      return false;
    }
  }

  /// Ajouter une transaction au cache
  static Future<void> addTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
  }

  /// Mettre à jour une transaction dans le cache
  static Future<void> updateTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    
    if (index != -1) {
      transactions[index] = transaction;
      await saveTransactions(transactions);
    }
  }

  /// Supprimer une transaction du cache
  static Future<void> deleteTransaction(String transactionId) async {
    final transactions = await getTransactions();
    transactions.removeWhere((t) => t.id == transactionId);
    await saveTransactions(transactions);
  }

  /// Vider le cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transactionsKey);
    await prefs.remove(_lastBalanceKey);
    await prefs.remove(_lastSyncKey);
  }

  /// Marquer les transactions comme synchronisées
  static Future<void> markAsSynced(List<String> transactionIds) async {
    final transactions = await getTransactions();
    
    for (final transaction in transactions) {
      if (transactionIds.contains(transaction.id) && !transaction.syncedWithCloud) {
        final updated = transaction.copyWith(syncedWithCloud: true);
        final index = transactions.indexWhere((t) => t.id == transaction.id);
        if (index != -1) {
          transactions[index] = updated;
        }
      }
    }
    
    await saveTransactions(transactions);
  }

  /// Récupérer les transactions non synchronisées
  static Future<List<Transaction>> getUnsyncedTransactions() async {
    final transactions = await getTransactions();
    return transactions.where((t) => !t.syncedWithCloud).toList();
  }
}

