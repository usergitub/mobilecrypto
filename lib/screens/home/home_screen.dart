import 'package:flutter/material.dart';
import '/utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildWelcomeBanner(),
            const SizedBox(height: 32),
            _buildSectionTitle("En pleine hausse 🚀", "Voir tous"),
            const SizedBox(height: 16),
            _buildTrendingCoins(),
            const SizedBox(height: 32),
            _buildSectionTitle("Achetez & Vendez 🔄", ""),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
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

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          // backgroundImage: NetworkImage('...'), // User profile image
          backgroundColor: Colors.blueAccent,
        ),
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
          onPressed: () {},
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
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            top: 0,
            width: MediaQuery.of(context).size.width * 0.4,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: Image.network(
                // Placeholder image, replace with your asset
                'https://i.ibb.co/C0bNf3M/african-man-surprised.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 100),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            bottom: 16,
            left: MediaQuery.of(context).size.width * 0.4 + 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Bonus de bienvenue 🎁", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("0 % de frais", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const Text("Sur la 1ère transaction, profite dès maintenant !", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const Spacer(),
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
                      Icon(Icons.arrow_forward_ios, size: 14)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)),
        if (actionText.isNotEmpty)
          Text(actionText, style: const TextStyle(color: AppColors.textFaded)),
      ],
    );
  }

  Widget _buildTrendingCoins() {
    // Replace with real data from your API
    final coins = [
      {'icon': Icons.currency_bitcoin, 'color': Colors.orange},
      {'icon': Icons.diamond_outlined, 'color': Colors.cyan},
      {'icon': Icons.ac_unit, 'color': Colors.yellow},
      {'icon': Icons.send, 'color': Colors.blue},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: coins.map((coin) {
        return Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.card,
              child: Icon(coin['icon'] as IconData, color: coin['color'] as Color, size: 28),
            ),
            const SizedBox(height: 8),
            const Text("+10,45%", style: TextStyle(color: AppColors.primaryGreen)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            "Acheter",
            Icons.arrow_upward,
            AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _actionButton(
            "Vendre",
            Icons.arrow_downward,
            AppColors.primaryRed,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
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
