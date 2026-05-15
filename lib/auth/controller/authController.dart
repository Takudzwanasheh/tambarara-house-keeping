import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tambarara_house_keeping/utils/contants.dart';

class AuthController {
  static const String _baseUrl = Constants.baseUrl;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('${Constants.baseUrl}/user/login');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 60));

      // Debug prints - IMPORTANT for debugging
      debugPrint('=== LOGIN DEBUG ===');
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      debugPrint('Response headers: ${response.headers}');
      debugPrint('===================');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          debugPrint('Parsed JSON data: $data');

          String role = 'ADMIN'; 
          if (data['role'] != "ADMIN") {
            role = data['role'].toString().toUpperCase();
          } else if (data['Role'] != "ADMIN") {
            role = data['Role'].toString().toUpperCase();
          }

          await _saveUserSession({
            'username': data['username'] ?? username,
            'role': data['role'] ?? 'staff',
            'email': data['email'] ?? '',
            'isAdmin':
                (data['role'] ?? 'staff').toString().toLowerCase() == 'admin',
          });

          return {
            'success': true,
            'message': data['message'] ?? 'Login successful',
            'role': data['role'] ?? 'staff',
            'username': data['username'] ?? username,
            'isAdmin':
                (data['role'] ?? 'staff').toString().toLowerCase() == 'admin',
          };
        } catch (e) {
          String message = response.body;
          String extractedUsername = username;

          if (message.contains('Login successful for user:')) {
            final parts = message.split(':');
            if (parts.length > 1) {
              extractedUsername = parts[1].trim();
            }
          }

          // Save user session
          await _saveUserSession({
            'username': extractedUsername,
            'role': 'ADMIN',
            'email': '',
            'isAdmin': true,
          });

          return {
            'success': true,
            'message': message,
            'role': 'ADMIN',
            'username': extractedUsername,
            'isAdmin': false,
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Login failed. Invalid credentials.',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timeout. Please try again.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  Future<void> _saveUserSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userKey);
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?['isAdmin'] ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_tokenKey);
  }
}
