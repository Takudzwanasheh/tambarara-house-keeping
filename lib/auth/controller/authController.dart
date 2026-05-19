import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tambarara_house_keeping/utils/contants.dart';

  // User roles enum
  enum UserRole {
  ADMIN,
  STAFF,
  USER,
  }
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

  debugPrint('=== LOGIN DEBUG ===');
  debugPrint('Response status: ${response.statusCode}');
  debugPrint('Response body: ${response.body}');
  debugPrint('===================');

  if (response.statusCode == 200) {
  // Parse JSON response
  final data = jsonDecode(response.body);

  // Extract role from backend response
  String role = _extractRoleFromResponse(data);
  String token = data['token'] ?? data['accessToken'] ?? '';

  // Save user session with role from backend
  await _saveUserSession({
  'id': data['id'] ?? data['userId'],
  'username': data['username'] ?? username,
  'email': data['email'] ?? '',
  'role': role,
  'fullName': data['fullName'] ?? data['name'] ?? data['username'] ?? username,
  'isAdmin': role == 'ADMIN',
  'permissions': data['permissions'] ?? [],
  'department': data['department'] ?? '',
  'token': token,
  });

  // Save token separately for API calls
  if (token.isNotEmpty) {
  await _saveToken(token);
  }

  return {
  'success': true,
  'message': data['message'] ?? 'Login successful',
  'role': role,
  'username': data['username'] ?? username,
  'isAdmin': role == 'ADMIN',
  'token': token,
  };
  } else if (response.statusCode == 401) {
  return {
  'success': false,
  'message': 'Invalid username or password.',
  };
  } else {
  String errorMessage = 'Login failed. Please try again.';
  try {
  final errorData = jsonDecode(response.body);
  errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
  } catch (e) {
  errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
  }
  return {
  'success': false,
  'message': errorMessage,
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

  // Extract role from backend response
  String _extractRoleFromResponse(Map<String, dynamic> data) {
  // Try different possible field names from backend
  String role = data['role'] ??
  data['userRole'] ??
  data['userType'] ??
  data['authority'] ??
  data['Role'] ??
  'USER';

  // Normalize to uppercase
  String roleUpper = role.toString().toUpperCase();

  // Map backend role values to standard roles
  if (roleUpper.contains('ADMIN')) {
  return 'ADMIN';
  } else if (roleUpper.contains('STAFF') || roleUpper.contains('HOUSEKEEPER') || roleUpper.contains('CLEANER')) {
  return 'STAFF';
  } else {
  return 'USER';
  }
  }

  Future<void> _saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_tokenKey);
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

  // Role-based check methods using stored user data
  Future<bool> isAdmin() async {
  final user = await getCurrentUser();
  return user?['isAdmin'] ?? false;
  }

  Future<String> getUserRole() async {
  final user = await getCurrentUser();
  return user?['role'] ?? 'USER';
  }

  Future<bool> isStaff() async {
  final role = await getUserRole();
  return role == 'STAFF';
  }

  Future<bool> isUser() async {
  final role = await getUserRole();
  return role == 'USER';
  }

  Future<bool> hasPermission(String permission) async {
  final user = await getCurrentUser();
  final permissions = user?['permissions'] ?? [];
  return permissions.contains(permission);
  }

  Future<bool> hasAnyPermission(List<String> permissions) async {
  final user = await getCurrentUser();
  final userPermissions = user?['permissions'] ?? [];
  return permissions.any((p) => userPermissions.contains(p));
  }

  Future<bool> hasAllPermissions(List<String> permissions) async {
  final user = await getCurrentUser();
  final userPermissions = user?['permissions'] ?? [];
  return permissions.every((p) => userPermissions.contains(p));
  }

  Future<bool> hasRole(List<String> allowedRoles) async {
  final role = await getUserRole();
  return allowedRoles.contains(role);
  }

  Future<String> getUsername() async {
  final user = await getCurrentUser();
  return user?['username'] ?? 'User';
  }

  Future<String> getFullName() async {
  final user = await getCurrentUser();
  return user?['fullName'] ?? user?['username'] ?? 'User';
  }

  Future<String?> getUserId() async {
  final user = await getCurrentUser();
  return user?['id']?.toString();
  }

  Future<Map<String, dynamic>> refreshUserData() async {
  try {
  final token = await getToken();
  if (token == null) {
  return {'success': false, 'message': 'No token found'};
  }

  final response = await http.get(
  Uri.parse('${Constants.baseUrl}/auth/me'),
  headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
  },
  );

  if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  String role = _extractRoleFromResponse(data);

  await _saveUserSession({
  'id': data['id'],
  'username': data['username'],
  'email': data['email'],
  'role': role,
  'fullName': data['fullName'] ?? data['name'],
  'isAdmin': role == 'ADMIN',
  'permissions': data['permissions'] ?? [],
  'department': data['department'] ?? '',
  });

  return {'success': true, 'data': data};
  } else {
  return {'success': false, 'message': 'Failed to refresh user data'};
  }
  } catch (e) {
  return {'success': false, 'message': e.toString()};
  }
  }

  Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_userKey);
  await prefs.remove(_isLoggedInKey);
  await prefs.remove(_tokenKey);
  }
}