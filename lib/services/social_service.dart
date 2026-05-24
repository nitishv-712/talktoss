import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'auth_service.dart';

class SocialService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<dynamic>> searchUsers(String query) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${Env.serverUrl}/social/users/search?q=${Uri.encodeComponent(query)}');
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (e) {
      print('[SocialService] searchUsers error: $e');
    }
    return [];
  }

  static Future<bool> sendFriendRequest(String receiverId) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse('${Env.serverUrl}/social/friend-request'),
        headers: headers,
        body: jsonEncode({'receiverId': receiverId}),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('[SocialService] sendFriendRequest error: $e');
    }
    return false;
  }

  static Future<bool> respondToFriendRequest(String requestId, String action) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse('${Env.serverUrl}/social/friend-request/respond'),
        headers: headers,
        body: jsonEncode({'requestId': requestId, 'action': action}),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('[SocialService] respondToFriendRequest error: $e');
    }
    return false;
  }

  static Future<List<dynamic>> getFriends() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse('${Env.serverUrl}/social/friends'), headers: headers);
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (e) {
      print('[SocialService] getFriends error: $e');
    }
    return [];
  }

  static Future<List<dynamic>> getNotifications() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse('${Env.serverUrl}/social/notifications'), headers: headers);
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (e) {
      print('[SocialService] getNotifications error: $e');
    }
    return [];
  }

  static Future<void> markNotificationsRead() async {
    try {
      final headers = await _getHeaders();
      await http.post(Uri.parse('${Env.serverUrl}/social/notifications/read'), headers: headers);
    } catch (e) {
      print('[SocialService] markNotificationsRead error: $e');
    }
  }

  static Future<List<dynamic>> getChatMessages(String friendId) async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse('${Env.serverUrl}/social/chats/$friendId'), headers: headers);
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
    } catch (e) {
      print('[SocialService] getChatMessages error: $e');
    }
    return [];
  }
}
