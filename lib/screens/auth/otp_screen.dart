import 'package:flutter/material.dart';
import '/utils/app_theme.dart';
import '/widgets/numeric_keypad.dart';
import 'name_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = '';

  void _onKeyPressed(String value) {
    if (_otp.length < 4) {
      setState(() {
        _otp += value;
      });
      if (_otp.length == 4) {
        // Automatically navigate when OTP is complete
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NameScreen()));
      }
    }
  }

  void _onBackspacePressed() {
    if (_otp.isNotEmpty) {
      setState(() {
        _otp = _otp.substring(0, _otp.length - 1);
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
              child: const Center(child: Icon(Icons.chat_bubble_outline, color: AppColors.primaryGreen)),
            ),
            const SizedBox(height: 32),
            const Text("Vérifie ta notification pour récupérer ton code MobileCrypto.", style: AppTextStyles.heading1, textAlign: TextAlign.center),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  width: 50,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: index < _otp.length ? AppColors.primaryGreen : AppColors.card,
                    borderRadius: BorderRadius.circular(2),
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
            TextButton(
              onPressed: () { /* Resend OTP Logic */ },
              child: const Text("Tu n'as pas reçu la notification ?\nRenvoyer un nouveau code",
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
