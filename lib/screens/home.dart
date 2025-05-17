import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventpilot/providers/auth_controller.dart';
import 'package:inventpilot/screens/assets/assign_asset.dart';
import 'package:inventpilot/screens/assets/list_asset.dart';
import 'package:inventpilot/screens/assets/scan_asset.dart';
import 'package:inventpilot/screens/users/create_user.dart';
import 'package:inventpilot/screens/assets/register_asset.dart';
import 'package:inventpilot/screens/users/list_user.dart';
import '../providers/auth_provider.dart';
import 'login.dart';

class Home extends ConsumerWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authControllerProvider);

    return userState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('Error con la sesion por favor, Ingresar otra vez'),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text('Home ${user.username}')),
          drawer: Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(
                          'assets/user_placeholder.png',
                        ),
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (user.role == 'admin') ...[
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: Text("Crear Usuario"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreateUser()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Ver usuarios registrados'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ListUser(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_box),
                    title: Text("Registrar Activo"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterAsset()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.list),
                    title: Text("Listar Activos"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ListAssets()),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.assignment_add),
                    title: Text("Asignar Activos"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AssignAsset()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: const Text('Buscar Activo por Código'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScanAsset()),
                      );
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text("Cerrar Sesion"),
                  onTap: () {
                    ref.read(authProvider.notifier).state = null;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => Login()),
                    );
                  },
                ),
              ],
            ),
          ),
          body: Center(child: Text("Bienvenido ${user.username}")),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
