import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../market/market_screen.dart'; 
import '../home/transactions_screen.dart'; 
import '../home/profile_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0; // Index de l'onglet sélectionné (0 = Accueil)

  // Liste des écrans à afficher dans le body
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),         // Index 0: Accueil (Déjà implémenté)
    MarketScreen(),       // Index 1: Marché (À implémenter)
    TransactionsScreen(), // Index 2: Transactions (À implémenter)
    ProfileScreen(),      // Index 3: Profil (À implémenter)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Affiche l'écran sélectionné
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // Barre de navigation inférieure
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Marché',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}