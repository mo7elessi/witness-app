import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
part 'main_layout_event.dart';

part 'main_layout_state.dart';

class MainLayoutBloc extends Bloc<MainLayoutEvent, MainLayoutState> {
  int currentIndex = 0;

  MainLayoutBloc() : super(MainLayoutInitial()) {
    on<MainLayoutEvent>((event, emit) {
      if (event is ChangeScaffoldBodyEvent) {
        currentIndex = event.index;
        emit(ChangeScaffoldBodyState(currentIndex));
      }
    });
  }
}
