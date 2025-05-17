import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventpilot/models/user.dart';
import 'package:inventpilot/providers/user_controller.dart';

class CreateUser extends ConsumerStatefulWidget {
  const CreateUser({super.key});

  @override
  ConsumerState<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends ConsumerState<CreateUser> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String selectedRole = 'regular';

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Ingrese un nombre de usuario' : null,
              ),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator:
                    (value) => value!.isEmpty ? 'Ingrese un email' : null,
              ),
              TextFormField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator:
                    (value) => value!.length < 6 ? 'Minimo 6 caracteres' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'regular', child: Text('Regular')),
                ],
                onChanged: (value) {
                  if (value != null) selectedRole = value;
                },
                decoration: const InputDecoration(labelText: 'Tipo de usuario'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    userState.isLoading
                        ? null
                        : () async {
                          if (_formKey.currentState!.validate()) {
                            final newUser = User(
                              username: nameCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              password: passCtrl.text.trim(),
                              role: selectedRole,
                            );
                            await ref
                                .read(userControllerProvider.notifier)
                                .addUser(newUser);

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Usuario creado exitosamente'),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                child:
                    userState.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Crear Usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
