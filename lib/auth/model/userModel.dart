class User {
  final String username;
  final String password;
  final String email;
  final String role;
  final String? token;

  User({
    required this.username,
    required this.password,
    required this.email,
    required this.role,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'role': role,
      'token': token,
    };
  }
}