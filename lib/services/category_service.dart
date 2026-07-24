import '../database/database_helper.dart';
import '../models/category.dart';

/// Service quản lý các thao tác CRUD cho Category.
class CategoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ── CREATE ──

  /// Tạo một category mới, trả về id của category vừa tạo.
  Future<int> createCategory({required String name}) async {
    final db = await _dbHelper.database;

    final category = Category(
      name: name,
      createdAt: DateTime.now(),
    );

    return await db.insert('categories', category.toMap());
  }

  // ── READ ──

  /// Lấy tất cả categories, sắp xếp theo thời gian tạo (mới nhất trước).
  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// Tìm kiếm categories theo tên.
  Future<List<Category>> searchCategories({required String query}) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Category.fromMap(map)).toList();
  }

  // ── UPDATE ──

  /// Cập nhật tên category.
  Future<int> updateCategory({required int id, required String name}) async {
    final db = await _dbHelper.database;

    return await db.update(
      'categories',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── DELETE ──

  /// Xóa một category (và tất cả accounts thuộc category đó nhờ ON DELETE CASCADE).
  Future<int> deleteCategory({required int id}) async {
    final db = await _dbHelper.database;

    // Xóa tất cả accounts thuộc category này trước
    await db.delete('accounts', where: 'category_id = ?', whereArgs: [id]);

    // Xóa category
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
