import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventpilot/models/asset.dart';
import 'package:inventpilot/database/asset_repository.dart';

final assetRepositoryProvider = Provider((ref) => AssetRepository());

final assetControllerProvider =
    AsyncNotifierProvider<AssetController, List<Asset>>(AssetController.new);

final userAssetsProvider = FutureProvider.family<List<Asset>, int>((
  ref,
  userId,
) {
  final repo = ref.read(assetRepositoryProvider);
  return repo.getAssetsByUserId(userId);
});

class AssetController extends AsyncNotifier<List<Asset>> {
  late final AssetRepository _repository;

  @override
  Future<List<Asset>> build() async {
    _repository = ref.read(assetRepositoryProvider);
    return await _repository.getAssets();
  }

  Future<void> addAsset(Asset asset) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addAsset(asset);
      final assets = await _repository.getAssets();
      state = AsyncValue.data(assets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAsset(Asset asset) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateAsset(asset);
      final assets = await _repository.getAssets();
      state = AsyncValue.data(assets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAsset(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteAsset(id);
      final assets = await _repository.getAssets();
      state = AsyncValue.data(assets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> assignAsset(int assetId, int userId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.assignAssetToUser(assetId, userId);
      final assets = await _repository.getAssets();
      state = AsyncValue.data(assets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
