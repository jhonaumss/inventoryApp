import 'package:inventpilot/database/db_helper.dart';
import 'package:inventpilot/models/user.dart';

class AuthRepository {
  Future<User?> login(String email, String password) async {
    final db = await DBHelper.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }
}
