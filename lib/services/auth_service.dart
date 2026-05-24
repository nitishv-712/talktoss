import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env.dart';

class AuthService {
  static final _googleSignIn = kIsWeb 
      ? GoogleSignIn(clientId: Env.googleClientId)
      : GoogleSignIn();
  static final _firebaseAuth = FirebaseAuth.instance;

  static User? get currentUser => _firebaseAuth.currentUser;
  static Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  static Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      // Sync with backend
      final idToken = await user.getIdToken();
      final res = await http.post(
        Uri.parse('${Env.serverUrl}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', body['token']);
      }

      return user;
    } catch (e) {
      debugPrint('[AuthService] error: $e');
      return null;
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
