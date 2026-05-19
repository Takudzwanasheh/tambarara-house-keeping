import 'package:tambarara_house_keeping/auth/controller/authController.dart';

class Permissions {
  static const List<String> adminOnly = ['ADMIN'];
  static const List<String> adminAndStaff = ['ADMIN', 'STAFF'];
  static const List<String> allUsers = ['ADMIN', 'STAFF', 'USER'];

  static Future<bool> canAccess(List<String> allowedRoles) async {
    final auth = AuthController();
    final role = await auth.getUserRole();
    return allowedRoles.contains(role);
  }

  static Future<bool> isAdmin() async {
    return await AuthController().isAdmin();
  }

  static Future<bool> isStaff() async {
    return await AuthController().isStaff();
  }

  static Future<bool> isUser() async {
    return await AuthController().isUser();
  }
}