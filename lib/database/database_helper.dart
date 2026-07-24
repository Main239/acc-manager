import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static const String _databaseName = 'account_manager.db';
  static const int _databaseVersion = 2;

  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE categories (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, parent_id INTEGER, created_at INTEGER NOT NULL, FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE CASCADE)''');
    await db.execute('''CREATE TABLE accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, category_id INTEGER NOT NULL, account_name TEXT NOT NULL, username TEXT NOT NULL, password TEXT NOT NULL, note TEXT, is_logged_in INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL, FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE)''');
    await db.execute('''CREATE INDEX idx_accounts_category_id ON accounts(category_id)''');
    await db.execute('''CREATE INDEX idx_categories_parent_id ON categories(parent_id)''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE categories ADD COLUMN parent_id INTEGER REFERENCES categories(id) ON DELETE CASCADE');
      await db.execute('ALTER TABLE accounts ADD COLUMN is_logged_in INTEGER NOT NULL DEFAULT 0');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_categories_parent_id ON categories(parent_id)');
    }
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
