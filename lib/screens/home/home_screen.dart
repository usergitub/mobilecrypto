import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '/utils/app_theme.dart';
import '../home/transactions_screen.dart';
import '../home/settings_screen.dart';
import '../home/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<double> percentages = [10.45, 10.45, 10.45, 10.45];
  late Timer _timer;

  final List<Widget> _screens = const [
    Placeholder(), // remplacé par Home contenu
    TransactionsScreen(),
    SettingsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        // Change aléatoirement les % et la couleur
        percentages = List.generate(4, (_) {
          double value = Random().nextDouble() * 20 - 10; // -10% à +10%
          return double.parse(value.toStringAsFixed(2));
        });
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: AppTextStyles.heading2),
        content: Text(message, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: AppTextStyles.link),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    if (_selectedIndex == 0) {
      currentScreen = _buildHomeContent();
    } else {
      currentScreen = _screens[_selectedIndex];
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: currentScreen),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: AppColors.card,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textFaded,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildSearchBar(),
        const SizedBox(height: 24),
        _buildWelcomeBanner(),
        const SizedBox(height: 32),
        _buildSectionTitle("En pleine hausse 🚀", "Voir tous", onTap: () {
          _showDialog("En développement", "Cette page est en cours de développement.");
        }),
        const SizedBox(height: 16),
        _buildTrendingCoins(),
        const SizedBox(height: 32),
        _buildSectionTitle("Achetez & Vendez 🔄", "", onTap: null),
        const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(radius: 24, backgroundColor: Colors.blueAccent),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Good morning", style: AppTextStyles.body),
            Text("Diara Toupetit", style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () {
            _showDialog("Notification", "L’app est en cours de développement. Testez et donnez votre avis.");
          },
          icon: const Icon(Icons.chat_bubble, color: AppColors.text, size: 18),
          label: const Text("Notification", style: TextStyle(color: AppColors.text)),
          style: TextButton.styleFrom(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Catégorie de recherche",
        hintStyle: const TextStyle(color: AppColors.textFaded),
        prefixIcon: const Icon(Icons.search, color: AppColors.textFaded),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.primaryGreen,
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Image.network(
              'https://i.ibb.co/C0bNf3M/african-man-surprised.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 100, color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Bonus de bienvenue 🎁", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("0 % de frais", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text("Sur la 1ère transaction, profite dès maintenant !", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Commencer"),
                        Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String actionText, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)),
        if (actionText.isNotEmpty)
          GestureDetector(
            onTap: onTap,
            child: Text(actionText, style: const TextStyle(color: AppColors.textFaded)),
          ),
      ],
    );
  }

  Widget _buildTrendingCoins() {
    final icons = [Icons.currency_bitcoin, Icons.diamond_outlined, Icons.ac_unit, Icons.send];
    final colors = [Colors.orange, Colors.cyan, Colors.yellow, Colors.blue];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (i) {
        bool isPositive = percentages[i] >= 0;
        return Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.card,
              child: Icon(icons[i], color: colors[i], size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              "${percentages[i] > 0 ? '+' : ''}${percentages[i]}%",
              style: TextStyle(color: isPositive ? AppColors.primaryGreen : AppColors.primaryRed, fontWeight: FontWeight.bold),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _actionButton("Acheter", Icons.arrow_upward, AppColors.primaryGreen, onPressed: () {
            _showDialog("Paiement", "L’API de réception d’argent n’est pas encore obtenue.");
          }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _actionButton("Vendre", Icons.arrow_downward, AppColors.primaryRed, onPressed: () {
            _showDialog("Paiement", "L’API de réception d’argent n’est pas encore obtenue.");
          }),
        ),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, {required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 160,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
