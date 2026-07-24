import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/account.dart';

/// Service quản lý các thao tác CRUD cho Account.
class AccountService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ── CREATE ──

  /// Tạo một account mới, trả về id của account vừa tạo.
  Future<int> createAccount({
    required int categoryId,
    required String accountName,
    required String username,
    required String password,
    String? note,
  }) async {
    final db = await _dbHelper.database;

    final account = Account(
      categoryId: categoryId,
      accountName: accountName,
      username: username,
      password: password,
      note: note,
      createdAt: DateTime.now(),
    );

    return await db.insert('accounts', account.toMap());
  }

  // ── READ ──

  /// Lấy tất cả accounts của một category.
  Future<List<Account>> getAccountsByCategory({required int categoryId}) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Account.fromMap(map)).toList();
  }

  /// Lấy một account theo id.
  Future<Account?> getAccountById({required int id}) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Account.fromMap(maps.first);
  }

  // ── UPDATE ──

  /// Cập nhật một account.
  Future<int> updateAccount({
    required int id,
    required String accountName,
    required String username,
    required String password,
    String? note,
  }) async {
    final db = await _dbHelper.database;

    return await db.update(
      'accounts',
      {
        'account_name': accountName,
        'username': username,
        'password': password,
        'note': note,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── DELETE ──

  /// Xóa một account theo id.
  Future<int> deleteAccount({required int id}) async {
    final db = await _dbHelper.database;

    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  /// Lấy tổng số accounts trong một category.
  Future<int> getAccountCount({required int categoryId}) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM accounts WHERE category_id = ?',
      [categoryId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
