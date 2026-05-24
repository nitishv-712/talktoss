import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _googleSignIn() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final user = await AuthService.signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    // Auth state stream handles navigation automatically
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Login screen always uses dark background for onboarding feel
    const bg = Color(0xFF0F0F0F);
    const card = Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                child: Icon(Icons.cell_tower_rounded, size: 48, color: cs.primary),
              ),
              const SizedBox(height: 28),
              const Text('TalkToss',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 10),
              const Text('Talk to random people\naround the world',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 15, height: 1.5)),
              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pill(cs, Icons.lock_outline, 'Anonymous'),
                  const SizedBox(width: 12),
                  _pill(cs, Icons.bolt, 'Instant'),
                  const SizedBox(width: 12),
                  _pill(cs, Icons.mic_none, 'Voice'),
                ],
              ),
              const Spacer(),
              _loading
                  ? CircularProgressIndicator(color: cs.primary)
                  : GestureDetector(
                      onTap: _googleSignIn,
                      child: Container(
                        width: double.infinity, height: 54,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network('https://developers.google.com/identity/images/g-logo.png', height: 22),
                            const SizedBox(width: 12),
                            const Text('Continue with Google',
                                style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              const Text('By continuing, you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white24, fontSize: 11)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(ColorScheme cs, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: cs.primary),
          const SizedBox(width: 5),
          const Text('', style: TextStyle(color: Colors.white60, fontSize: 12)),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }
}
