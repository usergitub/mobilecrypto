import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../utils/supabase_config.dart';
import '../services/local_cache_service.dart';

/// Repository pour gérer les transactions (Supabase + Cache local)
class TransactionRepository {
  static const String _userIdKey = 'userPhone';

  /// Récupérer toutes les transactions (avec mode hors ligne)
  Future<List<Transaction>> getTransactions() async {
    try {
      // Vérifier la connexion réseau
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = !connectivityResult.contains(ConnectivityResult.none);

      if (isOnline) {
        // Essayer de récupérer depuis Supabase
        try {
          final prefs = await SharedPreferences.getInstance();
          final userId = prefs.getString(_userIdKey);
          
          if (userId != null) {
            final response = await SupabaseConfig.client
                .from('transactions')
                .select()
                .eq('user_id', userId)
                .order('timestamp', ascending: false);

            final transactions = (response as List)
                .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
                .toList();

            // Sauvegarder dans le cache local
            await LocalCacheService.saveTransactions(transactions);
            
            // Synchroniser les transactions non synchronisées
            await _syncPendingTransactions();

            return transactions;
          }
        } catch (e) {
          // Si erreur Supabase, utiliser le cache
        }
      }

      // Mode hors ligne ou erreur : utiliser le cache local
      final cachedTransactions = await LocalCacheService.getTransactions();
      return cachedTransactions;
    } catch (e) {
      // En cas d'erreur, retourner le cache
      return await LocalCacheService.getTransactions();
    }
  }

  /// Ajouter une transaction
  Future<void> addTransaction(Transaction transaction) async {
    // Ajouter au cache local immédiatement (mode hors ligne)
    await LocalCacheService.addTransaction(
      transaction.copyWith(syncedWithCloud: false),
    );

    // Essayer de sauvegarder dans Supabase si en ligne
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (isOnline) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString(_userIdKey);

        if (userId != null) {
          await SupabaseConfig.client.from('transactions').insert({
            ...transaction.toJson(),
            'user_id': userId,
          });

          // Marquer comme synchronisé
          await LocalCacheService.markAsSynced([transaction.id]);
          
          // Mettre à jour dans le cache
          final updated = transaction.copyWith(syncedWithCloud: true);
          await LocalCacheService.updateTransaction(updated);
        }
      } catch (e) {
        // Erreur de synchronisation, la transaction restera dans le cache
        // et sera synchronisée plus tard
      }
    }
  }

  /// Mettre à jour une transaction
  Future<void> updateTransaction(Transaction transaction) async {
    // Mettre à jour le cache local
    await LocalCacheService.updateTransaction(transaction);

    // Essayer de mettre à jour dans Supabase si en ligne
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (isOnline) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString(_userIdKey);

        if (userId != null) {
          await SupabaseConfig.client
              .from('transactions')
              .update(transaction.toJson())
              .eq('id', transaction.id)
              .eq('user_id', userId);

          // Marquer comme synchronisé
          await LocalCacheService.markAsSynced([transaction.id]);
        }
      } catch (e) {
        // Erreur de synchronisation
      }
    }
  }

  /// Supprimer une transaction
  Future<void> deleteTransaction(String transactionId) async {
    // Supprimer du cache local
    await LocalCacheService.deleteTransaction(transactionId);

    // Essayer de supprimer de Supabase si en ligne
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = !connectivityResult.contains(ConnectivityResult.none);

    if (isOnline) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString(_userIdKey);

        if (userId != null) {
          await SupabaseConfig.client
              .from('transactions')
              .delete()
              .eq('id', transactionId)
              .eq('user_id', userId);
        }
      } catch (e) {
        // Erreur de suppression
      }
    }
  }

  /// Synchroniser les transactions en attente
  Future<void> _syncPendingTransactions() async {
    try {
      final unsynced = await LocalCacheService.getUnsyncedTransactions();
      
      if (unsynced.isEmpty) return;

      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = !connectivityResult.contains(ConnectivityResult.none);

      if (!isOnline) return;

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);

      if (userId == null) return;

      final syncedIds = <String>[];

      for (final transaction in unsynced) {
        try {
          await SupabaseConfig.client.from('transactions').insert({
            ...transaction.toJson(),
            'user_id': userId,
          });
          syncedIds.add(transaction.id);
        } catch (e) {
          // Continuer avec les autres transactions
        }
      }

      // Marquer comme synchronisés
      if (syncedIds.isNotEmpty) {
        await LocalCacheService.markAsSynced(syncedIds);
      }
    } catch (e) {
      // Erreur de synchronisation
    }
  }

  /// Forcer la synchronisation (appelé manuellement)
  Future<void> syncPendingTransactions() async {
    await _syncPendingTransactions();
  }
}
