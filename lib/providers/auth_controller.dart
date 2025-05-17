import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventpilot/database/auth_repository.dart';
import 'package:inventpilot/models/user.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
      return AuthController(ref);
    });

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final Ref ref;

  AuthController(this.ref) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(email, password);
      if (user != null) {
        state = AsyncValue.data(user);
      } else {
        state = AsyncValue.error('Credenciales inválidas', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void logout() {
    state = const AsyncValue.data(null);
  }
}
