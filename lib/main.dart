import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  await Firebase.initializeApp();
  await Permission.microphone.request();
  runApp(const TalkTossApp());
}

class TalkTossApp extends StatelessWidget {
  const TalkTossApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TalkToss',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data != null ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
