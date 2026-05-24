import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/socket_service.dart';
import '../call/call_screen.dart';
import 'ai_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final SocketService _socketService = SocketService();
  bool _searching = false;

  late AnimationController _orbController;
  late AnimationController _ringController;
  late AnimationController _glowController;
  late Animation<double> _ringAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _ringAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _initSocket();
  }

  Future<void> _initSocket() async {
    final token = await AuthService.getToken();
    if (token != null) {
      _socketService.connect(token);
      _socketService.on('match_found', (data) {
        if (mounted) {
          setState(() => _searching = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CallScreen(
                peerUid: data['peerUid'],
                peerSocketId: data['peerSocketId'],
                isOffer: data['isOffer'] ?? true,
                socketService: _socketService,
              ),
            ),
          );
        }
      });
    }
  }

  void _tapOrb() {
    if (!_socketService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connecting... please try again in a moment.'),
        ),
      );
      return;
    }
    if (_searching) {
      setState(() => _searching = false);
      _socketService.socket.emit('leave_queue');
    } else {
      setState(() => _searching = true);
      _socketService.socket.emit('join_queue');
    }
  }

  @override
  void dispose() {
    _orbController.dispose();
    _ringController.dispose();
    _glowController.dispose();
    _socketService.off('match_found');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final firstName = (user?.displayName ?? 'there').split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting ──
              Text(
                'Hey, $firstName 👋',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Who do you want to talk to today?',
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),

              // ── Cosmic Orb ──
              _orbSection(cs),
              const SizedBox(height: 32),

              // ── Quick Actions ──
              Text(
                'Quick Actions',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // Talk with AI card
              _actionCard(
                cs,
                icon: Icons.auto_awesome_rounded,
                title: 'Talk with AI',
                subtitle: 'Have a conversation with our AI assistant',
                gradientColors: [
                  const Color(0xFF7C3AED),
                  const Color(0xFFA855F7),
                ],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiChatScreen()),
                ),
              ),
              const SizedBox(height: 12),

              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _statCard(cs, Icons.call_rounded, 'Calls Made', '—'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(cs, Icons.people_rounded, 'Friends', '—'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orbSection(ColorScheme cs) {
    return Center(
      child: SizedBox(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer breathing ring
            AnimatedBuilder(
              animation: _ringAnim,
              builder: (_, _) => Container(
                width: 280 * _ringAnim.value,
                height: 280 * _ringAnim.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: cs.secondary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Inner breathing ring
            AnimatedBuilder(
              animation: _ringAnim,
              builder: (_, _) => Container(
                width: 240 * _ringAnim.value,
                height: 240 * _ringAnim.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Animated glow
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (_, _) => Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(
                        alpha: _glowAnim.value * 0.4,
                      ),
                      blurRadius: 60,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),
            ),
            // The orb
            GestureDetector(
              onTap: _tapOrb,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _searching ? 160 : 180,
                height: _searching ? 160 : 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [cs.primaryContainer, cs.primary],
                    center: Alignment.topLeft,
                    radius: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _searching ? Icons.search_rounded : Icons.call_rounded,
                        key: ValueKey(_searching),
                        color: cs.onPrimary,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searching ? 'SEARCHING...' : 'RANDOM CALL',
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
    ColorScheme cs, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(ColorScheme cs, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cs.primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
