import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventpilot/providers/asset_controller.dart';
import 'package:inventpilot/screens/assets/asset_details.dart';

class ListAssets extends ConsumerWidget {
  const ListAssets({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Activos registrados')),
      body: assetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (assets) {
          if (assets.isEmpty) {
            return const Center(
              child: Text('No se encontraron activos registrados.'),
            );
          }

          return ListView.builder(
            itemCount: assets.length,
            itemBuilder: (_, index) {
              final asset = assets[index];
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AssetDetails(assetId: asset.id!),
                    ),
                  );
                },
                leading:
                    asset.imagePath!.isNotEmpty
                        ? Image.file(
                          File(asset.imagePath ?? ''),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                        : const Icon(Icons.image_not_supported),
                title: Text(asset.name),
                subtitle: Text('${asset.type} - ${asset.serial}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    ref
                        .read(assetControllerProvider.notifier)
                        .deleteAsset(asset.id!);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
