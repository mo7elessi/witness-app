import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../core/util/enums.dart';
import '../../presentation/features/edited_videos/bloc/edited_video_bloc.dart';

part 'network_event.dart';

part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  StreamSubscription? _subscription;
  final EditedVideoBloc videoBloc;
  NetworkBloc({required this.videoBloc}) : super(const NetworkState()) {
    _subscription = Connectivity().onConnectivityChanged.listen((status) {
      add(InternetConnectionEvent(connectivityResult: status));
    });
    on<InternetConnectionEvent>(_onChangeInternetConnection);
  }

  Future _onChangeInternetConnection(
    InternetConnectionEvent event,
    Emitter<NetworkState> emit,
  ) async {
    if (event.connectivityResult == ConnectivityResult.none) {
      emit(state.copyWith(
        message: "Please, check internet connection",
        state: InternetConnectionState.disconnected,
      ));
    } else if (event.connectivityResult == ConnectivityResult.wifi) {
      if (state.state == InternetConnectionState.disconnected) {
        videoBloc.add(UploadEvent());
        emit(state.copyWith(
          message: "Internet connection",
          state: InternetConnectionState.connected,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _subscription!.cancel();
    return super.close();
  }
}
