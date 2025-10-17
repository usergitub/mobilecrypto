import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidInit);
    await _notifications.initialize(settings);
  }

  static Future<void> showOtpNotification(String code) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails('otp_channel', 'OTP Notifications',
            importance: Importance.max, priority: Priority.high);
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      'Code OTP MobileCrypto',
      'Votre code de vérification est : $code',
      details,
    );
  }
}
