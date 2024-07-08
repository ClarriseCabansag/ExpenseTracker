import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordService {
  static Future<void> sendPasswordResetEmail(String email) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Error sending password reset email');
    }
  }
}
