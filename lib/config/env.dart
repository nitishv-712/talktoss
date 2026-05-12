import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get serverUrl => dotenv.env['SERVER_URL'] ?? '';
  static String get turnUrl => dotenv.env['TURN_URL'] ?? '';
  static String get turnUsername => dotenv.env['TURN_USERNAME'] ?? '';
  static String get turnCredential => dotenv.env['TURN_CREDENTIAL'] ?? '';
}
