import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/utils/app_theme.dart';
import '/widgets/numeric_keypad.dart';
import '/screens/home/home_screen.dart';

class SecretCodeScreen extends StatefulWidget {
  const SecretCodeScreen({super.key});

  @override
  State<SecretCodeScreen> createState() => _SecretCodeScreenState();
}

class _SecretCodeScreenState extends State<SecretCodeScreen> {
  String _code = '';

  void _onKeyPressed(String value) {
    if (_code.length < 4) {
      setState(() {
        _code += value;
      });
      if (_code.length == 4) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    }
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: AppColors.card.withOpacity(0.5), shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.lock_outline, color: AppColors.primaryGreen)),
            ),
            const SizedBox(height: 32),
            const Text("Définir un nouveau code secret", style: AppTextStyles.heading1, textAlign: TextAlign.center),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: index < _code.length ? AppColors.primaryGreen : AppColors.card,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            Expanded(child: Container()),
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
            const SizedBox(height: 24),
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
                      recognizer: TapGestureRecognizer()..onTap = () { /* Handle link tap */ },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
