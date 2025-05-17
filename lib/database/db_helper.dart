import 'package:inventpilot/models/asset.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'inventory.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL,
          email TEXT NOT NULL,
          password TEXT NOT NULL,
          role TEXT NOT NULL
        );
      ''');

        await db.execute('''
        CREATE TABLE assets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          serial TEXT NOT NULL,
          imagePath TEXT,
          barcode TEXT,
          assignedTo INTEGER 
          );
      ''');
      },
    );
  }

  static Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<User?> getUser(String username, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return res.isNotEmpty ? User.fromMap(res.first) : null;
  }

  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  static Future<void> insertDefaultAdmin() async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['admin'],
    );
    if (res.isEmpty) {
      await insertUser(
        User(
          username: 'admin',
          email: 'admin@gmail.com',
          password: 'admin123',
          role: 'admin',
        ),
      );
    }
  }

  static Future<void> insertAsset(Asset asset) async {
    final db = await database;
    await db.insert(
      'assets',
      asset.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Asset>> getUnassignedAssets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'assignedTo IS NULL',
    );
    return maps.map((map) => Asset.fromMap(map)).toList();
  }

  static Future<List<User>> getRegularUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['regular'],
    );
    return maps.map((map) => User.fromMap(map)).toList();
  }

  static Future<void> assignAssetToUser(int assetId, int userId) async {
    final db = await database;
    await db.update(
      'assets',
      {'assignedTo': userId},
      where: 'id = ?',
      whereArgs: [assetId],
    );
  }
}
