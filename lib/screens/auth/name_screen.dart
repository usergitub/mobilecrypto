import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/utils/app_theme.dart';
import 'secret_code_screen.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {}); // Re-build to check button state
    });
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
              child: const Center(child: Icon(Icons.person_add_alt_1, color: AppColors.primaryGreen)),
            ),
            const SizedBox(height: 32),
            const Text("Veuillez entrer votre nom et prenoms légal comple.", style: AppTextStyles.heading1, textAlign: TextAlign.center),
            const SizedBox(height: 48),
            TextField(
              controller: _controller,
              style: const TextStyle(color: AppColors.text, fontSize: 20),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryGreen),
                ),
              ),
            ),
            const SizedBox(height: 32),
             Center(
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.body.copyWith(fontSize: 14),
                  children: [
                    const TextSpan(text: "En m'inscrivant, j'accepte les "),
                    TextSpan(
                      text: "conditions d'utilisation",
                      style: AppTextStyles.link,
                      recognizer: TapGestureRecognizer()..onTap = () { /* Handle link tap */ },
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _controller.text.trim().isEmpty ? null : () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SecretCodeScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                disabledBackgroundColor: AppColors.card,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
