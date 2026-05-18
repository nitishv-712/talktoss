import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final User? _user = AuthService.currentUser;

  final _screens = const [
    HomeScreen(),
    ChatScreen(),
    _PlaceholderScreen(icon: Icons.explore_outlined, label: 'Explore'),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 1,
        shadowColor: cs.primary.withValues(alpha: 0.05),
        titleSpacing: 16,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: _user?.photoURL != null ? NetworkImage(_user!.photoURL!) : null,
              backgroundColor: cs.surfaceContainer,
              child: _user?.photoURL == null
                  ? Icon(Icons.person, color: cs.onSurface.withValues(alpha: 0.5), size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [cs.primary, cs.secondary],
              ).createShader(bounds),
              child: const Text('TalkToss',
                  style: TextStyle(
                      color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: cs.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.85),
          border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2))),
          boxShadow: [
            BoxShadow(color: cs.primary.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4)),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(context, 0, Icons.home_outlined, Icons.home, 'Home'),
                _navItem(context, 1, Icons.chat_bubble_outline, Icons.chat_bubble, 'Chat'),
                _navItem(context, 2, Icons.explore_outlined, Icons.explore, 'Explore'),
                _navItem(context, 3, Icons.person_outline, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int idx, IconData icon, IconData activeIcon, String label) {
    final cs = Theme.of(context).colorScheme;
    final active = _index == idx;
    return GestureDetector(
      onTap: () => setState(() => _index = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: active ? 16 : 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? cs.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? activeIcon : icon,
                color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.5), size: 24),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderScreen({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: cs.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 16)),
        ],
      ),
    );
  }
}
