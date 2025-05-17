import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventpilot/models/user.dart';
import 'package:inventpilot/providers/asset_controller.dart';
import 'package:inventpilot/screens/assets/asset_details.dart';

class UserAssetsScreen extends ConsumerWidget {
  final User user;

  const UserAssetsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAssets = ref.watch(userAssetsProvider(user.id!));

    return Scaffold(
      appBar: AppBar(title: Text(' Activos de usuario: ${user.username}')),
      body: userAssets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (assets) {
          if (assets.isEmpty) {
            return const Center(
              child: Text('El usuario no tiene activos asignados.'),
            );
          }

          return ListView.builder(
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AssetDetails(assetId: asset.id),
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
                title: Text('${asset.name} (${asset.type})'),
                subtitle: Text('Serial: ${asset.serial}'),
              );
            },
          );
        },
      ),
    );
  }
}
