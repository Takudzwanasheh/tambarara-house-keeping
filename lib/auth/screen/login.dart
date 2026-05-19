import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tambarara_house_keeping/auth/controller/authController.dart';

import '../../features/housekeeping/screen/DashboadrdScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _usernameController = TextEditingController();

  // Focus nodes for keyboard management
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _pinFocusNode = FocusNode();

  late final AuthController _authController;
  bool _isLoading = false;
  bool _obscurePin = true;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();

    // Delay to ensure widget is fully built before focusing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Auto-focus username field when screen loads
      FocusScope.of(context).requestFocus(_usernameFocusNode);
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Dismiss keyboard
      _usernameFocusNode.unfocus();
      _pinFocusNode.unfocus();
      FocusScope.of(context).unfocus();

      // Small delay for keyboard to dismiss
      await Future.delayed(const Duration(milliseconds: 150));

      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _authController.login(
          _usernameController.text.trim(),
          _pinController.text.trim(),
        );

        debugPrint('Login Result: $result');

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (result['success'] == true) {
            final bool isAdmin = result['isAdmin'] ?? false;
            final String role = result['role'] ?? 'STAFF';
            final String username = result['username'] ?? _usernameController.text.trim();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Welcome back!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );

            _pinController.clear();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  isAdmin: isAdmin,
                  username: username,
                  userRole: role,
                ),
              ),
            );
          } else {
            _pinController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? "Invalid credentials"),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Refocus on username field
            FocusScope.of(context).requestFocus(_usernameFocusNode);
          }
        }
      } catch (e) {
        debugPrint('Login error: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Network error. Please try again.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          FocusScope.of(context).requestFocus(_usernameFocusNode);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            // Main content wrapped in GestureDetector to dismiss keyboard on tap
            GestureDetector(
              onTap: () {
                _usernameFocusNode.unfocus();
                _pinFocusNode.unfocus();
                FocusScope.of(context).unfocus();
              },
              behavior: HitTestBehavior.opaque,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue, Colors.blueAccent],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            "TAMBARARA",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "HOUSEKEEPING MANAGEMENT",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Image.network(
                    //   "https://www.tambarara.co.zw/wp-content/uploads/2018/10/Logo2--e1706291605595.png",
                    //   height: 120,
                    //   errorBuilder: (context, error, stackTrace) => Container(
                    //     height: 120,
                    //     width: 120,
                    //     decoration: BoxDecoration(
                    //       color: Colors.blue.withOpacity(0.1),
                    //       shape: BoxShape.circle,
                    //     ),
                    //     child: const Icon(Icons.hotel, size: 60, color: Colors.blue),
                    //   ),
                    //   loadingBuilder: (context, child, loadingProgress) {
                    //     if (loadingProgress == null) return child;
                    //     return Container(
                    //       height: 120,
                    //       width: 120,
                    //       decoration: BoxDecoration(
                    //         color: Colors.blue.withOpacity(0.1),
                    //         shape: BoxShape.circle,
                    //       ),
                    //       child: const Center(
                    //         child: CircularProgressIndicator(),
                    //       ),
                    //     );
                    //   },
                    // ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    "Login to your account",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                      
                                  const SizedBox(height: 32),
                                  TextFormField(
                                    autofocus: true,
                                    controller: _usernameController,
                                    focusNode: _usernameFocusNode,
                                    enabled: !_isLoading,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.text,
                                    onEditingComplete: () {
                                      _pinFocusNode.requestFocus();
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Staff Username",
                                      hintText: "Enter your username",
                                      prefixIcon: const Icon(Icons.person_outline),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your staff username';
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  TextFormField(
                                    autofocus: true,
                                    controller: _pinController,
                                    focusNode: _pinFocusNode,
                                    enabled: !_isLoading,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.number,
                                    onEditingComplete: _handleLogin,
                                    decoration: InputDecoration(
                                      labelText: "Staff PIN",
                                      hintText: "Enter 4-digit PIN",
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePin ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePin = !_obscurePin;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    obscureText: _obscurePin,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your Staff PIN';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _isLoading ? null : () {
                                        _showForgotPinDialog();
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue,
                                      ),
                                      child: const Text("Forgot PIN?"),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                      disabledBackgroundColor: Colors.blue.withOpacity(0.6),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                        : const Text(
                                      "CONTINUE",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: [
                        Text(
                          "Version 1.0.0",
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "© 2024 Tambarara Housekeeping",
                          style: TextStyle(color: Colors.grey[400], fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showForgotPinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Forgot PIN?"),
          content: const Text(
            "Please contact your administrator to reset your PIN.",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}