import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class LadgerDatabaseHelper {
  static final _databaseName = "Database.db";
  static final _databaseVersion = 1;

  static final table1 = 'ladger_table';
  static final columnTransactionId = 'transactionId'; // カラム名：取引ID
  static final columnUser = 'user'; // カラム名：ユーザー名
  static final columnAction = 'action'; // カラム名：操作（0:spend, 1:add）
  static final columnAmount = 'amount'; // カラム名：金額
  static final columnDate = 'date'; // カラム名：日付


  static Database? _database;
  static final LadgerDatabaseHelper instance =
      LadgerDatabaseHelper._privateConstructor();

  LadgerDatabaseHelper._privateConstructor();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table1 (
        $columnTransactionId INTEGER PRIMARY KEY,
        $columnUser TEXT NOT NULL,
        $columnAction INTEGER NOT NULL CHECK ($columnAction IN (0, 1)),
        $columnAmount INTEGER NOT NULL CHECK ($columnAmount >= 0),
        $columnDate TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(table1, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database? db = await instance.database;
    return await db!.query(table1);
  }

  Future<int> getSum() async {
    Database? db = await instance.database;
    List<Map<String, dynamic>> result = await db!.query(table1, columns: ["SUM($columnAmount)"]);
    int sum = result[0]["SUM($columnAmount)"] ?? 0;
    return sum;
  }


  /*
  Future<int> update(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    int id = row[columnId];
    return await db!.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
  */

  /*
  Future<int> delete(int id) async {
    Database? db = await instance.database;
    return await db!.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
  */
}
