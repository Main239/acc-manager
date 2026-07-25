import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/account.dart';

class AccountService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> createAccount({
    required int categoryId, required String accountName,
    required String username, required String password, String? note,
  }) async {
    final db = await _dbHelper.database;
    final account = Account(
      categoryId: categoryId, accountName: accountName,
      username: username, password: password, note: note,
      isLoggedIn: false, createdAt: DateTime.now(),
    );
    return await db.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAccountsByCategory({required int categoryId}) async {
    final db = await _dbHelper.database;
    final maps = await db.query('accounts',
      where: 'category_id = ?', whereArgs: [categoryId],
      orderBy: 'created_at DESC');
    return maps.map((m) => Account.fromMap(m)).toList();
  }

  Future<Account?> getAccountById({required int id}) async {
    final db = await _dbHelper.database;
    final maps = await db.query('accounts', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Account.fromMap(maps.first);
  }

  Future<int> updateAccount({
    required int id, required String accountName,
    required String username, required String password, String? note,
  }) async {
    final db = await _dbHelper.database;
    return await db.update('accounts', {
      'account_name': accountName, 'username': username,
      'password': password, 'note': note,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> moveAccount({required int id, required int newCategoryId}) async {
    final db = await _dbHelper.database;
    return await db.update('accounts', {'category_id': newCategoryId}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> toggleLoginStatus({required int id, required bool isLoggedIn}) async {
    final db = await _dbHelper.database;
    return await db.update('accounts', {'is_logged_in': isLoggedIn ? 1 : 0},
      where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAccount({required int id}) async {
    final db = await _dbHelper.database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getAccountCount({required int categoryId}) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM accounts WHERE category_id = ?', [categoryId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
