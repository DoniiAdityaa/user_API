// lib/cubit/user_state.dart

part of 'user_cubit.dart';

sealed class UserState {}

final class UserInitial extends UserState {}

final class UserLoading extends UserState {}

// TIDAK BERUBAH
final class UserSukses extends UserState {
  final List<UserModel> users;
  UserSukses(this.users);
}

// UserDetailSukses moved to separate UserDetailCubit

// TIDAK BERUBAH
final class UserError extends UserState {
  final String message;
  UserError(this.message);
}

// DIUBAH DI SINI
final class UserCreateSuccess extends UserState {
  final UserModel user;
  final String message; // <-- TAMBAHKAN INI

  // Ubah constructor untuk menerima message
  UserCreateSuccess({required this.user, required this.message});
}

// DIUBAH DI SINI
final class UserUpdateSuccess extends UserState {
  final UserModel updatedUser;
  final String message; // <-- TAMBAHKAN INI

  // Ubah constructor untuk menerima message
  UserUpdateSuccess({required this.updatedUser, required this.message});
}
