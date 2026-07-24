import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// Quản lý kết nối và khởi tạo database SQLite.
class DatabaseHelper {
  static const String _databaseName = 'account_manager.db';
  static const int _databaseVersion = 1;

  // Singleton pattern
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _database;

  /// Lấy instance database, tự động khởi tạo nếu chưa có.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Tạo bảng khi database được tạo lần đầu.
  Future<void> _onCreate(Database db, int version) async {
    // Bảng danh mục (Facebook, Zalo, Roblox,...)
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Bảng tài khoản
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        account_name TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        note TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // Index để truy vấn nhanh theo category_id
    await db.execute('''
      CREATE INDEX idx_accounts_category_id ON accounts(category_id)
    ''');
  }

  /// Đóng database (khi app đóng).
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
