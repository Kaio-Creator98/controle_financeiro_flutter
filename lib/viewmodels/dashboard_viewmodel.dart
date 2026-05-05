import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/transaction_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final List<TransactionModel> _transactions = [
    TransactionModel(title: "Salário", amount: 3000.0, isIncome: true),
    TransactionModel(title: "Mercado", amount: 200.0, isIncome: false),
    TransactionModel(title: "Freela", amount: 800.0, isIncome: true),
  ];

  List<TransactionModel> get transactions => _transactions;

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

  void addTransaction(String title, double amount, bool isIncome) {
    _transactions.add(
      TransactionModel(
        title: title,
        amount: amount,
        isIncome: isIncome,
      ),
    );

    notifyListeners();
  }
}