import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/socket_service.dart';
import '../call/call_screen.dart';

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
  late Animation<double> _ringAnim;

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
    _socketService.off('match_found');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: _orbSection(cs),
          ),
        ),
      ),
    );
  }

  Widget _orbSection(ColorScheme cs) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Connect Instantly',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the cosmic orb to jump into a random global session',
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.6),
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _ringAnim,
                  builder: (_, a) => Container(
                    width: 300 * _ringAnim.value,
                    height: 300 * _ringAnim.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.secondary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _ringAnim,
                  builder: (_, b) => Container(
                    width: 260 * _ringAnim.value,
                    height: 260 * _ringAnim.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _tapOrb,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _searching ? 180 : 200,
                    height: _searching ? 180 : 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [cs.primaryContainer, cs.primary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.45),
                          blurRadius: 48,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searching ? Icons.search : Icons.rocket_launch,
                          color: cs.onPrimary,
                          size: 54,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _searching ? 'SEARCHING...' : 'TAP TO CALL',
                          style: TextStyle(
                            color: cs.onPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
