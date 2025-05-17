import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventpilot/providers/auth_controller.dart';
import 'package:inventpilot/providers/password_visibility.dart';
import 'package:inventpilot/screens/home.dart';

class Login extends ConsumerWidget {
  Login({super.key});
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final obscurePassword = ref.watch(passwordVisibilityProvider);

    ref.listen(authControllerProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Home()),
          );
        }
      });
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Ingrese sus credenciales')),
      body:
          authState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: passCtrl,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            ref
                                .read(passwordVisibilityProvider.notifier)
                                .state = !obscurePassword;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(authControllerProvider.notifier)
                            .login(emailCtrl.text.trim(), passCtrl.text.trim());
                      },
                      child: const Text('Iniciar sesión'),
                    ),
                    if (authState.hasError)
                      Text(
                        authState.error.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
    );
  }
}
