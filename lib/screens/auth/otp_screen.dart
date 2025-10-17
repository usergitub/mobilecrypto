import 'package:flutter/material.dart';
import 'dart:math';
import '/utils/app_theme.dart';
import '/main.dart'; // 👈 Pour utiliser showOtpNotification()
import '/widgets/numeric_keypad.dart';
import 'name_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = '';
  String _generatedOtp = '';

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  // 🔐 Génération et affichage du code OTP via notification
  void _sendOtp() async {
    final code = (1000 + Random().nextInt(9000)).toString();
    await showOtpNotification(code); // 👈 Affiche la notification
    setState(() {
      _generatedOtp = code;
    });
  }

  void _onKeyPressed(String value) {
    if (_otp.length < 4) {
      setState(() {
        _otp += value;
      });
      if (_otp.length == 4) {
        if (_otp == _generatedOtp) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const NameScreen()));
        } else {
          _showError();
        }
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

  void _showError() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Code incorrect"),
        content: const Text("Le code saisi ne correspond pas."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _otp = '';
              });
            },
            child: const Text("Réessayer"),
          )
        ],
      ),
    );
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Icon(Icons.chat_bubble_outline,
                      color: AppColors.primaryGreen)),
            ),
            const SizedBox(height: 32),
            const Text(
              "Vérifie la notification pour ton code MobileCrypto.",
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  width: 50,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: index < _otp.length
                        ? AppColors.primaryGreen
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
            const Spacer(),
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
              onPressed: _sendOtp,
              child: const Text(
                "Tu n'as pas reçu la notification ?\nRenvoyer un nouveau code",
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
