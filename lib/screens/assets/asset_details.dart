import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inventpilot/models/user.dart';
import 'package:inventpilot/providers/asset_controller.dart';
import 'package:inventpilot/screens/assets/assign_asset.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:inventpilot/models/asset.dart';
import 'package:inventpilot/providers/user_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

class AssetDetails extends ConsumerWidget {
  final int? assetId;

  const AssetDetails({super.key, required this.assetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetControllerProvider);
    final usersAsync = ref.watch(userControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Activo')),
      body: assetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (assets) {
          Asset? asset;
          try {
            asset = assets.firstWhere((a) => a.id == assetId);
          } catch (_) {
            asset = null;
          }
          if (asset == null) {
            return const Center(child: Text('Activo no encontrado.'));
          }

          User? user;
          try {
            user =
                asset.assignedTo != null
                    ? usersAsync.value?.firstWhere(
                      (u) => u.id == asset?.assignedTo,
                    )
                    : null;
          } catch (_) {
            user = null;
          }

          final qrData = '${asset.name}, ${asset.type}, ${asset.serial}';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (asset.imagePath != null && asset.imagePath!.isNotEmpty)
                  Center(
                    child: Image.file(
                      File(asset.imagePath!),
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  asset.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(asset.type),
                const SizedBox(height: 8),
                Text('Serie: ${asset.serial}'),
                const SizedBox(height: 16),
                QrImageView(data: qrData, size: 200),
                const SizedBox(height: 16),
                Text(
                  user != null ? 'Asignado a: ${user.username}' : 'No asignado',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (user == null)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AssignAsset()),
                      );
                    },
                    child: const Text('Asignar Activo'),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Share.share('Datos del Activo:\n$qrData');
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir QR'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
