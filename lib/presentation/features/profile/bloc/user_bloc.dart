import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nice_shot/core/functions/functions.dart';
import 'package:nice_shot/core/util/global_variables.dart';
import 'package:nice_shot/core/strings/messages.dart';
import 'package:nice_shot/core/util/enums.dart';
import '../../../../data/model/api/User_model.dart';
import '../../../../data/model/api/data_model.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../logic/network_bloc/network_bloc.dart';

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  final NetworkBloc networkBloc;

  UserBloc({
    required this.userRepository,
    required this.networkBloc,
  }) : super(const UserState()) {
    on<UserEvent>((event, emit) async {});
    on<GetUserDataEvent>(_onGetUserData);
    on<UpdateUserDataEvent>(_onUpdateUserData);
    on<ResetPasswordEvent>(_onResetPassword);
    on<UpdateUserImageEvent>(_onUpdateUserImage);
  }

  Future<void> _onGetUserData(
    GetUserDataEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));

    var result = await userRepository.getUserData(id: userId);
    result.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (data) {
        emit(state.copyWith(
          requestState: RequestState.loaded,
          user: data,
        ));
      },
    );
  }

  Future<void> _onUpdateUserData(
    UpdateUserDataEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(updateDataState: RequestState.loading));
    var result = await userRepository.updateUserData(userModel: event.user);
    result.fold(
      (failure) => emit(state.copyWith(
        updateDataState: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (data) {
        emit(state.copyWith(
          updateDataState: RequestState.loaded,
          message: UPDATE_USER_SUCCESS_MESSAGE,
        ));
        add(GetUserDataEvent());
      },
    );
  }

  Future<void> _onUpdateUserImage(
    UpdateUserImageEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(updateImageState: RequestState.loading));
    var result = await userRepository.updateUserImage(path: event.path);
    result.fold(
      (failure) => emit(state.copyWith(
        updateImageState: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (r) {
        emit(state.copyWith(
          updateImageState: RequestState.loaded,
          message: UPDATE_USER_SUCCESS_MESSAGE,
        ));
        add(GetUserDataEvent());
      },
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(resetPasswordState: RequestState.loading));
    var result = await userRepository.resetPassword(
      newPassword: event.newPassword,
      oldPassword: event.oldPassword,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          resetPasswordState: RequestState.error,
          message: mapFailureToMessage(failure: failure),
        ),
      ),
      (r) => emit(state.copyWith(
        resetPasswordState: RequestState.loaded,
        message: RESET_PASSEORD_SUCCESS_MESSAGE,
      )),
    );
  }
}
