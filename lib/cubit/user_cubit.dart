import 'package:bloc/bloc.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;
  List<UserModel> _originalUsers = [];

  UserCubit(this._userRepository) : super(UserInitial());

  void getUsers() async {
    emit(UserLoading());
    try {
      final users = await _userRepository.getUsers();
      _originalUsers = users;
      emit(UserSukses(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> createUser({
    required String name,
    required String address,
  }) async {
    emit(UserLoading());
    try {
      final newUser = await _userRepository.createUser(name, address);
      // UBAH BARIS INI
      emit(UserCreateSuccess(user: newUser, message: "User berhasil dibuat!"));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> updateUser({
    required String id,
    required String name,
    required String address,
  }) async {
    emit(UserLoading());
    try {
      final updatedUser = await _userRepository.updateUser(id, name, address);
      emit(
        UserUpdateSuccess(
          updatedUser: updatedUser,
          message: "User berhasil diperbarui!",
        ),
      );
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      emit(UserSukses(_originalUsers));
      return;
    }
    final lowerCaseQuery = query.toLowerCase();

    final filteredUsers =
        _originalUsers.where((user) {
          return user.name.toLowerCase().contains(lowerCaseQuery);
        }).toList();
    emit(UserSukses(filteredUsers));
  }

  void getUserById(String id) async {
    emit(UserLoading());
    try {
      final user = await _userRepository.getUserById(id);
    } catch (e) {
      emit(UserError("Failed to fetch user: $e"));
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _userRepository.deleteUserById(id);
    } catch (e) {
      throw Exception('Gagal menghapus pengguna.');
    }
  }

  Future<void> filterUsersByDate(DateTime selectedDate) async {
    try {
      emit(UserLoading());

      // Get users from repository (will fallback to local if offline)
      final allUsers = await _userRepository.getUsers();

      final filteredUsers =
          allUsers.where((user) {
            return user.createdAt.year == selectedDate.year &&
                user.createdAt.month == selectedDate.month &&
                user.createdAt.day == selectedDate.day;
          }).toList();

      emit(UserSukses(filteredUsers));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
