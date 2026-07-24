import '../database/database_helper.dart';
import '../models/category.dart';

class CategoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> createCategory({required String name, int? parentId}) async {
    final db = await _dbHelper.database;
    final category = Category(name: name, parentId: parentId, createdAt: DateTime.now());
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getRootCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query('categories', where: 'parent_id IS NULL', orderBy: 'created_at DESC');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<List<Category>> getSubCategories({required int parentId}) async {
    final db = await _dbHelper.database;
    final maps = await db.query('categories', where: 'parent_id = ?', whereArgs: [parentId], orderBy: 'created_at DESC');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query('categories', orderBy: 'created_at DESC');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<List<Category>> searchCategories({required String query}) async {
    final db = await _dbHelper.database;
    final maps = await db.query('categories', where: 'name LIKE ?', whereArgs: ['%$query%'], orderBy: 'created_at DESC');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<int> updateCategory({required int id, required String name}) async {
    final db = await _dbHelper.database;
    return await db.update('categories', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCategory({required int id}) async {
    final db = await _dbHelper.database;
    await db.delete('accounts', where: 'category_id = ?', whereArgs: [id]);
    await db.delete('categories', where: 'parent_id = ?', whereArgs: [id]);
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
