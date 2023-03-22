import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class LadgerDatabaseHelper {
  static final _databaseName = "Database.db";
  static final _databaseVersion = 1;

  static final table1 = 'ladger_table';
  static final columnTransactionId =
      'transactionId INTEGER PRIMARY KEY AUTOINCREMENT'; // カラム名：取引ID
  static final columnBalance = 'balance'; // カラム名：残高
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
        $columnBalance INTEGER NOT NULL CHECK ($columnBalance >= 0),
        $columnUser TEXT NOT NULL,
        $columnAction INTEGER NOT NULL CHECK ($columnAction IN (0, 1)),
        $columnAmount INTEGER NOT NULL CHECK ($columnAmount >= 0),
        $columnDate TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertTransaction(
      String user, int action, int amount, String date) async {
    final db = await LadgerDatabaseHelper.instance.database;
    final currentBalance = await LadgerDatabaseHelper.instance.getMaxTransactionBalance() ?? 0;

    final newRow = <String, dynamic>{
      LadgerDatabaseHelper.columnBalance: action == 0
          ? currentBalance - amount
          : currentBalance + amount,
      LadgerDatabaseHelper.columnUser: user,
      LadgerDatabaseHelper.columnAction: action,
      LadgerDatabaseHelper.columnAmount: amount,
      LadgerDatabaseHelper.columnDate: date,
    };

    await db?.insert(LadgerDatabaseHelper.table1, newRow);
  }

  Future<int?> getMaxTransactionBalance() async {
    Database? db = await instance.database;
    List<Map<String, dynamic>> result = await db!.query(table1,
        columns: [columnBalance],
        where: "$columnTransactionId = (SELECT MAX($columnTransactionId) FROM $table1)");
    if (result.isNotEmpty) {
      return result.first[columnBalance];
    } else {
      return null;
    }
  }
}
