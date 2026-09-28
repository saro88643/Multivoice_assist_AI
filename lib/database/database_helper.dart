import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/history_model.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasePath = await getDatabasesPath();

    final String path = join(databasePath, 'chat_history.db');

    return openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        dateTime TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertChat(HistoryModel history) async {
    final Database db = await database;

    return db.insert(
      'history',
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HistoryModel>> getAllChats() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'history',
      orderBy: 'id DESC',
    );

    return maps.map((map) => HistoryModel.fromMap(map)).toList();
  }

  Future<int> deleteChat(int id) async {
    final Database db = await database;

    return db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllChats() async {
    final Database db = await database;

    return db.delete('history');
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();

      _database = null;
    }
  }
}
