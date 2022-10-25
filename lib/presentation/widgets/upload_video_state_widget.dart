import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:hive/hive.dart';
import 'package:nice_shot/core/functions/functions.dart';
import 'package:nice_shot/presentation/widgets/snack_bar_widget.dart';
import 'package:nice_shot/presentation/widgets/upload_video_loading_widget.dart';

import '../../core/themes/app_theme.dart';
import '../../core/util/enums.dart';
import '../../core/util/global_variables.dart';
import '../../data/model/video_model.dart';
import '../../data/model/api/video_model.dart' as video;
import '../features/edited_videos/bloc/edited_video_bloc.dart';
import '../features/raw_videos/bloc/raw_video_bloc.dart';
import 'alert_dialog_widget.dart';
import 'flag_count_widget.dart';
final videoInfo = FlutterVideoInfo();

class UploadVideoStateWidget extends StatelessWidget {
  final EditedVideoBloc videoBloc;
  final RawVideoBloc rawVideoBloc;
  final bool isEditedVideo;
  final int index;
  final Box<VideoModel> box;
  final VideoModel data;
  final String title;

  const UploadVideoStateWidget({
    Key? key,
    required this.videoBloc,
    required this.rawVideoBloc,
    required this.isEditedVideo,
    required this.index,
    required this.box,
    required this.data,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isEditedVideo)
          BlocConsumer<EditedVideoBloc, EditedVideoState>(
            listener: (context, state) {
              if (state.uploadingState == RequestState.loaded &&
                  state.index == index) {
                box.putAt(state.index!, data..isUploaded = true);
                //   videoBloc.add(CheckVideosEvent());
              }
            },
            builder: (context, state) {
              if (state.uploadingState == RequestState.loading &&
                  state.index == index) {
                return UploadVideoLoadingWidget(
                  videoBloc: videoBloc,
                  isEditedVideo: isEditedVideo,
                );
              }
              return uploadStateWidget(
                isUploaded: data.isUploaded ?? false,
                context: context,
              );
            },
          ),
        if (!isEditedVideo)
          BlocConsumer<RawVideoBloc, RawVideoState>(
            listener: (context, state) {
              if (state.uploadingState == RequestState.loaded &&
                  state.index == index) {
                box.putAt(index, data..isUploaded = true);
              }
            },
            builder: (context, state) {
              if (state.uploadingState == RequestState.loading &&
                  state.index == index) {
                return UploadVideoLoadingWidget(
                  rawVideoBloc: rawVideoBloc,
                  isEditedVideo: isEditedVideo,
                );
              }
              return uploadStateWidget(
                isUploaded: data.isUploaded ?? false,
                flagCount: data.flags!.length,
                context: context,
              );
            },
          ),
      ],
    );
  }

  Widget uploadStateWidget({
    required bool isUploaded,
    int? flagCount,
    required BuildContext context,
  }) {
    final editedVideo = video.VideoModel(
      categoryId: "1",
      name: title,
      userId: userId,
      duration: "${data.videoDuration}",
      thumbnail: File(data.videoThumbnail!),
      file: File(data.path!),
    );
    return Align(
      alignment: Alignment.bottomRight,
      child: InkWell(
        onTap: () async {
          if (isUploaded != true) {
            if (isEditedVideo) {
              if (videoBloc.state.uploadingState == RequestState.loading) {
                _showHint(
                  context: context,
                  function: () async{
                    videoBloc.add(CancelUploadVideoEvent(
                      taskId: videoBloc.state.taskId!,
                    ));
                    await videoInfo.getVideoInfo(data.path!).then((value) {
                      if (value!.filesize! > 100000000) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          snackBarWidget(
                            message: "Videos larger than 100MB cannot be uploaded!",
                          ),
                        );
                      }else{
                        videoBloc.add(
                            UploadVideoEvent(video: editedVideo, index: index));
                      }
                    });

                    Navigator.pop(context);
                  },
                );
              } else {
                await videoInfo.getVideoInfo(data.path!).then((value) {
                  if (value!.filesize! > 100000000) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBarWidget(
                        message: "Videos larger than 100MB cannot be uploaded!",
                      ),
                    );
                  }else{
                    videoBloc.add(
                        UploadVideoEvent(video: editedVideo, index: index));
                  }
                });
              }
            } else if (!isEditedVideo) {
              if (rawVideoBloc.state.uploadingState == RequestState.loading) {
                _showHint(
                  context: context,
                  function: () async{
                    rawVideoBloc.add(CancelUploadRawVideoEvent(
                      taskId: rawVideoBloc.state.taskId!,
                    ));
                    await videoInfo.getVideoInfo(data.path!).then((value) {
                      if (value!.filesize! > 100000000) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          snackBarWidget(
                            message: "Videos larger than 100MB cannot be uploaded!",
                          ),
                        );
                      }else{
                        rawVideoBloc.add(UploadRawVideoEvent(
                          index: index,
                          tags: data.flags!,
                          video: editedVideo,
                        ));
                      }
                    });
                    Navigator.pop(context);

                  },
                );
              } else {
                await videoInfo.getVideoInfo(data.path!).then((value) {
                  if (value!.filesize! > 100000000) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBarWidget(
                        message: "Videos larger than 100MB cannot be uploaded!",
                      ),
                    );
                  }else{
                    rawVideoBloc.add(UploadRawVideoEvent(
                      index: index,
                      tags: data.flags!,
                      video: editedVideo,
                    ));
                  }
                });

              }
            }
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5.0),
              margin: const EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MySizes.radius),
                border: Border.fromBorderSide(
                  BorderSide(
                    color: isUploaded ? Colors.green : MyColors.primaryColor,
                    width: MySizes.borderWidth,
                  ),
                ),
              ),
              child: Text(
                isUploaded ? "UPLOADED" : "UPLOAD",
                style: TextStyle(
                  color: isUploaded ? Colors.green : MyColors.primaryColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ),
            !isEditedVideo
                ? Container(
                    margin: const EdgeInsets.only(right: 12.0),
                    child: FlagCountWidget(
                      count: flagCount!,
                      isUploaded: isUploaded,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void _showHint({
    required BuildContext context,
    required Function function,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialogWidget(
          message: "You cannot upload more than one"
              "video at the same time, if you have to,"
              " un-upload the current video and upload this video."
              "",
          title: "UPLOAD VIDEO",
          function: () => function(),
        );
      },
    );
  }
}
