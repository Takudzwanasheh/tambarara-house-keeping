import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthController {
  static const String _baseUrl = 'http://192.168.1.104:8080';
  static const int _timeoutSeconds = 10;

  Future<Map<String, dynamic>> login(String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'pin': pin}),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          return {
            'success': true,
            'role': responseData['role'],
            'message': 'Login successful',
          };
        case 401:
          return {
            'success': false,
            'message': 'Invalid Staff PIN. Please try again.',
          };
        case 403:
          return {
            'success': false,
            'message': 'Account is disabled. Contact administrator.',
          };
        case 500:
          return {
            'success': false,
            'message': 'Server error. Please try again later.',
          };
        default:
          return {
            'success': false,
            'message': responseData['message'] ?? 'An unexpected error occurred.',
          };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No Internet connection or server is unreachable.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timed out. Please try again.',
      };
    } on FormatException {
      return {
        'success': false,
        'message': 'Invalid response format from server.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }
}
