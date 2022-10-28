import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:hive/hive.dart';
import 'package:nice_shot/core/constants/constants.dart';
import 'package:nice_shot/core/routes/routes.dart';
import 'package:nice_shot/data/model/flag_model.dart';
import 'package:video_trimmer/video_trimmer.dart';
import '../../../../core/functions/functions.dart';
import '../../../../core/util/boxes.dart';
import '../../../../core/util/enums.dart';
import '../../../../data/model/video_model.dart';
import '../../../../data/mute_model.dart';
import '../../../widgets/loading_widget.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/session_state.dart';

import '../../edited_videos/bloc/edited_video_bloc.dart';

class TrimmerPage extends StatefulWidget with ChangeNotifier {
  final File file;
  final FlagModel flag;
  final VideoModel data;
  final Box<VideoModel> items;
  final int flagIndex;
  final int videoIndex;
  final Duration videoDuration;
  static ValueNotifier<bool> deletingMode = ValueNotifier<bool>(false);
  static ValueNotifier<int> deletingIndex = ValueNotifier<int>(0);
  static MuteModel? model;

  TrimmerPage({
    Key? key,
    required this.file,
    required this.flag,
    required this.data,
    required this.items,
    required this.flagIndex,
    required this.videoIndex,
    required this.videoDuration,
  }) : super(key: key);

  @override
  State<TrimmerPage> createState() => _TrimmerPageState();
}

class _TrimmerPageState extends State<TrimmerPage>
    with TickerProviderStateMixin {
  final Trimmer trimmer = Trimmer();
  double startValue = 0.0;
  double endValue = 0.0;
  bool _isPlaying = false;
  double endTemp = 0;
  bool showSnackBarEnd = true;
  bool showSnackBarRight = true;
  int pausedValueTrimMode = 0;
  int pausedValueMuteMode = 0;
  bool isLoading = false;
  bool showNumberPickerDialog = false;
  bool doMute = false;
  List<MuteModel> mutedSections = [];
  bool isProcessingMode = true;
  int currentMode = 0;
  double muteStart = 0;
  double muteEnd = 0;
  int scrubberRebuild = 0;

  ///initialMode==trimMode
  late TabController _tabController;

  @override
  void initState() {
    startValue = widget.flag.startDuration!.inSeconds.toDouble();
    trimmer.loadVideo(videoFile: widget.file);
    endTemp = widget.flag.endDuration!.inSeconds.toDouble();
    muteEnd = endTemp;
    muteStart = startValue;
    _tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    TrimmerPage.deletingMode.dispose();
    trimmer.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TrimmerPage.deletingIndex.addListener(() {});
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          bottom: TabBar(
              onTap: (index) {
                if (_tabController.indexIsChanging) {
                  currentMode = index;
                  scrubberRebuild = currentMode == trimMode ? 0 : 1;
                  setState(() {
                    if (index == trimMode) {
                      trimmer.videoPlayerController!.pause().then((value) {
                        trimmer.videoPlayerController!
                            .seekTo(Duration(seconds: startValue.toInt()));
                      });
                    } else {
                      trimmer.videoPlayerController!.pause().then((value) {
                        trimmer.videoPlayerController!
                            .seekTo(Duration(seconds: muteStart.toInt()));
                      });
                    }
                  });
                }
              },
              controller: _tabController,
              indicatorColor: Colors.white60,
              labelColor: Colors.yellow,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(
                  text: "Trim",
                  icon: Icon(Icons.cut_rounded),
                ),
                Tab(
                  text: "Mute",
                  icon: Icon(Icons.music_off_outlined),
                )
              ]),
          title: const Text("EDITOR"),
          actions: [
            currentMode == muteMode && isProcessingMode == true
                ? TextButton(
                    onPressed: () {
                      isProcessingMode = false;
                      setState(() {});
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ))
                : Container(),
            ValueListenableBuilder(
                valueListenable: TrimmerPage.deletingMode,
                builder: (context, bool, text) {
                  print(bool);
                  return bool == true
                      ? InkWell(
                          child: const Icon(Icons.delete),
                          onTap: () {
                            mutedSections
                                .removeAt(TrimmerPage.deletingIndex.value);
                            TrimmerPage.deletingMode.value = false;
                            setState(() {});
                          },
                        )
                      : Container();
                }),
            IconButton(
              icon: Icon(
                (currentMode == trimMode) ||
                        (currentMode == muteMode && !isProcessingMode)
                    ? Icons.save
                    : Icons.done,
                color: !isLoading || startValue.toInt() - endTemp.toInt() >= 1
                    ? Colors.white
                    : Colors.white60,
              ),
              onPressed: !isLoading
                  ? () async {
                      if (!isProcessingMode || currentMode == trimMode) {
                        if (endTemp.toInt() - startValue.toInt() >= 1) {
                          isLoading = true;
                          setState(() {});
                          await trimmer.saveTrimmedVideo(
                            ffmpegCommand: mutedSections.isNotEmpty
                                ? MuteModel.ffmpegMuteCommand(
                                    mutedSections: mutedSections,
                                    startTrim: startValue.toInt(),
                                    endTrim: endTemp.toInt())
                                : null,
                            customVideoFormat:
                                mutedSections.isNotEmpty ? ".mp4" : null,
                            startValue: startValue * 1000,
                            endValue: endTemp * 1000,
                            onSave: (String? outputPath) async {
                              Directory d = await getExternalStoragePath();
                              String title = widget.flag.title != null
                                  ? "${DateTime.now().microsecondsSinceEpoch}_${widget.flag.title}"
                                  : DateTime.now()
                                      .microsecondsSinceEpoch
                                      .toString();
                              File finalOutputPath =
                                  File("${d.path}/$title.mp4");
                              String command =
                                  '-i ${outputPath.toString()} -i $logoPath -filter_complex overlay=10:10 -codec:a copy -q:v 4 -q:a 4 ${finalOutputPath.path}';
                              FFmpegKit.executeAsync(command, (session) async {
                                SessionState state = await session.getState();
                                if (state == SessionState.completed) {
                                  print(session.getCommand().toString());
                                  File(outputPath.toString()).deleteSync();
                                  VideoModel videoModel = VideoModel(
                                    id: widget.flag.id,
                                    path: finalOutputPath.path,
                                    title: widget.flag.title,
                                    dateTime: DateTime.now(),
                                    videoThumbnail: widget.data.videoThumbnail!,
                                    videoDuration: widget.data.videoDuration!,
                                  );
                                  await Boxes.exportedVideoBox.add(videoModel);
                                  widget.items
                                      .putAt(
                                    widget.videoIndex,
                                    widget.data
                                      ..flags![widget.flagIndex].isExtracted =
                                          true,
                                  )
                                      .then((value) {
                                    if (context
                                            .read<EditedVideoBloc>()
                                            .state
                                            .uploadingState !=
                                        RequestState.loading) {
                                      context.read<EditedVideoBloc>().add(
                                            UploadEvent(context: context),
                                          );
                                    }
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      Routes.homePage,
                                      (route) => false,
                                    );
                                  });
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text("something went wrong"),
                                    ));
                                  }
                                }
                              });
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            backgroundColor: Colors.white,
                            content: Text(
                              "please choose a valid trimming area ",
                              style: TextStyle(color: Colors.black),
                            ),
                          ));
                        }
                      } else {
                        TrimmerPage.model = MuteModel(
                            muteStart: muteStart.toInt(),
                            muteEnd: muteEnd.toInt());
                        MuteModel.verifyMuteModel(
                            model: TrimmerPage.model!,
                            muteModelList: mutedSections);
                        setState(() {
                          isProcessingMode = false;
                        });
                      }
                    }
                  : null,
            )
          ],
        ),
        body: File(widget.file.path).existsSync() == true
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      color: Colors.black,
                      child: VideoViewer(trimmer: trimmer),
                    ),
                  ),
                  Expanded(
                    child: TrimEditor(
                      endMute: muteEnd,
                      startMute: muteStart,
                      startValue: startValue,
                      endValue: endTemp,
                      rebuildScrubber: scrubberRebuild,
                      trimmer: trimmer,
                      viewerWidth: MediaQuery.of(context).size.width,
                      onChangeStart: (value) {
                        if (currentMode == muteMode &&
                            isProcessingMode == false) {
                          isProcessingMode = true;
                        }
                        setState(() {
                          if (currentMode == trimMode) {
                            startValue = (value / 1000);
                          } else {
                            muteStart = value / 1000;
                            if (muteStart < startValue) {
                              muteStart = startValue;
                              if (showSnackBarRight) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  backgroundColor: Colors.white,
                                  content: Text(
                                    "couldn't Mute outside of specified trimming area.",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ));
                              }
                              showSnackBarRight = false;
                            }
                          }
                        });
                      },
                      onChangeEnd: (value) {
                        if (currentMode == muteMode &&
                            isProcessingMode == false) {
                          isProcessingMode = true;
                        }
                        setState(() {
                          if (currentMode == trimMode) {
                            endValue = value / 1000;
                            endTemp = endValue;
                          } else {
                            muteEnd = value / 1000;
                            if (muteEnd > endTemp) {
                              muteEnd = endTemp;
                              if (showSnackBarEnd) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  backgroundColor: Colors.white,
                                  content: Text(
                                    "couldn't Mute outside of specified trimming area.",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ));
                              }
                              showSnackBarEnd = false;
                            }
                          }
                          trimmer.videoPlayerController!
                              .seekTo(const Duration(seconds: 0));
                          if (currentMode == trimMode) {
                            pausedValueTrimMode = trimmer.videoPlayerController!
                                    .value.position.inSeconds
                                    .toInt() -
                                1;
                          } else {
                            pausedValueMuteMode = trimmer.videoPlayerController!
                                    .value.position.inSeconds
                                    .toInt() -
                                1;
                          }
                        });
                      },
                      onChangePlaybackState: (value) {
                        setState(() {
                          _isPlaying = value;
                        });
                      },
                      flagModel: widget.flag,
                      videoDuration: widget.videoDuration,
                      fit: BoxFit.cover,
                      mutedSections: mutedSections,
                    ),
                  ),
                  !isLoading
                      ? Expanded(
                          child: TextButton(
                            child: _isPlaying
                                ? const Icon(
                                    Icons.pause,
                                    size: 50.0,
                                    color: Colors.white,
                                  )
                                : const Icon(
                                    Icons.play_arrow,
                                    size: 50.0,
                                    color: Colors.white,
                                  ),
                            onPressed: () async {
                              if (currentMode == trimMode) {
                                if (pausedValueTrimMode != -1) {
                                  pausedValueTrimMode = trimmer
                                      .videoPlayerController!
                                      .value
                                      .position
                                      .inSeconds;
                                }
                                bool playbackState =
                                    await trimmer.videPlaybackControl(
                                  startValue: ((pausedValueTrimMode == 0 ||
                                              pausedValueTrimMode == endTemp ||
                                              pausedValueTrimMode ==
                                                  endTemp - 1 ||
                                              pausedValueTrimMode == -1)
                                          ? (startValue)
                                          : (pausedValueTrimMode)) *
                                      1000,
                                  endValue: endValue,
                                );
                                setState(() {
                                  _isPlaying = playbackState;
                                  pausedValueTrimMode = trimmer
                                      .videoPlayerController!
                                      .value
                                      .position
                                      .inSeconds;
                                });
                              } else {
                                if (pausedValueMuteMode != -1) {
                                  pausedValueMuteMode = trimmer
                                      .videoPlayerController!
                                      .value
                                      .position
                                      .inSeconds;
                                }
                                bool playbackState =
                                    await trimmer.videPlaybackControl(
                                  startValue: ((pausedValueMuteMode == 0 ||
                                              pausedValueMuteMode == endTemp ||
                                              pausedValueMuteMode ==
                                                  endTemp - 1 ||
                                              pausedValueMuteMode == -1)
                                          ? (muteStart)
                                          : (pausedValueMuteMode)) *
                                      1000,
                                  endValue: muteEnd.toDouble(),
                                );
                                setState(() {
                                  _isPlaying = playbackState;
                                  pausedValueMuteMode = trimmer
                                      .videoPlayerController!
                                      .value
                                      .position
                                      .inSeconds;
                                });
                              }
                            },
                          ),
                        )
                      : const LoadingWidget()
                ],
              )
            : const Center(
                child: Text("Unknown video"),
              ),
      ),
    );
  }
}
