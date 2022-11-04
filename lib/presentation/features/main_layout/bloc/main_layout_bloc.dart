import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../../core/network/network_info.dart';
import '../../../../core/strings/messages.dart';
import '../../../../core/util/global_variables.dart';
import '../../../../data/network/local/cache_helper.dart';

part 'main_layout_event.dart';

part 'main_layout_state.dart';

class MainLayoutBloc extends Bloc<MainLayoutEvent, MainLayoutState> {
  int currentIndex = 0;
  bool isSync = false;
  final NetworkInfo networkInfo;

  MainLayoutBloc({required this.networkInfo}) : super(MainLayoutInitial()) {
    on<MainLayoutEvent>((event, emit) async {
      if (event is ChangeScaffoldBodyEvent) {
        currentIndex = event.index;
        emit(ChangeScaffoldBodyState(currentIndex));
      } else if (event is SyncEvent) {
        if (await networkInfo.isConnected) {
          if (isSync == true) {
            await CacheHelper.saveData(key: "sync", value: false);
          } else {
            await CacheHelper.saveData(key: "sync", value: true);
          }
          emit(ChangeSyncState());
          add(GetSyncStateEvent());
        } else {
          emit(ChangeSyncErrorState(message: NETWORK_ERROR_MESSAGE));
        }
      } else if (event is GetSyncStateEvent) {
        isSync = CacheHelper.getData(key: "sync");
        sync = isSync;
        emit(GetSyncState());
      }
    });
  }
}
