import 'package:flutter/material.dart';
import '../../services/social_service.dart';
import 'chat_detail_screen.dart';
import 'search_users_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> _friends = [];
  List<dynamic> _filteredFriends = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _searchController.addListener(_filterFriends);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    setState(() => _loading = true);
    final list = await SocialService.getFriends();
    if (mounted) {
      setState(() {
        _friends = list;
        _filteredFriends = list;
        _loading = false;
      });
    }
  }

  void _filterFriends() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFriends = _friends.where((f) {
        final name = (f['name'] ?? '').toString().toLowerCase();
        final email = (f['email'] ?? '').toString().toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final onlineFriends = _friends.where((f) => f['isOnline'] == true).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadFriends,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Search Bar
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: cs.onSurface, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search friends...',
                        hintStyle: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.4),
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: cs.primary,
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    // Active Now Section
                    Text(
                      'Active Now',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 96,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...onlineFriends.map(
                            (f) => _activeUserItem(context, cs, f),
                          ),
                          _searchUsersButton(cs),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Friends List Section
                    Text(
                      'Friends',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_filteredFriends.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 48,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cs.primary.withValues(alpha: 0.1),
                              ),
                              child: Icon(
                                Icons.forum_outlined,
                                size: 32,
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _searchController.text.isEmpty
                                  ? "No friends yet"
                                  : "No search results",
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isEmpty
                                  ? "Connect with people globally by tapping the button below or start a random voice call!"
                                  : "We couldn't find anyone matching your search query. Try another name.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.5),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                            if (_searchController.text.isEmpty) ...[
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SearchUsersScreen(),
                                    ),
                                  );
                                  _loadFriends();
                                },
                                icon: const Icon(
                                  Icons.search_rounded,
                                  size: 18,
                                ),
                                label: const Text('Find Friends'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cs.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      ..._filteredFriends.map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _chatCard(context, cs, f),
                        ),
                      ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 72),
      //   child: Container(
      //     decoration: BoxDecoration(
      //       shape: BoxShape.circle,
      //       gradient: LinearGradient(
      //         colors: [cs.primary, cs.secondary],
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //       ),
      //       boxShadow: [
      //         BoxShadow(
      //           color: cs.primary.withValues(alpha: 0.3),
      //           blurRadius: 12,
      //           offset: const Offset(0, 4),
      //         ),
      //       ],
      //     ),
      //     child: FloatingActionButton(
      //       heroTag: 'chat_fab',
      //       onPressed: () async {
      //         await Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (_) => const SearchUsersScreen()),
      //         );
      //         _loadFriends();
      //       },
      //       backgroundColor: Colors.transparent,
      //       foregroundColor: Colors.white,
      //       elevation: 0,
      //       highlightElevation: 0,
      //       shape: const CircleBorder(),
      //       child: const Icon(Icons.add_rounded, size: 28),
      //     ),
      //   ),
      // ),
    );
  }

  Widget _activeUserItem(BuildContext context, ColorScheme cs, dynamic user) {
    final name = user['name'] ?? 'Anonymous';
    final avatar = user['avatar'];
    final initial = name.isNotEmpty ? name[0] : '?';

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              friendId: user['_id'] ?? user['id'],
              name: name,
              avatar: avatar,
              isOnline: true,
            ),
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.15),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surface,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      backgroundColor: cs.surfaceContainer,
                      backgroundImage: avatar != null
                          ? NetworkImage(avatar)
                          : null,
                      child: avatar == null
                          ? Text(
                              initial.toUpperCase(),
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.surface, width: 2.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 60,
              child: Text(
                name.split(' ')[0],
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchUsersButton(ColorScheme cs) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchUsersScreen()),
        );
        _loadFriends();
      },
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surfaceContainerLow,
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Icon(Icons.add_rounded, color: cs.primary, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            'Add',
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _chatCard(BuildContext context, ColorScheme cs, dynamic user) {
    final name = user['name'] ?? 'Anonymous';
    final avatar = user['avatar'];
    final initial = name.isNotEmpty ? name[0] : '?';
    final isOnline = user['isOnline'] ?? false;
    final friendId = user['_id'] ?? user['id'];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            friendId: friendId,
            name: name,
            avatar: avatar,
            isOnline: isOnline,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: avatar == null
                        ? LinearGradient(
                            colors: [
                              cs.primary.withValues(alpha: 0.8),
                              cs.secondary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: avatar == null
                        ? Colors.transparent
                        : cs.surfaceContainerLow,
                    backgroundImage: avatar != null
                        ? NetworkImage(avatar)
                        : null,
                    child: avatar == null
                        ? Text(
                            initial.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOnline ? 'Online • Tap to chat' : 'Offline • Tap to chat',
                    style: TextStyle(
                      color: isOnline
                          ? cs.primary.withValues(alpha: 0.8)
                          : cs.onSurface.withValues(alpha: 0.4),
                      fontSize: 13,
                      fontWeight: isOnline
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurface.withValues(alpha: 0.25),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
