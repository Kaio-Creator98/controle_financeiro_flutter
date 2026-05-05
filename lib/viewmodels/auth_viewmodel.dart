import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLogin = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void toggleMode() {
    isLogin = !isLogin;
    notifyListeners();
  }

  void submit(BuildContext context) {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha email e senha"),
        ),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}