import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nice_shot/data/network/remote/dio_connectivity_request_retrier.dart';

import '../../core/util/enums.dart';

part 'network_event.dart';

part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState>{
  StreamSubscription? _subscription;
  NetworkBloc() : super(const NetworkState()) {
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
