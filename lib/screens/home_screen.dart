import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';
import 'call_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SocketService _socketService = SocketService();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _startSearch() async {
    setState(() => _searching = true);
    _socketService.socket.emit('join_queue');
  }

  void _cancelSearch() {
    setState(() => _searching = false);
    _socketService.socket.emit('leave_queue');
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TalkToss')),
      body: Center(
        child: _searching
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  const Text('Finding someone to talk to...'),
                  const SizedBox(height: 16),
                  TextButton(onPressed: _cancelSearch, child: const Text('Cancel')),
                ],
              )
            : ElevatedButton.icon(
                onPressed: _startSearch,
                icon: const Icon(Icons.phone),
                label: const Text('Start'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
              ),
      ),
    );
  }
}
