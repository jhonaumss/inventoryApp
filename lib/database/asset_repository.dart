import 'package:inventpilot/database/db_helper.dart';
import 'package:inventpilot/models/asset.dart';

class AssetRepository {
  Future<void> addAsset(Asset asset) async {
    final db = await DBHelper.database;
    await db.insert('assets', asset.toMap());
  }

  Future<List<Asset>> getAssets() async {
    final db = await DBHelper.database;
    final result = await db.query('assets');
    return result.map((e) => Asset.fromMap(e)).toList();
  }

  Future<void> deleteAsset(int id) async {
    final db = await DBHelper.database;
    await db.delete('assets', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateAsset(Asset asset) async {
    final db = await DBHelper.database;
    await db.update(
      'assets',
      asset.toMap(),
      where: 'id = ?',
      whereArgs: [asset.id],
    );
  }

  Future<void> assignAssetToUser(int assetId, int userId) async {
    final db = await DBHelper.database;
    final updated = await db.update(
      'assets',
      {'assignedTo': userId},
      where: 'id = ?',
      whereArgs: [assetId],
    );
    print('Updated asset: $updated');
  }

  Future<List<Asset>> getAssetsByUserId(int userId) async {
    final db = await DBHelper.database;
    final maps = await db.query(
      'assets',
      where: 'assignedTo = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => Asset.fromMap(map)).toList();
  }
}
