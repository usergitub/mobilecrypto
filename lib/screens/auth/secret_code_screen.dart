import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
  final _supabase = Supabase.instance.client;
  bool _loading = false;

  void _onKeyPressed(String value) async {
    if (_code.length < 4) {
      setState(() {
        _code += value;
      });
      if (_code.length == 4) {
        setState(() => _loading = true);

        if (widget.isCreating) {
          // ✅ MODE CRÉATION : Sauvegarder le PIN
          await _savePinCode();
        } else {
          // ✅ MODE VÉRIFICATION : Vérifier le PIN
          await _verifyPinCode();
        }

        setState(() => _loading = false);
      }
    }
  }

  Future<void> _savePinCode() async {
    try {
      debugPrint('💾 Sauvegarde PIN: ${_code} pour ${widget.phoneNumber}');

      final response = await _supabase
          .from('Users')
          .update({
            'pin_code': _code,
          })
          .eq('phone_number', widget.phoneNumber)
          .select();

      debugPrint('✅ PIN sauvegardé: $_code');
      debugPrint('✅ Réponse Supabase: $response');

      // Aller à l'accueil
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde PIN: $e');
      _showError('Erreur sauvegarde du code');
    }
  }

  Future<void> _verifyPinCode() async {
    try {
      debugPrint('🔍 Vérification PIN pour: ${widget.phoneNumber}');

      final result = await _supabase
          .from('Users')
          .select('pin_code, first_name')
          .eq('phone_number', widget.phoneNumber)
          .maybeSingle();

      debugPrint('📊 Résultat vérification: $result');

      if (result != null &&
          result['pin_code'] != null &&
          result['pin_code'] == _code) {
        // ✅ PIN correct → Home
        debugPrint('✅ PIN correct!');
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // ❌ PIN incorrect
        debugPrint('❌ PIN incorrect ou non défini');
        _showError('Code secret incorrect');
      }
    } catch (e) {
      debugPrint('❌ Erreur vérification PIN: $e');
      _showError('Erreur de vérification');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Erreur"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _code = '');
            },
            child: const Text("Réessayer"),
          ),
        ],
      ),
    );
  }

  void _onBackspacePressed() {
    if (_code.isNotEmpty) {
      setState(() {
        _code = _code.substring(0, _code.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: AppColors.text),
      ),
      body: SafeArea( // ✅ AJOUT DU SafeArea
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.card.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.lock_outline, color: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                widget.isCreating
                    ? "Définis ton code secret à 4 chiffres"
                    : "Entre ton code secret",
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.isCreating
                    ? "Ce code permettra d'accéder à ton compte : ${widget.phoneNumber}"
                    : "Saisis ton code secret pour ${widget.phoneNumber}",
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              if (_loading) ...[
                const CircularProgressIndicator(color: AppColors.primaryGreen),
                const SizedBox(height: 16),
                const Text("Vérification...", style: AppTextStyles.body),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: index < _code.length
                            ? AppColors.primaryGreen
                            : AppColors.card,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ],

              const SizedBox(height: 20), // ✅ REMPLACEMENT DU Spacer()

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: KeypadWidget(
                  onKeyPressed: _onKeyPressed,
                  onBackspacePressed: _onBackspacePressed,
                ),
              ),

              const SizedBox(height: 16), // ✅ ESPACE RÉDUIT

              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.body.copyWith(fontSize: 14),
                    children: [
                      const TextSpan(text: "En continuant, vous acceptez nos\n"),
                      TextSpan(
                        text: "conditions d'utilisation",
                        style: AppTextStyles.link,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // TODO: ouvrir les CGU
                          },
                      ),
                    ],
                  ),
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