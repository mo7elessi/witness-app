import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'flag_event.dart';

part 'flag_state.dart';

class FlagBloc extends Bloc<FlagEvent, FlagState> {
  FlagBloc() : super(FlagInitial()) {
    on<FlagEvent>((event, emit) {
      // TODO: implement event handler
    });
  }

  Future<void> _onEditFlagEvent(
    EditFlagEvent event,
    Emitter<FlagState> emit,
  ) async {}
}
