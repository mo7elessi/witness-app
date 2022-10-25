part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final Data<UserModel>? user;
  final UserModel? currentUser;
  final RequestState? registerState;
  final RequestState? loginState;
  final RequestState? logoutState;
  final RequestState? getMe;
  final String? message;
  final LoginModel? login;

  const AuthState({
    this.user,
    this.registerState,
    this.loginState,
    this.logoutState,
    this.message,
    this.login,
    this.getMe,
    this.currentUser,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        user,
        registerState,
        message,
        login,
        loginState,
        logoutState,
        getMe,
        currentUser,
      ];

  AuthState copyWith({
    Data<UserModel>? user,
    RequestState? registerState,
    RequestState? loginState,
    RequestState? logoutState,
    RequestState? getMe,
    String? message,
    LoginModel? login,
    UserModel? currentUser,
  }) {
    return AuthState(
      registerState: registerState ?? this.registerState,
      loginState: loginState ?? this.loginState,
      getMe: getMe ?? this.getMe,
      logoutState: logoutState ?? this.logoutState,
      message: message ?? this.message,
      user: user ?? this.user,
      login: login ?? this.login,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

// abstract class AuthState {
//   const AuthState();
// }
//
// class AuthInitial extends AuthState {}
//
// class PickUserImageState extends AuthState {
//   final File file;
//
//   PickUserImageState({required this.file});
// }
//
// class ChangeVisibilityPasswordState extends AuthState {
//   final IconData icon;
//   final bool isShow;
//
//   ChangeVisibilityPasswordState({ required this.isShow, required this.icon});
// }
