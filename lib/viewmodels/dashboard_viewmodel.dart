import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../services/database_helper.dart';

class DashboardViewModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  final List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;

  double get totalIncome {
    return _transactions
        .where((transaction) => transaction.isIncome)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get totalExpense {
    return _transactions
        .where((transaction) => !transaction.isIncome)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get balance => totalIncome - totalExpense;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadTransactions(int userId) async {
    _setLoading(true);

    try {
      final data = await _databaseHelper.getTransactionsByUser(userId);
      _transactions
        ..clear()
        ..addAll(data);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _databaseHelper.insertTransaction(transaction);
    await loadTransactions(transaction.userId);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _databaseHelper.updateTransaction(transaction);
    await loadTransactions(transaction.userId);
  }

  Future<void> deleteTransaction({
    required int id,
    required int userId,
  }) async {
    await _databaseHelper.deleteTransaction(id);
    await loadTransactions(userId);
  }

  void clear() {
    _transactions.clear();
    notifyListeners();
  }
}
