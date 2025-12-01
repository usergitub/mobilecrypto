// lib/screens/auth/sign_up_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/utils/app_theme.dart';
import '/utils/responsive_helper.dart';
import '/widgets/numeric_keypad.dart';
import 'otp_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _phoneNumber = ''; // les 10 chiffres (sans indicatif)
  bool _loading = false;

  final _supabase = Supabase.instance.client;

  // ajoute un chiffre (max 10)
  void _onKeyPressed(String value) {
    if (_phoneNumber.length < 10) {
      setState(() => _phoneNumber += value);
    }
  }

  // supprime le dernier chiffre
  void _onBackspacePressed() {
    if (_phoneNumber.isNotEmpty) {
      setState(
        () => _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1),
      );
    }
  }

  // retourne le numéro complet avec indicatif national +225
  String get _fullPhone => '+225$_phoneNumber';

  // fonction appelée quand l'utilisateur clique sur Continuer
  Future<void> _handleContinue() async {
    if (_phoneNumber.length != 10 || _loading) return;

    setState(() => _loading = true);
    final fullPhone = _fullPhone;

    try {
      // ✅ Vérifier si le numéro existe
      final result = await _supabase
          .from('Users')
          .select()
          .eq('phone_number', fullPhone)
          .maybeSingle();

      final bool isNewUser = (result == null);

      // ✅ CORRECTION : Utiliser fullPhone au lieu de fullUser
      debugPrint('🔍 Recherche utilisateur: $fullPhone - Trouvé: ${!isNewUser}');

      if (isNewUser) {
        // ✅ CRÉATION AVANT la navigation
        debugPrint('👤 Création nouvel utilisateur: $fullPhone');
        final insertResponse = await _supabase.from('Users').insert({
          'phone_number': fullPhone,
          'first_name': null,
          'last_name': null,
          'pin_code': '',
          'is_verified': false,
          'created_at': DateTime.now().toIso8601String(),
        }).select();

        debugPrint('✅ Utilisateur créé: $insertResponse');
      }

      // ✅ Navigation vers OTP
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            phoneNumber: _phoneNumber,
            isNewUser: isNewUser,
            fullPhone: fullPhone,
          ),
        ),
      );
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Erreur duplication → continuer vers OTP comme utilisateur existant
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              phoneNumber: _phoneNumber,
              isNewUser: false,
              fullPhone: fullPhone,
            ),
          ),
        );
      } else {
        debugPrint('❌ Erreur Supabase : ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur Supabase : ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('❌ Erreur inconnue : $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur réseau ou serveur : $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // widget affichant le numéro avec des placeholders
  Widget _buildPhoneNumberDisplay(BuildContext context) {
    List<Widget> displayChars = [];
    String placeholder = '0000000000'; // 10 zéros
    final fontSize = ResponsiveHelper.fontSize(context, 32);
    final spacing = ResponsiveHelper.spacing(context, 8);

    for (int i = 0; i < 10; i++) {
      if (i > 0 && i % 2 == 0) displayChars.add(SizedBox(width: spacing));

      final bool hasChar = i < _phoneNumber.length;
      final String char = hasChar ? _phoneNumber[i] : placeholder[i];

      displayChars.add(
        Text(
          char,
          style: TextStyle(
            color: hasChar
                ? AppColors.text
                : AppColors.textFaded.withValues(alpha: 0.4),
            fontSize: fontSize,
            letterSpacing: 2,
            fontWeight: hasChar ? FontWeight.w600 : FontWeight.w300,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: displayChars,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _phoneNumber.length == 10;
    final horizontalPad = ResponsiveHelper.horizontalPadding(context);
    final logoSize = ResponsiveHelper.logoSize(context);
    final buttonH = ResponsiveHelper.buttonHeight(context);
    final fontSizeHeading = ResponsiveHelper.fontSize(context, 28);
    final fontSizeBody = ResponsiveHelper.fontSize(context, 16);
    final fontSizePhone = ResponsiveHelper.fontSize(context, 32);
    final spacing1 = ResponsiveHelper.spacing(context, 32);
    final spacing2 = ResponsiveHelper.spacing(context, 16);
    final spacing3 = ResponsiveHelper.spacing(context, 12);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(Icons.arrow_back, color: AppColors.text),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                  child: Column(
                    children: [
                      SizedBox(height: spacing1),
                      Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          color: AppColors.card.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.primaryGreen,
                            size: ResponsiveHelper.iconSize(context, 30),
                          ),
                        ),
                      ),
                      SizedBox(height: spacing1),
                      Text(
                        "Pour commencer, entrez votre numéro mobile",
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: fontSizeHeading,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spacing2),
                      Text(
                        "Nous vous enverrons un code de vérification",
                        style: AppTextStyles.body.copyWith(
                          fontSize: fontSizeBody,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spacing1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "+225",
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: fontSizePhone,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(width: spacing2),
                          Flexible(child: _buildPhoneNumberDisplay(context)),
                        ],
                      ),
                      SizedBox(height: spacing1),
                      // Bouton Continuer
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing3),
                        child: SizedBox(
                          width: double.infinity,
                          height: buttonH,
                          child: ElevatedButton(
                            onPressed: isComplete && !_loading ? _handleContinue : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              disabledBackgroundColor: AppColors.card,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Continuer",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ResponsiveHelper.fontSize(context, 18),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: spacing2),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTextStyles.body.copyWith(
                              fontSize: ResponsiveHelper.fontSize(context, 14),
                            ),
                            children: [
                              const TextSpan(
                                text: "En continuant, vous acceptez nos ",
                              ),
                              TextSpan(
                                text: "conditions d'utilisation",
                                style: AppTextStyles.link,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // TODO: ouvre la page CGU
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: spacing1),
                      // Pavé numérique
                      Container(
                        padding: EdgeInsets.all(spacing2),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: KeypadWidget(
                          onKeyPressed: _onKeyPressed,
                          onBackspacePressed: _onBackspacePressed,
                        ),
                      ),
                      SizedBox(height: spacing3),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: spacing3),
                        child: Text(
                          'Numéro saisi: $_fullPhone',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textFaded,
                            fontSize: ResponsiveHelper.fontSize(context, 14),
                          ),
                        ),
                      ),
                      SizedBox(height: spacing2),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
