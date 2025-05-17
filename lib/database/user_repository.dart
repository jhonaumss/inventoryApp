import 'package:inventpilot/database/db_helper.dart';
import 'package:inventpilot/models/user.dart';

class UserRepository {
  Future<List<User>> getRegularUsers() async {
    final db = await DBHelper.database;
    final result = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['regular'],
    );
    return result.map((e) => User.fromMap(e)).toList();
  }

  Future<void> addUser(User user) async {
    final db = await DBHelper.database;
    await db.insert('users', user.toMap());
  }

  Future<void> updateUser(User user) async {
    final db = await DBHelper.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(int id) async {
    final db = await DBHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
