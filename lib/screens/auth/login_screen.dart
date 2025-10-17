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
    // Le numéro de téléphone en Côte d'Ivoire a 10 chiffres.
    if (_phoneNumber.length < 10) {
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
  
  // CHANGEMENT 1 : Nouveau widget pour afficher le numéro de téléphone comme la maquette
  Widget _buildPhoneNumberDisplay() {
    List<Widget> displayChars = [];
    String placeholder = '0000000000'; // 10 zéros

    for (int i = 0; i < 10; i++) {
      // Ajoute un espace après les 2e, 4e, 6e, et 8e chiffres (format XX XX XX XX XX)
      if (i > 0 && i % 2 == 0) {
        displayChars.add(const Text(" ", style: TextStyle(color: AppColors.text, fontSize: 32)));
      }
      
      if (i < _phoneNumber.length) {
        // Chiffre entré par l'utilisateur
        displayChars.add(Text(_phoneNumber[i], style: const TextStyle(color: AppColors.text, fontSize: 32, letterSpacing: 2)));
      } else {
        // Placeholder pour les chiffres non encore entrés
        displayChars.add(Text(placeholder[i], style: TextStyle(color: AppColors.textFaded.withOpacity(0.3), fontSize: 32, letterSpacing: 2)));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: displayChars,
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
      // CHANGEMENT 2 : Ajout de SingleChildScrollView pour éviter le "Bottom Overflow"
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9, // S'assure que le contenu a une hauteur définie
            child: Column(
              children: [
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
                    // CHANGEMENT 3 : Utilisation de notre nouveau widget
                    _buildPhoneNumberDisplay(),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _phoneNumber.length == 10 ? () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OtpScreen()));
                  } : null, // Le bouton est désactivé si le numéro n'est pas complet
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    disabledBackgroundColor: AppColors.card,
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
                const Spacer(), // Pousse le clavier vers le bas
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}