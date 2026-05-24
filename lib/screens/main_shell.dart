import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';
import '../services/social_service.dart';
import 'home/home_screen.dart';
import 'chat/chat_screen.dart';
import 'profile/profile_screen.dart';
import 'profile/notifications_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  int _unreadCount = 0;

  final _screens = const [HomeScreen(), ChatScreen(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    _initSocket();
    _fetchUnreadCount();
  }

  @override
  void dispose() {
    SocketService().off('notification');
    super.dispose();
  }

  void _onNotificationReceived(dynamic data) {
    if (mounted) {
      setState(() {
        _unreadCount++;
      });
    }
  }

  Future<void> _initSocket() async {
    final token = await AuthService.getToken();
    if (token != null) {
      SocketService().connect(token);
      SocketService().on('notification', _onNotificationReceived);
    }
  }

  Future<void> _fetchUnreadCount() async {
    final list = await SocialService.getNotifications();
    if (mounted) {
      setState(() {
        _unreadCount = list.where((n) => n['read'] == false).length;
      });
    }
  }

  void _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    _fetchUnreadCount();
  }

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
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [cs.primary, cs.secondary],
              ).createShader(bounds),
              child: const Text(
                'TalkToss',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: cs.primary),
                onPressed: _openNotifications,
              ),
              if (_unreadCount > 0)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.85),
          border: Border(
            top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2)),
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
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
                _navItem(
                  context,
                  1,
                  Icons.chat_bubble_outline,
                  Icons.chat_bubble,
                  'Chat',
                ),
                _navItem(
                  context,
                  2,
                  Icons.person_outline,
                  Icons.person,
                  'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    int idx,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final cs = Theme.of(context).colorScheme;
    final active = _index == idx;
    return GestureDetector(
      onTap: () => setState(() => _index = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: active ? 16 : 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: active
              ? cs.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? activeIcon : icon,
              color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.5),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: active
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
