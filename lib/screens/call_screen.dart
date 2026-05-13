import 'package:flutter/material.dart';
import '../services/socket_service.dart';
import '../services/webrtc_service.dart';

class CallScreen extends StatefulWidget {
  final String peerUid;
  final String peerSocketId;
  final bool isOffer;
  final SocketService socketService;

  const CallScreen({
    super.key,
    required this.peerUid,
    required this.peerSocketId,
    required this.isOffer,
    required this.socketService,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late WebRTCService _webrtc;
  bool _muted = false;
  bool _speakerOn = true;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    _webrtc = WebRTCService(socketService: widget.socketService, peerSocketId: widget.peerSocketId);
    await _webrtc.init(isOffer: widget.isOffer);

    widget.socketService.on('offer', (data) => _webrtc.handleOffer(data['sdp']));
    widget.socketService.on('answer', (data) => _webrtc.handleAnswer(data['sdp']));
    widget.socketService.on('ice_candidate', (data) => _webrtc.addIceCandidate(data['candidate']));
    widget.socketService.on('call_end', (_) => _endCall(notify: false));
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _webrtc.toggleMute(_muted);
  }

  void _endCall({bool notify = true}) {
    if (notify) widget.socketService.endCall(widget.peerSocketId);
    _webrtc.dispose();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _reportUser() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('Abusive Language'), onTap: () => Navigator.pop(ctx, 'Abusive')),
            ListTile(title: const Text('Spam'), onTap: () => Navigator.pop(ctx, 'Spam')),
            ListTile(title: const Text('Inappropriate'), onTap: () => Navigator.pop(ctx, 'Inappropriate')),
          ],
        ),
      ),
    );
    if (reason != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User reported')));
    }
  }

  @override
  void dispose() {
    _webrtc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.report, color: Colors.red),
                    onPressed: _reportUser,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Icon(Icons.person, size: 100, color: Colors.white),
                const SizedBox(height: 16),
                const Text('Connected', style: TextStyle(color: Colors.white, fontSize: 24)),
                const SizedBox(height: 8),
                Text('ID: ${widget.peerUid}',
                    style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'mute',
                    onPressed: _toggleMute,
                    backgroundColor: _muted ? Colors.red : Colors.grey,
                    child: Icon(_muted ? Icons.mic_off : Icons.mic),
                  ),
                  FloatingActionButton(
                    heroTag: 'end',
                    onPressed: () => _endCall(),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.call_end),
                  ),
                  FloatingActionButton(
                    heroTag: 'speaker',
                    onPressed: () => setState(() => _speakerOn = !_speakerOn),
                    backgroundColor: _speakerOn ? Colors.blue : Colors.grey,
                    child: Icon(_speakerOn ? Icons.volume_up : Icons.volume_off),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
