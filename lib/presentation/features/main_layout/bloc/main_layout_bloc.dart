import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../../data/network/local/cache_helper.dart';
import '../../edited_videos/bloc/edited_video_bloc.dart';

part 'main_layout_event.dart';

part 'main_layout_state.dart';

class MainLayoutBloc extends Bloc<MainLayoutEvent, MainLayoutState> {
  int currentIndex = 0;
  bool isSync = false;
  final EditedVideoBloc videoBLoc;

  MainLayoutBloc({required this.videoBLoc}) : super(MainLayoutInitial()) {
    on<MainLayoutEvent>((event, emit) async {
      if (event is ChangeScaffoldBodyEvent) {
        currentIndex = event.index;
        emit(ChangeScaffoldBodyState(currentIndex));
      } else if (event is SyncEvent) {
        if (isSync == true) {
          await CacheHelper.saveData(key: "sync", value: false);
        } else {
          await CacheHelper.saveData(key: "sync", value: true);
        }
        emit(ChangeSyncState());
        add(GetSyncStateEvent());
      } else if (event is GetSyncStateEvent) {
        isSync = CacheHelper.getData(key: "sync");
        emit(GetSyncState());
      }
      if(state is GetSyncState){
        if (isSync == true) {
          videoBLoc.add(UploadEvent());
        }
      }
    });
  }
}
