import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const dbName = "myDatabase.db";
  static const dbVersion = 1;
  static const dbTable = 'emp_info';
  static const columnId = 'emp_id';
  static const columnName = 'emp_name';
  static const columnPass = 'emp_pass';

  static final DatabaseHelper instance = DatabaseHelper();

  static Database? _database;

  Future<Database?> get database async {
    _database ??= await initDB();
    return _database;
  }

  initDB() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, dbName);
    return await openDatabase(path, version: dbVersion, onCreate: onCreate);
  }

  Future onCreate(Database db, int version) async {
    db.execute('''CREATE TABLE $dbTable(
        $columnId INT IDENTITY(1001,1) PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnPass TEXT NOT NULL
        );  ''');
  }

  insertRecord(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(dbTable, row);
  }

  Future<List<Map<String, dynamic>>> queryDatabase() async {
    Database? db = await instance.database;
    return await db!.rawQuery("SELECT * FROM $dbTable");
  }

  Future<int> updateRecord(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    int id = row[columnId];
    return await db!
        .update(dbTable, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteRecord(String empName) async {
    Database? db = await instance.database;
    // Map<String, dynamic> id = row[columnName];
    return await db!
        .delete(dbTable, where: '$columnName = ?', whereArgs: [empName]);
  }
}
