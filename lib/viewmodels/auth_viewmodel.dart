import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/database_helper.dart';

class AuthViewModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final user = await _databaseHelper.login(email.trim(), password.trim());
      _currentUser = user;
      return user != null;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final existingUser = await _databaseHelper.getUserByEmail(email.trim());

      if (existingUser != null) {
        return 'Este e-mail já está cadastrado.';
      }

      await _databaseHelper.insertUser(
        UserModel(
          name: name.trim(),
          email: email.trim(),
          password: password.trim(),
        ),
      );

      return null;
    } catch (e) {
      return 'Erro ao cadastrar usuário.';
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
