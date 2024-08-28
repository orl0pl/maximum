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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (newVersion == 2) {
      await db.execute('ALTER TABLE Note RENAME TO Note_old');
      await db.execute('ALTER TABLE Task RENAME TO Task_old');
      await db.execute('ALTER TABLE Place RENAME TO Place_old');
      await db.execute('DROP TABLE IF EXISTS Note');
      await db.execute('DROP TABLE IF EXISTS Task');
      await db.execute('DROP TABLE IF EXISTS Place');
      await _onCreate(db, newVersion);
      await db.execute('INSERT INTO Note SELECT * FROM Note_old');
      await db.execute('INSERT INTO Task SELECT * FROM Task_old');
      await db.execute('INSERT INTO Place SELECT * FROM Place_old');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    if (version == 2) {
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
        target_progress INT DEFAULT 0,
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
      CREATE TABLE IF NOT EXISTS TaskProgress (
        task_id INTEGER NOT NULL REFERENCES Task(id),
        date TEXT NOT NULL,
        current_progress INT DEFAULT 0,
        PRIMARY KEY (task_id, date)
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
}
