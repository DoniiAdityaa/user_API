part of 'user_cubit.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}

final class UserLoading extends UserState {}

final class UserSukses extends UserState {
  final List<UserModel> users;

  UserSukses(this.users);
}

final class UserDetailSukses extends UserState {
  final UserModel user;

  UserDetailSukses(this.user);
}

final class UserError extends UserState {
  final String message;

  UserError(this.message);
}

final class UserCreateSuccess extends UserState {
  final UserModel user;
  UserCreateSuccess(this.user);
}

final class UserUpdateSuccess extends UserState {
  final UserModel updatedUser;
  UserUpdateSuccess(this.updatedUser);
}
