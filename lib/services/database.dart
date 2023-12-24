import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:flutter/widgets.dart';

class DatabaseService {
  static const _dbName = 'inventory';
  static const _dbVersion = 1;
  static Database? _db;

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _dbName);

    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (error) {
      print('Failed to create databasesPath');
      print(error);
      exit(500);
    }

    try {
      DatabaseService._db = await openDatabase(
        path,
        onOpen: _onOpen,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: onDatabaseDowngradeDelete,
        version: _dbVersion,
      );
    } catch (error) {
      print('Failed open db');
      print(error);
      exit(500);
    }
  }

  static Future delete({ required String tableName, required String idName, required String idValue }) async {
    if (_db == null) {
      await DatabaseService.init();
    }
    int amount = 0;

    if (_db != null) {
      amount = await _db!.delete(tableName,
          where: '$idName = ?', whereArgs: [idValue]);
    }

    return amount;
  }

  static Future<int> update(
      tableName, Map<String, dynamic> values, Map<String, String> where) async {
    int id = 0;

    if (_db == null) {
      await DatabaseService.init();
    }

    if (_db != null) {
      id = await _db!.update(tableName, values,
          where: '${where.keys.first} = ?', whereArgs: [...where.values]);
    }

    return id;
  }

  static Future<int> insert(tableName, row) async {
    int id = 0;

    if (_db == null) {
      await DatabaseService.init();
    }

    if (_db != null) {
      return await _db!.insert(tableName, row);
    }

    return id;
  }

  static Future<List<Map>> getAll({required tableName,  String? idName, String? idValue}) async {
    List<Map> data = [];

    if (_db == null) {
      await DatabaseService.init();
    }

    if (_db != null) {
      data = await _db!.query(tableName, where: idName != null ? '$idName = ?': null, whereArgs: idValue != null? [idValue]: null );
    }

    return data;
  }

  static Future<String> getUser() async {
    if (_db == null) {
      await DatabaseService.init();
    }

    if (_db != null) {
      final List<Map> users = await _db!.rawQuery(""" 
        SELECT * FROM users;
      """);

      if (users.isEmpty) {
        return '';
      }
      print(users);
      return users[0]['name'];
    }

    return '';
  }

  static Future<int> saveUser(Map<String, dynamic> row) async {
    if (_db == null) {
      await DatabaseService.init();
    } else {
      return await _db!.insert('users', row);
    }

    return 0;
  }

  static Future<void> _onOpen(Database db) async {
    // Database is open, print its version
    print('db version ${await db.getVersion()}');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Database version is updated, alter the table
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Database is created, create the table
    await db.execute("""CREATE TABLE users 
        (id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT NOT NULL);""");
    await db.execute("""CREATE TABLE inventories
        (id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL,
        started TEXT NOT NULL,
        finished TEXT,
        user TEXT NOT NULL,
        items_amount INT,
        synced INTEGER);""");
    await db.execute("""CREATE TABLE inventory_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL, 
        price REAl NOT NULL,
        amount INTEGER NOT NULL,
        user TEXT NOT NULL,
        inventory INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL);""");
  }
}
