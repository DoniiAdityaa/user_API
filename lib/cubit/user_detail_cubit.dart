import 'package:bloc/bloc.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';

part 'user_detail_state.dart';

class UserDetailCubit extends Cubit<UserDetailState> {
  final UserRepository _userRepository;

  UserDetailCubit(this._userRepository) : super(UserDetailInitial());

  void getUserById(String id) async {
    emit(UserDetailLoading());
    try {
      final user = await _userRepository.getUserById(id);
      emit(UserDetailSukses(user));
    } catch (e) {
      emit(UserDetailError("Failed to fetch user: $e"));
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _userRepository.deleteUserById(id);
      emit(UserDetailDeleted());
    } catch (e) {
      emit(UserDetailError('Gagal menghapus pengguna: $e'));
    }
  }

  Future<void> updateUser({
    required String id,
    required String name,
    required String address,
  }) async {
    emit(UserDetailLoading());
    try {
      final updatedUser = await _userRepository.updateUser(id, name, address);
      emit(UserDetailSukses(updatedUser));
    } catch (e) {
      emit(UserDetailError(e.toString()));
    }
  }
}
