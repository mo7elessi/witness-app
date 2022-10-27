import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:hive/hive.dart';
import 'package:nice_shot/presentation/widgets/snack_bar_widget.dart';
import 'package:nice_shot/presentation/widgets/upload_video_loading_widget.dart';

import '../../core/themes/app_theme.dart';
import '../../core/util/enums.dart';
import '../../core/util/global_variables.dart';
import '../../data/model/flag_model.dart';
import '../../data/model/video_model.dart';
import '../../data/model/api/video_model.dart' as video;
import '../features/edited_videos/bloc/edited_video_bloc.dart';
import '../features/raw_videos/bloc/raw_video_bloc.dart';
import 'alert_dialog_widget.dart';
import 'flag_count_widget.dart';

final videoInfo = FlutterVideoInfo();

class UploadVideoStateWidget extends StatelessWidget {
  final bool isEditedVideo;
  final int index;
  final Box<VideoModel> box;
  final VideoModel data;
  final String title;

  const UploadVideoStateWidget({
    Key? key,
    required this.isEditedVideo,
    required this.index,
    required this.box,
    required this.data,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditedVideoBloc, EditedVideoState>(
      listener: (context, state) {
        if (state.uploadingState == RequestState.loaded &&
            state.path == data.path!) {
          box.putAt(index, data..isUploaded = true);

        }
      },
      builder: (context, state) {
        final EditedVideoBloc videoBloc = context.read<EditedVideoBloc>();

        if (state.uploadingState == RequestState.loading &&
            state.path == data.path!) {
          return UploadVideoLoadingWidget(videoBloc: videoBloc);
        }
        return uploadStateWidget(
          isUploaded: data.isUploaded ?? false,
          context: context,
          flagCount: data.flags?.length ?? 0,
          videoBloc: videoBloc,
        );
      },
    );
  }

  Widget uploadStateWidget({
    required bool isUploaded,
    int? flagCount,
    required BuildContext context,
    required EditedVideoBloc videoBloc,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        !isEditedVideo
            ? Container(
                margin: const EdgeInsets.only(right: 12.0),
                child: FlagCountWidget(
                  count: flagCount!,
                  isUploaded: isUploaded,
                ),
              )
            : Container(),
        InkWell(
          onTap: () async {
            List<FlagModel> flags = data.flags ?? [];

            final editedVideo = video.VideoModel(
              categoryId: "1",
              name: title,
              userId: userId,
              duration: "${data.videoDuration}",
              thumbnail: File(data.videoThumbnail!),
              file: File(data.path!),
            );
            if (isUploaded != true) {
              if (videoBloc.state.uploadingState == RequestState.loading) {
                _showHint(
                  context: context,
                  function: () async {
                    videoBloc.add(CancelUploadVideoEvent(
                      taskId: videoBloc.state.taskId!,
                    ));
                    flags = [];
                    await videoInfo.getVideoInfo(data.path!).then((value) {
                      if (value!.filesize! > 100000000) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          snackBarWidget(
                            message:
                                "Videos larger than 100MB cannot be uploaded!",
                          ),
                        );
                      } else {
                        videoBloc.add(UploadVideoEvent(
                          video: editedVideo,
                          isEditedVideo: isEditedVideo,
                        ));
                      }
                      flags = [];
                    }).then((value) => Navigator.pop(context));
                  },
                );
              } else {
                await videoInfo.getVideoInfo(data.path!).then((value) {
                  if (value!.filesize! > 100000000) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBarWidget(
                        message: "Videos larger than 100 MB cannot be uploaded!",
                      ),
                    );
                  } else {
                    videoBloc.add(UploadVideoEvent(
                      video: editedVideo,
                      isEditedVideo: isEditedVideo,
                      tags: flags,
                    ));
                    flags = [];
                  }

                });
              }
            }
          },
          child: Container(
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
        ),
      ],
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
