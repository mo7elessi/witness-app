import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:nice_shot/core/util/boxes.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../data/model/flag_model.dart';
import '../../../../data/model/video_model.dart';
part 'trimmer_event.dart';

part 'trimmer_state.dart';

class TrimmerBloc extends Bloc<TrimmerEvent, TrimmerState> {
  final Trimmer trimmer = Trimmer();
  double startValue = 0.0;
  double endValue = 0.0;

  TrimmerBloc() : super(TrimmerInitial()) {
    on<TrimmerEvent>((event, emit) {});
    on<InitTrimmerEvent>(_onInitTrimmer);
    on<ExportVideoEvent>(_onExportVideo);
  }

  Future<void> _onInitTrimmer(
    InitTrimmerEvent event,
    Emitter<TrimmerState> emit,
  ) async {
    trimmer.loadVideo(videoFile: event.file);
    trimmer.videPlaybackControl(
      startValue: startValue,
      endValue: endValue,
    );
    emit(InitTrimmerState(trimmer: trimmer));
  }

  Future<void> _onExportVideo(
    ExportVideoEvent event,
    Emitter<TrimmerState> emit,
  ) async {
    emit(ExportVideoLoadingState());
    try {
      await trimmer.saveTrimmedVideo(
        startValue: startValue,
        endValue: endValue,
        videoFileName: event.flagModel.title,
        videoFolderName: "edited_videos",
        onSave: (String? outputPath) async {
          VideoModel videoModel = VideoModel(
            id: event.flagModel.id,
            path: outputPath!,
            title: event.flagModel.title,
            dateTime: DateTime.now(),
          );
          await Boxes.exportedVideoBox.add(videoModel);
        },
      );

      emit(ExportVideoSuccessState());
    } on ExportVideoException catch (e) {
      emit(ExportVideoErrorState(error: "$e"));
    }
  }
  @override
  Future<void> close() {
    trimmer.dispose();
    trimmer.videoPlayerController?.dispose();
    print("closed");
    return super.close();
  }
}
