import 'package:flutter/material.dart';
import '../services/social_service.dart';
import '../services/socket_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String friendId;
  final String name;
  final String? avatar;
  final bool isOnline;
  
  const ChatDetailScreen({
    super.key,
    required this.friendId,
    required this.name,
    this.avatar,
    this.isOnline = true,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<_Message> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();

    // Listen for incoming messages in real-time
    SocketService().on('receive_message', _onMessageReceived);
  }

  @override
  void dispose() {
    SocketService().off('receive_message');
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMessageReceived(dynamic data) {
    // Only append if the message is from this friend
    if (data['sender'] == widget.friendId && mounted) {
      setState(() {
        _messages.add(_Message(
          text: data['text'] ?? '',
          isMe: false,
          time: _formatMsgTime(data['createdAt']),
        ));
      });
      _scrollToBottom();
    }
  }

  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    final history = await SocialService.getChatMessages(widget.friendId);
    if (mounted) {
      setState(() {
        _messages = history.map((m) {
          final sender = m['sender'];
          final isMe = sender != widget.friendId;
          return _Message(
            text: m['text'] ?? '',
            isMe: isMe,
            time: _formatMsgTime(m['createdAt']),
          );
        }).toList();
        _loading = false;
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Emit event via Socket.IO
    SocketService().socket.emit('send_message', {
      'receiverId': widget.friendId,
      'text': text,
    });

    setState(() {
      _messages.add(_Message(text: text, isMe: true, time: _timeNow()));
      _controller.clear();
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _timeNow() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _formatMsgTime(dynamic dateStr) {
    if (dateStr == null) return _timeNow();
    try {
      final date = DateTime.parse(dateStr.toString()).toLocal();
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return _timeNow();
    }
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
                  backgroundImage: widget.avatar != null ? NetworkImage(widget.avatar!) : null,
                  child: widget.avatar == null
                      ? Text(widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                          style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600))
                      : null,
                ),
                if (widget.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.surface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name,
                      style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                  if (widget.isOnline)
                    Text('Online', style: TextStyle(color: const Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildMessage(cs, _messages[index]),
                      );
                    },
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
              gradient: msg.isMe
                  ? LinearGradient(
                      colors: [cs.primary, cs.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: msg.isMe ? null : cs.surfaceContainerLow,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                bottomRight: Radius.circular(msg.isMe ? 4 : 16),
              ),
              border: msg.isMe ? null : Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: msg.isMe ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: msg.isMe ? const Offset(0, 4) : Offset.zero,
                )
              ],
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

  Widget _buildInput(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.4), fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: TextStyle(color: cs.onSurface, fontSize: 14),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [cs.primary, cs.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [
                    BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 1)
                  ],
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
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
