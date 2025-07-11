import 'package:api/models/user_model.dart';
import 'package:api/repository/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository = UserRepository();

  List<UserModel> _originalUsers = [];

  UserCubit() : super(UserInitial());

  void getUsers() async {
    emit(UserLoading());
    try {
      // Gunakan instance yang sudah ada
      final users = await _userRepository.getUsers();
      _originalUsers = users;
      emit(UserSukses(users));
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

  // Di dalam class UserCubit

  // Ubah tipe data 'id' di baris ini
  void getUserById(String id) async {
    // <--- DARI int MENJADI String
    emit(UserLoading());
    try {
      final user = await _userRepository.getUserById(id);
      emit(UserDetailSukses(user)); // Pastikan Anda punya state ini
    } catch (e) {
      emit(UserError("Failed to fetch user: $e"));
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      // Gunakan instance yang sudah ada dan benar
      await _userRepository.deleteUserById(id);
    } catch (e) {
      throw Exception('Gagal menghapus pengguna.');
    }
  }

  Future<void> createUser({
    required String name,
    required String address,
  }) async {
    emit(UserLoading());
    try {
      final newUser = await _userRepository.createUser(name, address);
      emit(UserCreateSuccess(newUser));
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
      emit(UserUpdateSuccess(updatedUser));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> filterUsersByDate(DateTime selectedDate) async {
    try {
      emit(UserLoading());
      final filteredUsers =
          await _originalUsers.where((user) {
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
