# Architecture MobileCrypto

## Structure proposée

```
lib/
├── models/                    # Modèles de données
│   ├── transaction.dart      # Modèle Transaction
│   ├── coin.dart             # ✅ Déjà existant
│   └── notification_model.dart
│
├── repositories/              # Pattern Repository (Supabase + Cache)
│   ├── transaction_repository.dart
│   └── coin_repository.dart
│
├── services/                  # Services métier
│   ├── wallet_service.dart   # Calcul du solde
│   ├── coingecko_service.dart # ✅ Déjà existant
│   └── local_cache_service.dart # Cache local (Hive)
│
├── utils/                     # Utilitaires
│   ├── app_theme.dart
│   ├── supabase_config.dart
│   └── notification_service.dart
│
└── screens/                   # Écrans UI
```

## Principes

1. **Repository Pattern** : Séparation Supabase (cloud) et cache local
2. **Services** : Logique métier (calcul solde, validation)
3. **Mode hors ligne** : Cache local avec Hive pour données critiques
4. **State Management** : Provider simple pour état global (solde, transactions)

## Flux de données

### Transaction
```
BuySellScreen → WalletService → TransactionRepository → [Supabase + Hive Cache]
                                                       ↓
                                              TransactionsScreen (lecture)
```

### Solde
```
HomeScreen → WalletService → TransactionRepository → [Calcul: dépôts - achats + ventes - retraits]
                                                     ↓
                                            Affichage solde mis à jour
```

## Mode hors ligne

- **Cache Hive** : Transactions, solde, coins favoris
- **Priorité** : Lecture depuis cache si pas de réseau
- **Synchronisation** : Push vers Supabase dès reconnexion

