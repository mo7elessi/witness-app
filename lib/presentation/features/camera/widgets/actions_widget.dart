// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/data/model/flag_model.dart';
import 'package:nice_shot/data/model/video_model.dart';
import 'package:nice_shot/presentation/widgets/loading_widget.dart';

import '../../../widgets/recording_button.dart';
import '../bloc/bloc.dart';

class ActionsWidget extends StatelessWidget {
  final CameraBloc cameraBloc;

  const ActionsWidget({
    Key? key,
    required this.cameraBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _mapToActions(),
    );
  }

  List<Widget> _mapToActions() {
    if (cameraBloc.controller!.value.isRecordingVideo &&
        !cameraBloc.controller!.value.isRecordingPaused) {
      return [
        FloatingActionButton(
          onPressed: () => _onPressStop(),
          child: const Icon(Icons.stop),
        ),
        RecordingButtonWidget(
          icon: Icons.flag,
          onPressed: () => _onPressFlag(),
        ),
        // FloatingActionButton(
        //   backgroundColor: MyColors.backgroundColor,
        //   onPressed: () => _onPressFlag(),
        //   child: const Icon(MyIcons.flag, color: MyColors.primaryColor),
        // ),
        FloatingActionButton(
          onPressed: () => cameraBloc.add(PausedRecordingEvent()),
          child: const Icon(Icons.pause),
        ),
      ];
    } else if (cameraBloc.controller!.value.isRecordingPaused) {
      return [
        FloatingActionButton(
          onPressed: () => _onPressStop(),
          child: const Icon(Icons.stop),
        ),
        FloatingActionButton(
          onPressed: () => cameraBloc.add(ResumeRecordingEvent()),
          child: const Icon(Icons.play_arrow),
        ),
      ];
    } else if (!cameraBloc.controller!.value.isRecordingVideo) {
      return [
        startVideoButton(
          clickAble: !cameraBloc.controller!.value.isRecordingPaused,
        )
      ];
    }

    return [startVideoButton(clickAble: true)];
  }

  Widget startVideoButton({required bool clickAble}) => clickAble
      ? RecordingButtonWidget(
          icon: Icons.circle,
          onPressed: () => cameraBloc.add(StartRecordingEvent(fromUser: false)),
          // child: const Icon(Icons.circle_rounded),
        )
      : const CircularProgressIndicator();

  void _onPressFlag() {
    //cameraBloc.audioPlayer.open(Audio("assets/audios/flags.mp3"));
    Duration flagPoint = cameraBloc.videoDuration;
    Duration timeShot =cameraBloc.afterTimeShot;
    FlagModel flag = FlagModel(
      flagPoint: flagPoint.toString(),
      durationShot: (timeShot.inSeconds/2).toDouble().toInt().toString(),
    );
    cameraBloc.add(NewFlagEvent(flagModel: flag));
  }

  Future<void> _onPressStop() async {
    Duration currentDuration =  cameraBloc.videoDuration;
    VideoModel video = VideoModel(
      dateTime: DateTime.now(),
      videoDuration: currentDuration.toString(),
      flags: cameraBloc.flags,
    );
    cameraBloc.add(StopRecordingEvent(video: video, fromUser: true));
    cameraBloc.flags = [];
  }
}
