import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Place (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        lat REAL NOT NULL,
        lng REAL NOT NULL,
        precision INTEGER DEFAULT 50
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Task (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        completed INTEGER NOT NULL DEFAULT 0,
        title TEXT NOT NULL,
        attachments TEXT NOT NULL DEFAULT '',
        time TEXT,
        date TEXT NOT NULL,
        is_deadline INTEGER NOT NULL DEFAULT 0,
        repeat_type TEXT CHECK (repeat_type IN (NULL, 'DAILY', 'WEEKLY', 'MONTHLY_DAY_WEEK', 'MONTHLY_DAY', 'YEARLY')),
        repeat_interval INTEGER,
        repeat_days TEXT,
        end_type TEXT CHECK (end_type IN (NULL, 'DATE', 'TIMES')),
        end_on TEXT,
        exclude TEXT,
        place_id INTEGER REFERENCES Place(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Note (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        datetime TEXT NOT NULL,
        attachments TEXT NOT NULL DEFAULT '',
        lat REAL,
        lng REAL,
        tags TEXT NOT NULL DEFAULT ''
      )
    ''');
  }
}
