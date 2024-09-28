import 'package:notifications_tut/models/task.model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(path,
        version: 7, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        content TEXT,
        time TEXT,
        location TEXT,
        leader TEXT,
        note TEXT,
        status TEXT,
        isReminderEnabled INTEGER DEFAULT 0,
        reminderTime INTETGER,
        priority INTERGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE tasks ADD COLUMN isReminderEnabled INTEGER DEFAULT 0
        ALTER TABLE tasks ADD COLUMN reminderTime INTEGER 
        ALTER TABLE tasks ADD COLUMN priority INTEGER DEFAULT 0
      ''');
    }
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

Future<List<Task>> getTasks() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('tasks');

  return List.generate(maps.length, (i) {
    return Task(
      id: maps[i]['id'],
      date: maps[i]['date'],
      content: maps[i]['content'],
      time: maps[i]['time'],
      location: maps[i]['location'],
      leader: maps[i]['leader'],
      note: maps[i]['note'],
      status: maps[i]['status'],
      isReminderEnabled: maps[i]['isReminderEnabled'],  
      reminderTime: maps[i]['reminderTime'],
      priority: maps[i]['priority'],
    );
  });
}

  Future<int> updateTask(Task task) async {
  final db = await database;
  return await db.update(
    'tasks',
    task.toMap(),
    where: 'id = ?',
    whereArgs: [task.id],
  );
}

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
