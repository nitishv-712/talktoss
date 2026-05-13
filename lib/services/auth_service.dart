import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/env.dart';

class AuthService {
  static String get baseUrl => Env.serverUrl;
  static final _googleSignIn = GoogleSignIn();
  static final _firebaseAuth = FirebaseAuth.instance;

  static Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseIdToken = await userCredential.user!.getIdToken();

      final res = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': firebaseIdToken}),
      );

      if (res.statusCode == 200) {
        return _saveSession(jsonDecode(res.body));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _saveSession(Map<String, dynamic> data) async {
    final token = data['token'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userId', data['user']['id']);
    await prefs.setString('userUid', data['user']['uid'] ?? '');
    await prefs.setString('userName', data['user']['name']);
    return token;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<String?> getUserUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userUid');
  }

  static Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
