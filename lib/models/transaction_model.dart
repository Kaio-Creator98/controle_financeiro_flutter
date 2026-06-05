class TransactionModel {
  final int? id;
  final int userId;
  final String title;
  final double amount;
  final String date;
  final bool isIncome;

  TransactionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'date': date,
      'isIncome': isIncome ? 1 : 0,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
      isIncome: map['isIncome'] == 1,
    );
  }

  TransactionModel copyWith({
    int? id,
    int? userId,
    String? title,
    double? amount,
    String? date,
    bool? isIncome,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}
