import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';
import 'call_screen.dart';

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

  static const _lounges = [
    _Lounge(
      title: 'Minimalist Design Systems',
      active: 142,
      icon: Icons.palette_outlined,
      useSecondary: true,
    ),
    _Lounge(
      title: 'Crypto Market Pulse',
      active: 89,
      icon: Icons.currency_bitcoin,
      useSecondary: false,
    ),
  ];

  static const _trending = [
    _TrendingItem(
      title: 'Electronic Music Production',
      host: '@vibrant_beats',
      listeners: '432',
      tag: 'Music',
    ),
    _TrendingItem(
      title: 'Startup Founders Circle',
      host: '@venture_hub',
      listeners: '891',
      tag: 'Business',
    ),
    _TrendingItem(
      title: 'Web3 Engineering Deep Dive',
      host: '@chain_master',
      listeners: '256',
      tag: 'Dev',
    ),
  ];

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
    _socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _aiBanner(cs),
            const SizedBox(height: 32),
            _orbSection(cs),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Global Lounges',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Active discussions happening right now',
                            style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: Text(
                          'See All',
                          style: TextStyle(color: cs.primary, fontSize: 13),
                        ),
                        label: Icon(
                          Icons.arrow_forward,
                          color: cs.primary,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _featuredLoungeCard(cs),
                  const SizedBox(height: 12),
                  Row(
                    children: _lounges
                        .map(
                          (l) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: l == _lounges.last ? 0 : 12,
                              ),
                              child: _smallLoungeCard(cs, l),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  _breakingNewsCard(cs),
                  const SizedBox(height: 32),
                  Text(
                    'Trending Lounges',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._trending.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _trendingItem(cs, t),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiBanner(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unlock Fluidity with AI Pulse',
            style: TextStyle(
              color: cs.onPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Experience zero-latency voice translation and intelligent conversational bridging.',
            style: TextStyle(
              color: cs.onPrimary.withValues(alpha: 0.8),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                'Start Session',
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orbSection(ColorScheme cs) {
    return Column(
      children: [
        Text(
          'Connect Instantly',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Tap the cosmic orb to jump into a random global session',
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _ringAnim,
                builder: (_, a) => Container(
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
              AnimatedBuilder(
                animation: _ringAnim,
                builder: (_, b) => Container(
                  width: 240 * _ringAnim.value,
                  height: 240 * _ringAnim.value,
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
                  width: _searching ? 160 : 180,
                  height: _searching ? 160 : 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [cs.primaryContainer, cs.primary],
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
                      Icon(
                        _searching ? Icons.search : Icons.rocket_launch,
                        color: cs.onPrimary,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searching ? 'SEARCHING...' : 'TAP TO CALL',
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
      ],
    );
  }

  Widget _featuredLoungeCard(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: cs.primary.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 160,
              color: cs.surfaceContainer,
              child: Center(
                child: Icon(Icons.groups, size: 64, color: cs.primary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _tag(cs, 'LIVE', cs.primary),
                    const SizedBox(width: 8),
                    _tag(cs, 'Tech Ethics', cs.secondary),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'The Future of AI Autonomy',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ...List.generate(
                          3,
                          (i) => Transform.translate(
                            offset: Offset(i * -8.0, 0),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: [
                                  cs.primary,
                                  cs.secondary,
                                  cs.primaryContainer,
                                ][i],
                                border: Border.all(color: cs.surface, width: 2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.surfaceContainer,
                            border: Border.all(color: cs.surface, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '+42',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.group,
                          size: 14,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '1.2k listening',
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallLoungeCard(ColorScheme cs, _Lounge lounge) {
    final color = lounge.useSecondary ? cs.secondary : cs.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: cs.primary.withValues(alpha: 0.03), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(lounge.icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            lounge.title,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${lounge.active} active',
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakingNewsCard(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: cs.primary.withValues(alpha: 0.03), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.error,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Breaking News',
                      style: TextStyle(
                        color: cs.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Global Space Summit: Mars Colony Updates',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 80,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: cs.surfaceContainer,
            ),
            child: Icon(Icons.rocket_launch, color: cs.primary, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _trendingItem(ColorScheme cs, _TrendingItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surfaceContainer,
            ),
            child: Icon(Icons.headphones, color: cs.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Hosted by ${item.host}',
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.listeners} listening',
                style: TextStyle(color: cs.onSurface, fontSize: 12),
              ),
              Text(
                item.tag,
                style: TextStyle(color: cs.secondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Icon(Icons.add_circle_outline, color: cs.primary),
        ],
      ),
    );
  }

  Widget _tag(ColorScheme cs, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Lounge {
  final String title;
  final int active;
  final IconData icon;
  final bool useSecondary;
  const _Lounge({
    required this.title,
    required this.active,
    required this.icon,
    required this.useSecondary,
  });
}

class _TrendingItem {
  final String title;
  final String host;
  final String listeners;
  final String tag;
  const _TrendingItem({
    required this.title,
    required this.host,
    required this.listeners,
    required this.tag,
  });
}
