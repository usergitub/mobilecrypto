import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/utils/app_theme.dart';
import '/widgets/numeric_keypad.dart';
import 'otp_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _phoneNumber = '';

  void _onKeyPressed(String value) {
    if (_phoneNumber.length < 9) {
      setState(() {
        _phoneNumber += value;
      });
    }
  }

  void _onBackspacePressed() {
    if (_phoneNumber.isNotEmpty) {
      setState(() {
        _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
      });
    }
  }

  String _formatPhoneNumber() {
    var buffer = StringBuffer();
    for (int i = 0; i < _phoneNumber.length; i++) {
      buffer.write(_phoneNumber[i]);
      if ((i + 1) % 3 == 0 && i < _phoneNumber.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
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
            // Your logo here
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: AppColors.card.withOpacity(0.5), shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.chat_bubble_outline, color: AppColors.primaryGreen)),
            ),
            const SizedBox(height: 32),
            const Text("Pour Commencer entre votre numero mobile", style: AppTextStyles.heading1, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Text("Nous vous enverrons un code de vérification", style: AppTextStyles.body),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("+225", style: TextStyle(color: AppColors.text, fontSize: 32, letterSpacing: 2)),
                const SizedBox(width: 16),
                Text(
                  _formatPhoneNumber().padRight(11, '_'),
                  style: const TextStyle(color: AppColors.text, fontSize: 32, letterSpacing: 2),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OtpScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
             Center(
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.body.copyWith(fontSize: 14),
                  children: [
                    const TextSpan(text: "En continuant, vous acceptez nos "),
                    TextSpan(
                      text: "conditions d'utilisation",
                      style: AppTextStyles.link,
                      recognizer: TapGestureRecognizer()..onTap = () { /* Handle link tap */ },
                    ),
                  ],
                ),
              ),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
