import 'package:flutter/material.dart';
import 'dart:math';
import '/utils/app_theme.dart';
import '/utils/responsive_helper.dart';
import '/widgets/numeric_keypad.dart';
import 'name_screen.dart';
import 'secret_code_screen.dart';
import '/utils/notification_service.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isNewUser;
  final String fullPhone;

  const OtpScreen({
    super.key, 
    required this.phoneNumber,
    required this.isNewUser,
    required this.fullPhone,
  });

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

  Future<void> _sendOtp() async {
    final code = (1000 + Random().nextInt(9000)).toString();
    await NotificationService.showOtpNotification(code);
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
          if (widget.isNewUser) {
            // Nouvel utilisateur → NameScreen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NameScreen(phoneNumber: widget.fullPhone),
              ),
            );
          } else {
            // Utilisateur existant → SecretCodeScreen (vérification PIN)
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SecretCodeScreen(
                  phoneNumber: widget.fullPhone,
                  isCreating: false,
                ),
              ),
            );
          }
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
              setState(() => _otp = '');
            },
            child: const Text("Réessayer"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPad = ResponsiveHelper.horizontalPadding(context);
    final logoSize = ResponsiveHelper.logoSize(context);
    final spacing1 = ResponsiveHelper.spacing(context, 32);
    final spacing2 = ResponsiveHelper.spacing(context, 16);
    final spacing3 = ResponsiveHelper.spacing(context, 48);
    final spacing4 = ResponsiveHelper.spacing(context, 24);
    final fontSizeHeading = ResponsiveHelper.fontSize(context, 28);
    final fontSizeBody = ResponsiveHelper.fontSize(context, 16);
    final otpBarWidth = ResponsiveHelper.getWidth(context, 12);
    final otpBarMargin = ResponsiveHelper.spacing(context, 10);

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
                        "Un code a été envoyé à ${widget.phoneNumber}",
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: fontSizeHeading,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spacing2),
                      Text(
                        "Saisis ton code OTP reçu par notification",
                        style: AppTextStyles.body.copyWith(
                          fontSize: fontSizeBody,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spacing3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Container(
                            width: otpBarWidth,
                            height: 4,
                            margin: EdgeInsets.symmetric(horizontal: otpBarMargin),
                            decoration: BoxDecoration(
                              color: index < _otp.length
                                  ? AppColors.primaryGreen
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: spacing3),
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
                      SizedBox(height: spacing4),
                      TextButton(
                        onPressed: _sendOtp,
                        child: Text(
                          "Tu n'as pas reçu la notification ?\nRenvoyer un nouveau code",
                          style: AppTextStyles.body.copyWith(
                            fontSize: fontSizeBody,
                          ),
                          textAlign: TextAlign.center,
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
