import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/socket_service.dart';
import '../../services/webrtc_service.dart';

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

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  late WebRTCService _webrtc;
  bool _muted = false;
  bool _speakerOn = true;
  int _seconds = 0;
  Timer? _timer;
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
    _initCall();
  }

  Future<void> _initCall() async {
    _webrtc = WebRTCService(
      socketService: widget.socketService,
      peerSocketId: widget.peerSocketId,
    );
    await _webrtc.init(isOffer: widget.isOffer);
    widget.socketService.on(
      'offer',
      (data) => _webrtc.handleOffer(data['sdp']),
    );
    widget.socketService.on(
      'answer',
      (data) => _webrtc.handleAnswer(data['sdp']),
    );
    widget.socketService.on(
      'ice_candidate',
      (data) => _webrtc.addIceCandidate(data['candidate']),
    );
    widget.socketService.on('call_end', (_) => _endCall(notify: false));
  }

  String get _timerLabel {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
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

  Future<void> _showMoreSheet() async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.flag_outlined, color: cs.error),
              title: Text(
                'Report user',
                style: TextStyle(color: cs.error, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _reportUser();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.block,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
              title: Text('Block user', style: TextStyle(color: cs.onSurface)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reportUser() async {
    final cs = Theme.of(context).colorScheme;
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Report User', style: TextStyle(color: cs.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Abusive Language', 'Spam', 'Inappropriate']
              .map(
                (l) => ListTile(
                  title: Text(l),
                  onTap: () => Navigator.pop(ctx, l),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (reason != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reported: $reason')));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
    _pulseController.dispose();
    _webrtc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.secondary.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      _headerBtn(
                        cs,
                        Icons.keyboard_arrow_down,
                        () => _endCall(),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'ON CALL',
                              style: TextStyle(
                                color: cs.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _timerLabel,
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      _headerBtn(cs, Icons.add_call, () {}),
                    ],
                  ),
                ),
                // Main
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: ScaleTransition(
                          scale: _pulseAnim,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cs.primary.withValues(alpha: 0.2),
                                    width: 4,
                                  ),
                                ),
                              ),
                              Container(
                                width: 240,
                                height: 240,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cs.secondary.withValues(alpha: 0.15),
                                    width: 1,
                                  ),
                                ),
                              ),
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [cs.primary, cs.secondary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cs.primary.withValues(alpha: 0.2),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 80,
                                  color: cs.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Anonymous',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified, color: cs.secondary, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'ID: ${widget.peerUid}',
                              style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.6),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      _buildWaveform(cs),
                    ],
                  ),
                ),
                // Dock
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.05),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _dockBtn(
                              cs,
                              icon: _muted ? Icons.mic_off : Icons.mic,
                              label: _muted ? 'Unmute' : 'Mute',
                              active: _muted,
                              onTap: _toggleMute,
                            ),
                          ),
                          Expanded(
                            child: _dockBtn(
                              cs,
                              icon: Icons.apps,
                              label: 'Keypad',
                              onTap: () {},
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => _endCall(),
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: cs.error,
                                      boxShadow: [
                                        BoxShadow(
                                          color: cs.error.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.call_end,
                                      color: cs.onError,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'End',
                                  style: TextStyle(
                                    color: cs.error,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _dockBtn(
                              cs,
                              icon: _speakerOn
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                              label: 'Speaker',
                              active: _speakerOn,
                              onTap: () =>
                                  setState(() => _speakerOn = !_speakerOn),
                            ),
                          ),
                          Expanded(
                            child: _dockBtn(
                              cs,
                              icon: Icons.more_horiz,
                              label: 'More',
                              onTap: _showMoreSheet,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBtn(ColorScheme cs, IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.surfaceContainer.withValues(alpha: 0.5),
          ),
          child: Icon(icon, color: cs.onSurface.withValues(alpha: 0.6)),
        ),
      );

  Widget _dockBtn(
    ColorScheme cs, {
    required IconData icon,
    required String label,
    bool active = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? cs.primary.withValues(alpha: 0.12)
                  : cs.surfaceContainerLow,
            ),
            child: Icon(
              icon,
              color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform(ColorScheme cs) {
    final heights = [
      16.0,
      32.0,
      48.0,
      24.0,
      40.0,
      56.0,
      32.0,
      48.0,
      20.0,
      36.0,
    ];
    final delays = [0.0, 0.2, 0.4, 0.1, 0.3, 0.5, 0.2, 0.4, 0.1, 0.3];
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          heights.length,
          (i) => AnimatedBuilder(
            animation: _waveController,
            builder: (_, x) {
              final offset = sin((_waveController.value + delays[i]) * pi);
              final h = heights[i] * (0.4 + 0.6 * ((offset + 1) / 2));
              return Container(
                width: 4,
                height: h,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.secondary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
