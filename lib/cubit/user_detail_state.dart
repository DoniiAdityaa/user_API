part of 'user_detail_cubit.dart';

sealed class UserDetailState {}

final class UserDetailInitial extends UserDetailState {}

final class UserDetailLoading extends UserDetailState {}

final class UserDetailSukses extends UserDetailState {
  final UserModel user;
  UserDetailSukses(this.user);
}

final class UserDetailError extends UserDetailState {
  final String message;
  UserDetailError(this.message);
}

final class UserDetailDeleted extends UserDetailState {}

final class UserDetailUpdateSuccess extends UserDetailState {
  final UserModel updatedUser;
  final String message;
  UserDetailUpdateSuccess({required this.updatedUser, required this.message});
}
