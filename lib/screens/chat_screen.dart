import 'package:flutter/material.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  static const _activeUsers = [
    _ActiveUser(name: 'Sarah L.', initial: 'S'),
    _ActiveUser(name: 'Marcus K.', initial: 'M'),
    _ActiveUser(name: 'Elena R.', initial: 'E'),
    _ActiveUser(name: 'David W.', initial: 'D'),
  ];

  static const _chats = [
    _ChatItem(name: 'Sarah L.', message: 'That meeting was incredibly productive! Let\'s sync...', time: '12m ago', isGroup: false),
    _ChatItem(name: 'Marcus K.', message: 'Did you see the new design tokens? The gradient looks amazing.', time: '1h ago', isGroup: false),
    _ChatItem(name: 'Design Team', message: 'Elena: Check out the Cosmic Light theme draft.', time: '3h ago', isGroup: true),
    _ChatItem(name: 'Elena R.', message: 'I\'ll send over the assets by Monday morning.', time: 'Yesterday', isGroup: false),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Search
                    Container(
                      margin: const EdgeInsets.only(bottom: 28),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outlineVariant),
                        boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.04), blurRadius: 8)],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search conversations...',
                          hintStyle: TextStyle(color: cs.outline, fontSize: 16),
                          prefixIcon: Icon(Icons.search, color: cs.outline),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    // Active Now
                    Text('Active Now', style: TextStyle(color: cs.onSurface, fontSize: 24, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 90,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ..._activeUsers.map((u) => _activeUserItem(context, cs, u)),
                          _inviteItem(cs),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Recent Chats
                    Text('Recent Chats', style: TextStyle(color: cs.onSurface, fontSize: 24, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    _aiFeaturedCard(cs),
                    const SizedBox(height: 12),
                    ..._chats.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _chatCard(context, cs, c),
                    )),
                  ]),
                ),
              ),
            ],
          ),
          // FAB
          Positioned(
            bottom: 80, right: 16,
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(colors: [cs.primary, cs.primaryContainer], begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 16, spreadRadius: 2)],
              ),
              child: Icon(Icons.chat_bubble_outline, color: cs.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeUserItem(BuildContext context, ColorScheme cs, _ActiveUser user) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 56, height: 56,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: cs.primary, width: 2)),
                child: CircleAvatar(
                  backgroundColor: cs.surfaceContainer,
                  child: Text(user.initial, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
                ),
              ),
              Positioned(
                bottom: 2, right: 2,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle,
                      border: Border.all(color: cs.surface, width: 2)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(user.name, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _inviteItem(ColorScheme cs) {
    return Column(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(shape: BoxShape.circle, color: cs.surfaceContainer,
              border: Border.all(color: cs.outlineVariant)),
          child: Icon(Icons.add, color: cs.primary),
        ),
        const SizedBox(height: 6),
        Text('Invite', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _aiFeaturedCard(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.08), blurRadius: 12, spreadRadius: 1)],
        border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [cs.primary, cs.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.2), blurRadius: 8)],
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TalkToss AI', style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('Just now', style: TextStyle(color: cs.primary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('"I\'ve analyzed your project notes. Ready to summarize?"',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 14, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary)),
        ],
      ),
    );
  }

  Widget _chatCard(BuildContext context, ColorScheme cs, _ChatItem chat) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(name: chat.name))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.03), blurRadius: 8)],
        ),
        child: Row(
          children: [
            chat.isGroup
                ? Container(width: 48, height: 48,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: cs.surfaceContainer),
                    child: Icon(Icons.groups, color: cs.outline))
                : CircleAvatar(
                    radius: 24,
                    backgroundColor: cs.surfaceContainerLow,
                    child: Text(chat.name[0], style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600, fontSize: 18))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(chat.name, style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(chat.time, style: TextStyle(color: cs.outline, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(chat.message, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveUser {
  final String name;
  final String initial;
  const _ActiveUser({required this.name, required this.initial});
}

class _ChatItem {
  final String name;
  final String message;
  final String time;
  final bool isGroup;
  const _ChatItem({required this.name, required this.message, required this.time, required this.isGroup});
}
