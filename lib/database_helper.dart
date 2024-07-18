import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'Book.dart';  // Replace with your book model

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    var path = join(documentsDirectory.path, 'books_database.db');

    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        author TEXT,
        date TEXT,
        rating REAL
      )
    ''');
  }

  Future<int> insert(Book book) async {
    Database db = await DatabaseHelper().database;
    return await db.insert('books', book.toMap());
  }

  Future<int> update(Book book) async {
    Database db = await DatabaseHelper().database;
    return await db.update('books', book.toMap(),
        where: 'id = ?', whereArgs: [book.id]);
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseHelper().database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Book>> getBooks() async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> maps = await db.query('books');
    return List.generate(maps.length, (i) {
      return Book(
        id: maps[i]['id'],
        title: maps[i]['title'],
        author: maps[i]['author'],
        date: DateTime.parse(maps[i]['date']),
        rating: maps[i]['rating'],
      );
    });
  }

  Future close() async {
    Database db = await DatabaseHelper().database;
    db.close();
  }
}

final DatabaseHelper databaseHelper = DatabaseHelper();
