import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nice_shot/core/error/failure.dart';
import 'package:nice_shot/core/functions/functions.dart';
import 'package:nice_shot/core/strings/messages.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/data/model/api/User_model.dart';
import 'package:nice_shot/data/model/api/data_model.dart';
import 'package:nice_shot/data/repositories/user_repository.dart';
import '../../../../data/model/api/login_model.dart';
import '../../../../logic/network_bloc/network_bloc.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;
  final NetworkBloc networkBloc;

  AuthBloc({required this.userRepository, required this.networkBloc})
      : super(const AuthState()) {
    on<AuthEvent>((event, emit) async {
      if (event is CreateAccountEvent) {
        emit(state.copyWith(registerState: RequestState.loading));
        final result = await userRepository.createUser(userModel: event.user);
        result.fold(
          (failure) => emit(
            state.copyWith(
              registerState: RequestState.error,
              message: mapFailureToMessage(failure: failure),
            ),
          ),
          (data) => emit(state.copyWith(
            registerState: RequestState.loaded,
            message: REGISTER_SUCCESS_MESSAGE,
          )),
        );
      } else if (event is LoginEvent) {
        emit(state.copyWith(loginState: RequestState.loading));
        var result = await userRepository.login(
          email: event.email,
          password: event.password,
        );
        result.fold(
          (failure) => emit(
            state.copyWith(
              loginState: RequestState.error,
              message: mapFailureToMessage(failure: failure),
            ),
          ),
          (r) {
            emit(
              state.copyWith(
                loginState: RequestState.loaded,
                message: LOGIN_SUCCESS_MESSAGE,
              ),
            );
          },
        );
      } else if (event is LogoutEvent) {
        emit(state.copyWith(logoutState: RequestState.loading));
        final result = await userRepository.logout();
        result.fold(
          (failure) => emit(
            state.copyWith(
              logoutState: RequestState.error,
              message: mapFailureToMessage(failure: failure),
            ),
          ),
          (r) => emit(
            state.copyWith(
              logoutState: RequestState.loaded,
              message: LOGOUT_SUCCESS_MESSAGE,
            ),
          ),
        );
      } else if (event is DeleteAccountEvent) {
        emit(state.copyWith(logoutState: RequestState.loading));
        final result = await userRepository.deleteAccount();
        result.fold(
          (failure) => emit(
            state.copyWith(
              logoutState: RequestState.error,
              message: mapFailureToMessage(failure: failure),
            ),
          ),
          (r) => emit(state.copyWith(logoutState: RequestState.loaded)),
        );
      }
    });
  }
}
