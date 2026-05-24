import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get serverUrl => dotenv.env['SERVER_URL'] ?? '';
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
}
