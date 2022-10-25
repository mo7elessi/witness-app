import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nice_shot/core/strings/messages.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/data/model/api/User_model.dart';
import 'package:nice_shot/data/model/api/data_model.dart';
import 'package:nice_shot/data/repositories/user_repository.dart';
import '../../../../data/model/api/login_model.dart';
import '../../profile/bloc/user_bloc.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({required this.userRepository}) : super(const AuthState()) {
    on<AuthEvent>((event, emit) async {
      if (event is CreateAccountEvent) {
        emit(state.copyWith(registerState: RequestState.loading));
        var result = await userRepository.createUser(userModel: event.user);
        result.fold(
          (l) => emit(state.copyWith(
              registerState: RequestState.error, message: "${l.runtimeType}")),
          (r) => emit(state.copyWith(
            registerState: RequestState.loaded,
            user: Data<UserModel>.fromJson(r.data),
            message: r.data['message'] ?? REGISTER_SUCCESS_MESSAGE,
          )),
        );
      } else if (event is LoginEvent) {
        emit(state.copyWith(loginState: RequestState.loading));
        var result = await userRepository.login(
          email: event.email,
          password: event.password,
        );
        result.fold(
          (l) => emit(state.copyWith(loginState: RequestState.error)),
          (r) {
            emit(
              state.copyWith(
                loginState: RequestState.loaded,
                login: LoginModel.fromJson(r.data),
                message: r.data['error'] ?? LOGIN_SUCCESS_MESSAGE,
              ),
            );
          },
        );
      } else if (event is LogoutEvent) {
        final result = await userRepository.logout();
        result.fold(
            (l) => emit(
                  state.copyWith(
                    logoutState: RequestState.error,
                    message: l.toString(),
                  ),
                ),
            (r) => {
                  emit(
                    state.copyWith(
                      logoutState: RequestState.loaded,
                      message: r.data['message'],
                    ),
                  ),
                });
      }
      // else if (event is GetCurrentUserData) {
      //   emit(state.copyWith(getMe: RequestState.loading));
      //   final result = await userRepository.getCurrentUserData();
      //   result.fold(
      //     (l) => emit(
      //       state.copyWith(
      //         getMe: RequestState.error,
      //         message: l.toString(),
      //       ),
      //     ),
      //     (r) => emit(
      //       state.copyWith(
      //         getMe: RequestState.loaded,
      //         currentUser: UserModel.fromJson(r.data),
      //       ),
      //     ),
      //   );
      // }
    });
  }
}
