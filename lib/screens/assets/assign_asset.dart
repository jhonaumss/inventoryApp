import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventpilot/providers/user_controller.dart';
import 'package:inventpilot/providers/asset_controller.dart';
import 'package:inventpilot/models/asset.dart';
import 'package:inventpilot/models/user.dart';

class AssignAsset extends ConsumerStatefulWidget {
  const AssignAsset({super.key});

  @override
  ConsumerState<AssignAsset> createState() => _AssignAssetState();
}

class _AssignAssetState extends ConsumerState<AssignAsset> {
  Asset? selectedAsset;
  User? selectedUser;

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(assetControllerProvider);
    final usersAsync = ref.watch(userControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Asignar Activo')),
      body: assetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error cargando activos: $e')),
        data: (assets) {
          final unassignedAssets =
              assets.where((a) => a.assignedTo == null).toList();

          return usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error cargando usuarios: $e')),
            data: (users) {
              if (unassignedAssets.isEmpty || users.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay activos y/o usuarios disponibles para asignar. \n Registre nuevos activos y/o usuarios.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<Asset>(
                      decoration: const InputDecoration(
                        labelText: "Seleccionar Activo",
                      ),
                      items:
                          unassignedAssets.map((asset) {
                            return DropdownMenuItem(
                              value: asset,
                              child: Text('${asset.name} (${asset.serial})'),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setState(() => selectedAsset = value),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<User>(
                      decoration: const InputDecoration(
                        labelText: "Seleccionar Usuario",
                      ),
                      items:
                          users.map((user) {
                            return DropdownMenuItem(
                              value: user,
                              child: Text('${user.username} (${user.role})'),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setState(() => selectedUser = value),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed:
                          (selectedAsset != null && selectedUser != null)
                              ? () async {
                                final assetId = selectedAsset!.id!;
                                final userId = selectedUser!.id!;
                                await ref
                                    .read(assetControllerProvider.notifier)
                                    .assignAsset(assetId, userId);
                                ref.invalidate(userAssetsProvider(userId));

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Activo Asignado exitosamente!',
                                      ),
                                    ),
                                  );
                                }

                                setState(() {
                                  selectedAsset = null;
                                  selectedUser = null;
                                });
                              }
                              : null,
                      child: const Text('Asignar Activo'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
