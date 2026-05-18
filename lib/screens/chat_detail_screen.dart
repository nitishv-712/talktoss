import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final String name;
  final bool isOnline;
  const ChatDetailScreen({super.key, this.name = 'Sasha', this.isOnline = true});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final _messages = <_Message>[
    _Message(text: "Hey! Are we still on for the cosmic design review later today? 🌌", isMe: false, time: '14:02'),
    _Message(text: "Absolutely! I've been refining the translucent layers for the Glassmorphism cards. Think you'll like the progress.", isMe: true, time: '14:05'),
    _Message(text: "Perfect. Can you also bring those spatial rhythm docs? I want to make sure the fluid grid is mathematically aligned.", isMe: false, time: '14:08'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, isMe: true, time: _timeNow()));
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  String _timeNow() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 32,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.primary),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: cs.surfaceContainer,
                  child: Text(widget.name[0], style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
                ),
                if (widget.isOnline)
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(color: cs.secondary, shape: BoxShape.circle,
                          border: Border.all(color: cs.surface, width: 1.5)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name, style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                if (widget.isOnline)
                  Text('Online', style: TextStyle(color: cs.secondary, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
            child: Row(
              children: [
                Icon(Icons.call, color: cs.primary, size: 16),
                const SizedBox(width: 4),
                Text('On Call', style: TextStyle(color: cs.primary, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          IconButton(icon: Icon(Icons.more_vert, color: cs.onSurface.withValues(alpha: 0.6)), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: BorderRadius.circular(999)),
                    child: Text('TODAY', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 16),
                ..._messages.map((m) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildMessage(cs, m))),
                _buildAiBridge(cs),
                const SizedBox(height: 16),
                _buildTypingIndicator(cs),
              ],
            ),
          ),
          _buildInput(cs),
        ],
      ),
    );
  }

  Widget _buildMessage(ColorScheme cs, _Message msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: msg.isMe ? LinearGradient(colors: [cs.primary, cs.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
              color: msg.isMe ? null : cs.surfaceContainerLow,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                bottomRight: Radius.circular(msg.isMe ? 4 : 16),
              ),
              border: msg.isMe ? null : Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
              boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: msg.isMe ? 0.2 : 0.05), blurRadius: 8, offset: msg.isMe ? const Offset(0, 4) : Offset.zero)],
            ),
            child: Text(msg.text, style: TextStyle(color: msg.isMe ? Colors.white : cs.onSurface, fontSize: 14, height: 1.5)),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: msg.isMe ? 0 : 4, right: msg.isMe ? 4 : 0),
            child: Text(msg.time, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildAiBridge(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.auto_awesome, color: cs.primary, size: 18),
            const SizedBox(width: 6),
            Text('LIVE AI BRIDGE', style: TextStyle(color: cs.primary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
          ]),
          const SizedBox(height: 10),
          Text('"Sasha is looking for the updated UI specs for the \'Cosmic Pulse\' theme. Mention the new 8px spatial rhythm."',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 12, fontStyle: FontStyle.italic, height: 1.5)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _aiBridgeChip(cs, '"I\'ll bring the 8px grid specs!"'),
            _aiBridgeChip(cs, '"Send spatial rhythm docs"'),
          ]),
        ],
      ),
    );
  }

  Widget _aiBridgeChip(ColorScheme cs, String label) {
    return GestureDetector(
      onTap: () => setState(() => _controller.text = label.replaceAll('"', '')),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: cs.outlineVariant)),
        child: Text(label, style: TextStyle(color: cs.primary, fontSize: 11, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildTypingIndicator(ColorScheme cs) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Opacity(
        opacity: 0.5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => Container(
            width: 6, height: 6,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary),
          )),
        ),
      ),
    );
  }

  Widget _buildInput(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: cs.onSurface.withValues(alpha: 0.6)),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.4), fontSize: 14),
                            border: InputBorder.none, isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          style: TextStyle(color: cs.onSurface, fontSize: 14),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.sentiment_satisfied_outlined, color: cs.onSurface.withValues(alpha: 0.5), size: 20),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [cs.primary, cs.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 1)],
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icons.image_outlined, Icons.mic_none, Icons.location_on_outlined, Icons.description_outlined]
                .map((icon) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(icon, color: cs.onSurface.withValues(alpha: 0.5), size: 24),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isMe;
  final String time;
  const _Message({required this.text, required this.isMe, required this.time});
}
