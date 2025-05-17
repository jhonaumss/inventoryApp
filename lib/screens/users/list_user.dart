import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventpilot/providers/user_controller.dart';
import 'package:inventpilot/screens/users/user_asset_screen.dart';

class ListUser extends ConsumerWidget {
  const ListUser({super.key});

  String _capitalize(String input) {
    if (input.isEmpty) return '';
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios registrados')),
      body: users.when(
        data: (users) {
          return users.isEmpty
              ? const Center(
                child: Text('No se encontraron usuarios registrados.'),
              )
              : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(_capitalize(user.username)),
                    subtitle: Text(user.email),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Borrar usuario'),
                                content: Text(
                                  'Esta seguro de eliminar al usuario ${_capitalize(user.username)}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Borrar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          ref
                              .read(userControllerProvider.notifier)
                              .deleteUser(user.id!);
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserAssetsScreen(user: user),
                        ),
                      );
                    },
                  );
                },
              );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: ${e.toString()}')),
      ),
    );
  }
}
