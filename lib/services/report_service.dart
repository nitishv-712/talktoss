import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/env.dart';

class ReportService {
  static String get baseUrl => Env.serverUrl;

  static Future<bool> reportUser(String reportedUserId, String reason) async {
    final token = await AuthService.getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/report/user'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'reportedUserId': reportedUserId, 'reason': reason}),
    );
    return res.statusCode == 200;
  }
}
