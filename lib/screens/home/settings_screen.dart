import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // États pour les préférences
  String _selectedLanguage = 'FR';
  String _selectedTheme = 'Sombre';
  String _selectedCurrency = 'XOF';
  
  // États pour la sécurité
  bool _biometricEnabled = false;
  bool _securityNotificationsEnabled = true;
  
  // États pour les notifications
  bool _priceAlertEnabled = true;
  bool _depositAlertEnabled = true;
  bool _withdrawalAlertEnabled = true;
  bool _promoAlertEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'FR';
      _selectedTheme = prefs.getString('theme') ?? 'Sombre';
      _selectedCurrency = prefs.getString('currency') ?? 'XOF';
      _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
      _securityNotificationsEnabled = prefs.getBool('securityNotifications') ?? true;
      _priceAlertEnabled = prefs.getBool('priceAlert') ?? true;
      _depositAlertEnabled = prefs.getBool('depositAlert') ?? true;
      _withdrawalAlertEnabled = prefs.getBool('withdrawalAlert') ?? true;
      _promoAlertEnabled = prefs.getBool('promoAlert') ?? true;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: AppTextStyles.heading2.copyWith(color: AppColors.text)),
        content: Text(message, style: AppTextStyles.body.copyWith(color: AppColors.textFaded)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: AppTextStyles.link.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  
  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sélectionner la langue', style: AppTextStyles.heading2),
              const SizedBox(height: 20),
              _buildLanguageOption('FR', 'Français'),
              _buildLanguageOption('EN', 'English'),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildLanguageOption(String code, String name) {
    final isSelected = _selectedLanguage == code;
    return ListTile(
      title: Text(name, style: AppTextStyles.body),
      trailing: isSelected
          ? Icon(Icons.check, color: AppColors.primaryGreen)
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
        _saveSetting('language', code);
        Navigator.pop(context);
      },
    );
  }
  
  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sélectionner le thème', style: AppTextStyles.heading2),
              const SizedBox(height: 20),
              _buildThemeOption('Clair'),
              _buildThemeOption('Sombre'),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildThemeOption(String theme) {
    final isSelected = _selectedTheme == theme;
    return ListTile(
      title: Text(theme, style: AppTextStyles.body),
      trailing: isSelected
          ? Icon(Icons.check, color: AppColors.primaryGreen)
          : null,
      onTap: () {
        setState(() {
          _selectedTheme = theme;
        });
        _saveSetting('theme', theme);
        Navigator.pop(context);
        _showDialog(context, 'Thème', 'Le thème $theme sera disponible dans une prochaine mise à jour.');
      },
    );
  }
  
  void _showCurrencySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sélectionner la devise', style: AppTextStyles.heading2),
              const SizedBox(height: 20),
              _buildCurrencyOption('XOF', 'Franc CFA'),
              _buildCurrencyOption('USD', 'Dollar US'),
              _buildCurrencyOption('EUR', 'Euro'),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildCurrencyOption(String code, String name) {
    final isSelected = _selectedCurrency == code;
    return ListTile(
      title: Text('$code - $name', style: AppTextStyles.body),
      trailing: isSelected
          ? Icon(Icons.check, color: AppColors.primaryGreen)
          : null,
      onTap: () {
        setState(() {
          _selectedCurrency = code;
        });
        _saveSetting('currency', code);
        Navigator.pop(context);
      },
    );
  }
  
  void _showPinSettings() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Code PIN', style: AppTextStyles.heading2),
        content: Text(
          'Gérer votre code PIN pour sécuriser l\'application.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDialog(context, 'Code PIN', 'Cette fonctionnalité sera bientôt disponible.');
            },
            child: Text('Modifier', style: AppTextStyles.link.copyWith(color: AppColors.primaryGreen)),
          ),
        ],
      ),
    );
  }
  
  void _showBiometricInfo() {
    _showDialog(
      context,
      'Biométrie',
      'L\'authentification biométrique (FaceID/TouchID) sera disponible dans une prochaine mise à jour.',
    );
  }


  Widget _buildSettingItem({
    required String title,
    required IconData icon,
    bool hasToggle = false,
    bool? toggleValue,
    ValueChanged<bool>? onToggleChanged,
    VoidCallback? onTap,
    String? trailingText,
    Color iconColor = AppColors.textFaded,
  }) {
    return InkWell(
      onTap: hasToggle ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.text, 
                  fontSize: 16,
                ),
              ),
            ),
            if (hasToggle && toggleValue != null)
              Switch(
                value: toggleValue,
                onChanged: onToggleChanged,
                activeColor: AppColors.primaryGreen,
              )
            else if (trailingText != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trailingText,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textFaded,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, color: AppColors.textFaded, size: 18),
                ],
              )
            else if (!hasToggle)
              Icon(Icons.arrow_forward_ios, color: AppColors.textFaded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 16.0),
          child: Text(
            title,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textFaded,
              fontSize: 14,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Paramètres',
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10.0, bottom: 40.0),
                    child: Column(
        children: [
          // Section Sécurité
          _buildSection(
            context,
            'Sécurité',
            [
              _buildSettingItem(
                title: 'Code PIN pour l\'application',
                icon: Icons.lock_outline,
                onTap: () => _showPinSettings(),
              ),
              Divider(color: AppColors.border, height: 1),
              _buildSettingItem(
                title: 'Biométrie (FaceID / TouchID)',
                icon: Icons.fingerprint,
                hasToggle: true,
                toggleValue: _biometricEnabled,
                onToggleChanged: (value) {
                  setState(() {
                    _biometricEnabled = value;
                  });
                  _saveSetting('biometricEnabled', value);
                  if (value) {
                    _showBiometricInfo();
                  }
                },
              ),
              Divider(color: AppColors.border, height: 1),
              _buildSettingItem(
                title: 'Notification sécurité compte',
                icon: Icons.security,
                hasToggle: true,
                toggleValue: _securityNotificationsEnabled,
                onToggleChanged: (value) {
                  setState(() {
                    _securityNotificationsEnabled = value;
                  });
                  _saveSetting('securityNotifications', value);
                },
              ),
            ],
          ),
          
          // Section Préférences
          _buildSection(
            context,
            'Préférences',
            [
              _buildSettingItem(
                title: 'Langue',
                icon: Icons.language,
                trailingText: _selectedLanguage,
                onTap: () => _showLanguageSelector(),
              ),
              Divider(color: AppColors.border, height: 1),
              _buildSettingItem(
                title: 'Thème',
                icon: Icons.light_mode_outlined,
                trailingText: _selectedTheme,
                onTap: () => _showThemeSelector(),
              ),
              Divider(color: AppColors.border, height: 1),
              _buildSettingItem(
                title: 'Devise d\'affichage',
                icon: Icons.currency_exchange,
                trailingText: _selectedCurrency,
                onTap: () => _showCurrencySelector(),
              ),
            ],
          ),
          
          // Section Notifications
          _buildSection(
            context,
            'Notifications',
            [
              _buildSettingItem(
                title: 'Alerte prix',
                icon: Icons.trending_up,
                hasToggle: true,
                toggleValue: _priceAlertEnabled,
                onToggleChanged: (value) {
                  setState(() {
                    _priceAlertEnabled = value;
                  });
                  _saveSetting('priceAlert', value);
                },
              ),
              Divider(color: AppColors.border, height: 1),
              _buildSettingItem(
                title: 'Alerte dépôt validé',
                icon: Icons.arrow_downward,
                hasToggle: true,
                toggleValue: _depositAlertEnabled,
                onToggleChanged: (value) {
                  setState(() {
                    _depositAlertEnabled = value;
                  });
                  _saveSetting('depositAlert', value);
                },
              ),
              Divider(color: AppColors.border, height: 1),
              _buildSettingItem(
                title: 'Alerte retrait envoyé',
                icon: Icons.arrow_upward,
                hasToggle: true,
                toggleValue: _withdrawalAlertEnabled,
                onToggleChanged: (value) {
                  setState(() {
                    _withdrawalAlertEnabled = value;
                  });
                  _saveSetting('withdrawalAlert', value);
                },
              ),
              Divider(color: AppColors.border, height: 1),
              _buildSettingItem(
                title: 'Alerte promo ou nouveautés',
                icon: Icons.local_offer,
                hasToggle: true,
                toggleValue: _promoAlertEnabled,
                onToggleChanged: (value) {
                  setState(() {
                    _promoAlertEnabled = value;
                  });
                  _saveSetting('promoAlert', value);
                },
              ),
            ],
          ),
        ],
              ),
            ),
          ),
        ],
            );
          },
        ),
      ),
    );
  }
}
