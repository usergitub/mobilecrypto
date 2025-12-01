import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/utils/app_theme.dart';
import '/utils/responsive_helper.dart';
import 'secret_code_screen.dart';

class NameScreen extends StatefulWidget {
  final String phoneNumber;

  const NameScreen({super.key, required this.phoneNumber});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _controller = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  Future<void> _onContinue() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() => _loading = true);

    try {
      // Sauvegarde du nom dans Supabase
      final response = await _supabase
          .from('Users')
          .update({
            'first_name': name,
          })
          .eq('phone_number', widget.phoneNumber)
          .select();

      debugPrint('✅ Nom sauvegardé: $name pour ${widget.phoneNumber}');
      debugPrint('✅ Réponse Supabase: $response');

      // ✅ Sauvegarde locale (pour affichage immédiat dans l'app)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userName", name);
      await prefs.setString("userPhone", widget.phoneNumber);

      // ✅ Continuer vers la création du PIN
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SecretCodeScreen(
            phoneNumber: widget.phoneNumber,
            isCreating: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde nom: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur sauvegarde: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPad = ResponsiveHelper.horizontalPadding(context);
    final logoSize = ResponsiveHelper.logoSize(context);
    final spacing1 = ResponsiveHelper.spacing(context, 32);
    final spacing2 = ResponsiveHelper.spacing(context, 48);
    final spacing3 = ResponsiveHelper.spacing(context, 40);
    final fontSizeHeading = ResponsiveHelper.fontSize(context, 28);
    final fontSizeInput = ResponsiveHelper.fontSize(context, 20);
    final buttonH = ResponsiveHelper.buttonHeight(context);

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
                            Icons.person_add_alt_1,
                            color: AppColors.primaryGreen,
                            size: ResponsiveHelper.iconSize(context, 30),
                          ),
                        ),
                      ),
                      SizedBox(height: spacing1),
                      Text(
                        "Veuillez entrer votre nom et prénoms légaux complets.",
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: fontSizeHeading,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spacing2),
                      TextField(
                        controller: _controller,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: fontSizeInput,
                        ),
                        decoration: InputDecoration(
                          hintText: "Nom et prénoms",
                          hintStyle: TextStyle(color: AppColors.textFaded),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primaryGreen),
                          ),
                        ),
                      ),
                      SizedBox(height: spacing1),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTextStyles.body.copyWith(
                              fontSize: ResponsiveHelper.fontSize(context, 14),
                            ),
                            children: [
                              const TextSpan(text: "En m'inscrivant, j'accepte les "),
                              TextSpan(
                                text: "conditions d'utilisation",
                                style: AppTextStyles.link,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // TODO: Ouvrir les CGU
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: spacing2),
                      SizedBox(
                        width: double.infinity,
                        height: buttonH,
                        child: ElevatedButton(
                          onPressed: (_controller.text.trim().isEmpty || _loading)
                              ? null
                              : _onContinue,
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
                      SizedBox(height: spacing3),
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
