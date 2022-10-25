part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class LogoutEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

//class GetCurrentUserData extends AuthEvent {}

class CreateAccountEvent extends AuthEvent {
  final UserModel user;

  CreateAccountEvent({required this.user});
}
