import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

part 'ui_event.dart';
part 'ui_state.dart';

class UiBloc extends Bloc<UiEvent, UiState> {
  var picker = ImagePicker();
  bool isPassword = false;

  UiBloc() : super(const UiState()) {
    on<UiEvent>((event, emit) async{
      if (event is PickUserImageEvent) {
        await pickImage().then((value) {
          emit(state.copyWith(file: value!));
        });
      } else if (event is PickProfileImageEvent) {
        await pickImage().then((value) {
          emit(state.copyWith(profileImage: value!));
        });
      } else if (event is ChangeIconSuffixEvent) {
        isPassword = !event.isPassword;
        emit(state.copyWith(
          icon:
          event.isPassword ? Icons.visibility_sharp : Icons.visibility_off,
          isPassword: event.isPassword,
        ));
      }
      });
  }
  Future<File?> pickImage() async {
    final file = await picker.getImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      return File(file.path);
    }
    return null;
  }
}
