import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/utils/app_theme.dart';
import '/widgets/numeric_keypad.dart';
import '/screens/home/home_screen.dart';

class SecretCodeScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isCreating;

  const SecretCodeScreen({
    super.key,
    required this.phoneNumber,
    this.isCreating = true,
  });

  @override
  State<SecretCodeScreen> createState() => _SecretCodeScreenState();
}

class _SecretCodeScreenState extends State<SecretCodeScreen> {
  String _code = '';
  bool _loading = false;
  final _supabase = Supabase.instance.client;

  /* ✅ SAUVEGARDE DES INFORMATIONS DE SESSION */
  Future<void> _saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userPhone', widget.phoneNumber);
    await prefs.setBool('pinCreated', true);
  }

  /* ✅ SAUVEGARDE DU PIN DANS SUPABASE */
  Future<void> _savePinCode() async {
    try {
      debugPrint('💾 Sauvegarde PIN: $_code pour ${widget.phoneNumber}');

      final response = await _supabase
          .from('Users')
          .update({'pin_code': _code})
          .eq('phone_number', widget.phoneNumber)
          .select();

      debugPrint('✅ Réponse Supabase: $response');

      await _saveLoginState();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde PIN: $e');
      _showError("Erreur lors de l'enregistrement du code secret");
    }
  }

  /* ✅ VÉRIFICATION DU PIN */
  Future<void> _verifyPinCode() async {
    try {
      debugPrint('🔍 Vérification PIN pour: ${widget.phoneNumber}');

      final result = await _supabase
          .from('Users')
          .select('pin_code')
          .eq('phone_number', widget.phoneNumber)
          .maybeSingle();

      if (result != null &&
          result['pin_code'] != null &&
          result['pin_code'] == _code) {
        debugPrint('✅ PIN correct');

        await _saveLoginState();

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        _showError("Code secret incorrect");
      }
    } catch (e) {
      debugPrint('❌ Erreur vérification PIN: $e');
      _showError("Impossible de vérifier le code secret");
    }
  }

  /* ✅ GESTION DU NUMPAD */
  void _onKeyPressed(String value) async {
    if (_code.length < 4) {
      setState(() => _code += value);
    }

    if (_code.length == 4) {
      setState(() => _loading = true);

      if (widget.isCreating) {
        await _savePinCode();
      } else {
        await _verifyPinCode();
      }

      if (mounted) setState(() => _loading = false);
    }
  }

  void _onBackspacePressed() {
    if (_code.isNotEmpty) {
      setState(() => _code = _code.substring(0, _code.length - 1));
    }
  }

  /* ✅ AFFICHAGE ALERT D'ERREUR */
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text("Erreur", style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _code = '');
            },
            child: const Text("Réessayer"),
          )
        ],
      ),
    );
  }

  /* ✅ UI */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.card.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline,
                    color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 32),

              Text(
                widget.isCreating
                    ? "Définis ton code secret à 4 chiffres"
                    : "Entrer votre code secret",
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                widget.isCreating
                    ? "Ce code sécurise ton compte MobileCrypto"
                    : "Déverrouille ton compte ${widget.phoneNumber}",
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              _loading
                  ? const CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        return Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: i < _code.length
                                ? AppColors.primaryGreen
                                : AppColors.card,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: KeypadWidget(
                  onKeyPressed: _onKeyPressed,
                  onBackspacePressed: _onBackspacePressed,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
