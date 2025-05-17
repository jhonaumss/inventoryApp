import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventpilot/database/user_repository.dart';
import 'package:inventpilot/models/user.dart';

final userRepositoryProvider = Provider((ref) => UserRepository());

final userControllerProvider =
    StateNotifierProvider<UserController, AsyncValue<List<User>>>((ref) {
      return UserController(ref);
    });

class UserController extends StateNotifier<AsyncValue<List<User>>> {
  final Ref ref;

  UserController(this.ref) : super(const AsyncLoading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final users = await ref.read(userRepositoryProvider).getRegularUsers();
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addUser(User user) async {
    state = const AsyncLoading();
    await ref.read(userRepositoryProvider).addUser(user);
    await loadUsers();
  }

  Future<void> updateUser(User user) async {
    state = const AsyncLoading();
    await ref.read(userRepositoryProvider).updateUser(user);
    await loadUsers();
  }

  Future<void> deleteUser(int id) async {
    state = const AsyncLoading();
    await ref.read(userRepositoryProvider).deleteUser(id);
    await loadUsers();
  }
}
