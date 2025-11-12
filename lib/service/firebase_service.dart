import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static Future<String?> obterTokenFCM() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }
}
