import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nice_shot/core/util/boxes.dart';
import 'package:nice_shot/core/error/exceptions.dart';
import 'package:nice_shot/data/model/video_model.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumbnail;
import 'package:video_trimmer/video_trimmer.dart';
import '../../../../core/functions/functions.dart';
import '../../../../data/model/flag_model.dart';
import 'bloc.dart';
import 'package:ffmpeg_kit_flutter/session_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraController? controller;
  Duration videoDuration = const Duration(seconds: 0);
  Duration selectedDuration = const Duration(seconds: 60);
  Duration afterTimeShot = const Duration(seconds: 10);
  Duration beforeTimeShot = const Duration(seconds: 10);
  Duration mainDuration = const Duration(seconds: 60);
  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;
  Timer? countdownTimer;
  double minAvailableZoom = 1.0;
  double maxAvailableZoom = 1.0;
  double currentZoomLevel = 1.0;
  bool showFocusCircle = false;
  double x = 0;
  double y = 0;
  List<FlagModel> flags = [];
  List<String> paths = [];
  final Trimmer trimmer = Trimmer();
  bool flashOpened = false;

  CameraBloc() : super(CameraInitial()) {
    on<InitCameraEvent>(_initCamera);
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<PausedRecordingEvent>(_onPauseRecording);
    on<ResumeRecordingEvent>(_onResumeRecording);
    on<DeleteRecordingEvent>(_onDeleteRecording);
    on<OpenFlashEvent>(_onOpenFlash);
    on<ChangeZoomLeveEvent>(_onChangeCurrentZoomLevel);
    on<FocusEvent>(_onFocusEvent);
    on<ChangeSelectedDurationEvent>(_changeSelectedDuration);
    on<NewFlagEvent>(_addNewFlag);
    on<SaveRecordsEvent>(_onSaveRecords);
    on<ChangeSelectedShotDurationEvent>(_changeSelectedTimeShot);
  }

  Future<void> _changeSelectedDuration(
    ChangeSelectedDurationEvent event,
    Emitter<CameraState> emit,
  ) async {
    selectedDuration = event.duration;
    mainDuration = event.duration;
    emit(ChangeSelectedDurationState());
  }

  Future<void> _changeSelectedTimeShot(
    ChangeSelectedShotDurationEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (event.after) {
      afterTimeShot = Duration(seconds: event.duration.inSeconds);
    } else {
      beforeTimeShot = Duration(seconds: event.duration.inSeconds);
    }
    emit(ChangeSelectedTimeShotState());
  }

  Future<void> _addNewFlag(
    NewFlagEvent event,
    Emitter<CameraState> emit,
  ) async {
    flags.add(event.flagModel);

    emit(FlagsState());
  }

  Future<void> _initCamera(
    InitCameraEvent event,
    Emitter<CameraState> emit,
  ) async {
    try {
      add(OpenFlashEvent(open: true));
      final cameras = await availableCameras();
      final back = cameras.firstWhere((camera) {
        return camera.lensDirection == CameraLensDirection.back;
      });
      controller = CameraController(
        back,
        currentResolutionPreset,
        enableAudio: true,
      );
      await controller!.initialize();
      emit(InitCameraState());
      controller!.getMaxZoomLevel().then((value) => maxAvailableZoom = value);
      controller!.getMinZoomLevel().then((value) => minAvailableZoom = value);
    } on CameraException catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> _onStartRecording(
    StartRecordingEvent event,
    Emitter<CameraState> emit,
  ) async {
    try {
      if (!event.fromUser) {
        startTimer();
        await _startRecording();
        emit(StartRecordingState());
      }
    } on CameraException catch (e) {
      debugPrint("$e");
    }
  }

  List<List<VideoModel>> videosToMerge = [];
  List<VideoModel> videos = [];
  List<VideoModel> videosToSave = [];

  Future<void> _onStopRecording(
    StopRecordingEvent event,
    Emitter<CameraState> emit,
  ) async {
    try {
      var file = await _stopRecording();
      selectedDuration = mainDuration;
      emit(StopRecordingState(fromUser: event.fromUser));
      countdownTimer!.cancel();
      videoDuration = const Duration(seconds: 0);
      Duration beforeShot =
          Duration(seconds: (beforeTimeShot.inSeconds.toDouble()) ~/ 2);
      event.video.path = file!.path;
      List<FlagModel> myFlags = event.video.flags!;
      videos.add(event.video);
      if (myFlags.isEmpty) {
        paths.add(file.path);
        if (videos.length > 1 && !videosToMerge.contains([event.video])) {
          File(paths.first).deleteSync();
          paths.removeAt(0);
        }
      } else if (myFlags.isNotEmpty) {
        List<FlagModel> x = myFlags.where((element) {
          final flagTime = castingDuration(duration: element.flagPoint!);
          return flagTime.inSeconds >= beforeShot.inSeconds;
        }).toList();
        List<FlagModel> y = myFlags.where((element) {
          final flagTime = castingDuration(duration: element.flagPoint!);
          return flagTime.inSeconds < beforeShot.inSeconds;
        }).toList();
        bool saved = false;
        if (x.isNotEmpty && videos.length > 1) {
          if (!videos.contains(event.video)) videos.add(event.video);
          saved = true;
          saveVideoToHive(videoModel: event.video);
        } else if (y.isNotEmpty && videos.length > 1) {
          List<VideoModel> list = [videos[videos.length - 2], event.video];
          if (!videosToMerge.contains(list)) videosToMerge.add(list);
        } else if (videos.length < 2 && x.isNotEmpty && !event.fromUser) {
          if (!saved) saveVideoToHive(videoModel: event.video);
        }
      }
      if (!event.fromUser) {
        add(StartRecordingEvent(fromUser: event.fromUser));
      } else if (event.fromUser && videosToMerge.isEmpty) {
        saveVideoToHive(videoModel: event.video);
        videos = [];
        videosToMerge = [];
      } else if (event.fromUser && videosToMerge.isNotEmpty) {
        add(SaveRecordsEvent(videos: videosToMerge));
      }
    } on CameraException catch (e) {
      throw Exception(e);
    }
  }

  Future saveVideoToHive({required VideoModel videoModel}) async {
    video_thumbnail.VideoThumbnail.thumbnailFile(
      video: videoModel.path!,
      imageFormat: video_thumbnail.ImageFormat.JPEG,
    ).then((value) async {
      await Boxes.videoBox.add(videoModel..videoThumbnail = value!);
      emit(SaveToHiveSuccess());
    });
  }

  List<String> mergedVideos = [];

  Future<void> _onSaveRecords(
    SaveRecordsEvent event,
    Emitter<CameraState> emit,
  ) async {
  //  emit(SaveRecordsLoading());
    for (var e in videosToMerge) {
      for (var i = 0; i < e.length - 1; i++) {
        getApplicationStoragePath().then((value) {
          String path =
              "${value.path}/${DateTime.now().microsecondsSinceEpoch}.mp4";
          String commandToExecute =
              '-i ${e[i].path} -i ${e[i + 1].path} -filter_complex "[0:0][0:1][1:0][1:1]concat=n=2:v=1:a=1[outv][outa]" -map "[outv]" -map "[outa]" -q:v 4 -q:a 4 $path';
          FFmpegKit.executeAsync(commandToExecute, (session) async {
            SessionState state = await session.getState();

            if (state == SessionState.completed) {
              videosToMerge.removeAt(0);

              final v1Duration = castingDuration(
                duration: e[i].videoDuration!,
              );
              final v2Duration = castingDuration(
                duration: e[i + 1].videoDuration!,
              );
              List<FlagModel> flags = [];
              for (var element in e[i + 1].flags!) {
                final flagPoint = castingDuration(
                  duration: element.flagPoint!,
                );
                final lastVideo = castingDuration(
                  duration: e[i].videoDuration!,
                );
                element.flagPoint = (flagPoint + lastVideo).toString();
                flags.add(element);
              }
              saveVideoToHive(
                videoModel: VideoModel(
                  path: path,
                  flags: flags,
                  dateTime: e[i + 1].dateTime,
                  videoDuration: (v1Duration + v2Duration).toString(),
                ),
              );
            }
          });
          // if (videosToMerge.length - 1 == i) {
          //   videosToMerge.clear();
          //   emit(SaveRecordsSuccess());
          // }
        });
      }
    }
  }

  void startTimer() {
    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) async {
        const reduceSecondsBy = 1;
        final seconds = videoDuration.inSeconds + reduceSecondsBy;
        if (seconds < 0) {
          countdownTimer!.cancel();
        } else {
          videoDuration = Duration(seconds: seconds);
          Duration afterShot =
              Duration(seconds: afterTimeShot.inSeconds.toDouble() ~/ 2);
          Duration currentDuration = videoDuration;
          VideoModel video = VideoModel(
            dateTime: DateTime.now(),
            videoDuration: videoDuration.toString(),
            flags: flags,
          );

          if (flags.isNotEmpty && currentDuration == selectedDuration) {
            final flagDuration = castingDuration(
              duration: flags.last.flagPoint!,
            );

            if (flagDuration > (currentDuration - afterShot)) {
              selectedDuration += afterShot;
            } else {
              add(StopRecordingEvent(video: video, fromUser: false));
              flags = [];
            }
          } else if (currentDuration == selectedDuration && flags.isEmpty) {
            add(StopRecordingEvent(video: video..flags = [], fromUser: false));
          }
        }
        emit(StartTimerState());
      },
    );
  }

  Future<void> _onResumeRecording(
    ResumeRecordingEvent event,
    Emitter<CameraState> emit,
  ) async {
    try {
      startTimer();
      await _resumeRecording();
      emit(ResumeRecordingState());
    } on CameraException catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> _onPauseRecording(
    PausedRecordingEvent event,
    Emitter<CameraState> emit,
  ) async {
    try {
      countdownTimer!.cancel();
      await _pauseRecording();
      emit(PauseRecordingState());
    } on CameraException catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> _onDeleteRecording(
    DeleteRecordingEvent event,
    Emitter<CameraState> emit,
  ) async {
    try {
      await File(event.file.path).delete();
      emit(DeleteRecordingSuccessState());
    } on DeleteVideoException catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> _onOpenFlash(
    OpenFlashEvent event,
    Emitter<CameraState> emit,
  ) async {
    try {
      flashOpened = !event.open;
      await _openFlash();
      emit(FlashOpenedState());
    } catch (e) {
      emit(FlashErrorState(error: e.toString()));
      debugPrint("$e");
    }
  }

  Future<void> _onChangeCurrentZoomLevel(
    ChangeZoomLeveEvent event,
    Emitter<CameraState> emit,
  ) async {
    currentZoomLevel = event.currentZoomLevel;
    emit(ChangeCurrentZoomState());
  }

  Future<void> _startRecording() async {
    final CameraController? cameraController = controller;

    if (!cameraController!.value.isInitialized) {
      return;
    }
    await cameraController.prepareForVideoRecording();
    await cameraController.startVideoRecording();
  }

  Future<void> _onFocusEvent(
    FocusEvent event,
    Emitter<CameraState> emit,
  ) async {
    if (controller!.value.isInitialized) {
      showFocusCircle = true;
      x = event.details.localPosition.dx;
      y = event.details.localPosition.dy;
      double fullWidth = MediaQuery.of(event.context).size.width;
      double cameraHeight = fullWidth * controller!.value.aspectRatio;
      double xp = x / fullWidth;
      double yp = y / cameraHeight;
      Offset point = Offset(xp, yp);

      await controller!.setFocusPoint(point);
      // await controller!.setExposurePoint(point);
      Future.delayed(const Duration(seconds: 2)).whenComplete(() {
        showFocusCircle = false;
        emit(FocusState());
      });
    }
  }

  Future<XFile?> _stopRecording() async {
    final CameraController? cameraController = controller;

    if (!cameraController!.value.isInitialized) {
      return null;
    }

    //  audioPlayer.open(Audio("assets/audios/stop.mp3"));
    return await cameraController.stopVideoRecording();
  }

  Future<void> _pauseRecording() async {
    final CameraController? cameraController = controller;

    if (!cameraController!.value.isInitialized) {
      return;
    }
    // audioPlayer.open(Audio("assets/audios/pause.mp3"));
    await cameraController.pauseVideoRecording();
  }

  Future<void> _resumeRecording() async {
    final CameraController? cameraController = controller;

    if (!cameraController!.value.isInitialized) {
      return;
    }
    // audioPlayer.open(Audio("assets/audios/resume.mp3"));
    await cameraController.resumeVideoRecording();
  }

  Future<void> _openFlash() async {
    final CameraController? cameraController = controller;
    if (!cameraController!.value.isInitialized) {
      return;
    }
    await cameraController.setFlashMode(
      flashOpened ? FlashMode.torch : FlashMode.off,
    );
  }

  @override
  Future<void> close() {
    controller?.dispose();
    return super.close();
  }
}
