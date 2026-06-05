import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction_model.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'controle_financeiro.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );

    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        isIncome INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> login(String email, String password) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactionsByUser(int userId) async {
    final db = await database;

    final result = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );

    return result.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;

    return db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
