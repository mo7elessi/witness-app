import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nice_shot/core/util/global_variables.dart';
import 'package:nice_shot/core/strings/messages.dart';
import 'package:nice_shot/core/util/enums.dart';

import '../../../../data/model/api/User_model.dart';
import '../../../../data/model/api/data_model.dart';
import '../../../../data/repositories/user_repository.dart';

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(const UserState()) {
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
    var result = await userRepository.getUserData(id: userId!);
    result.fold(
      (l) => emit(state.copyWith(
        requestState: RequestState.error,
        message: "${l.runtimeType}",
      )),
      (r) {
        emit(state.copyWith(
          requestState: RequestState.loaded,
          user: Data<UserModel>.fromJson(r.data),
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
      (l) => emit(state.copyWith(
        updateDataState: RequestState.error,
        message: "${l.runtimeType}",
      )),
      (r) {
        emit(state.copyWith(
          updateDataState: RequestState.loaded,
          user: Data<UserModel>.fromJson(r.data),
          message: r.data['message'] ?? UPDATE_USER_SUCCESS_MESSAGE,
        ));
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
      (l) => emit(state.copyWith(
        updateImageState: RequestState.error,
        message: "${l.runtimeType}",
      )),
      (r) {
        emit(state.copyWith(
          updateImageState: RequestState.loaded,
          user: Data<UserModel>.fromJson(r.data),
          message: r.data['message'] ?? UPDATE_USER_SUCCESS_MESSAGE,
        ));
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
      (l) => emit(state.copyWith(
        resetPasswordState: RequestState.error,
        message: "${l.runtimeType}",
      )),
      (r) => emit(state.copyWith(
        resetPasswordState: RequestState.loaded,
        message: r.data['message'],
      )),
    );
  }
}
