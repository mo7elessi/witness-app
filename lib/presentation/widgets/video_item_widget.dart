import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/core/util/my_box_decoration.dart';
import 'package:nice_shot/presentation/features/edited_videos/bloc/edited_video_bloc.dart';
import 'package:nice_shot/presentation/widgets/action_widget.dart';
import 'package:nice_shot/presentation/widgets/snack_bar_widget.dart';
import 'package:nice_shot/presentation/widgets/upload_video_state_widget.dart';
import 'package:nice_shot/presentation/widgets/video_details_widget.dart';
import 'package:nice_shot/presentation/widgets/video_image_widget.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/functions/functions.dart';
import '../../core/util/enums.dart';
import '../../core/util/my_alert_dialog.dart';
import '../../data/model/video_model.dart';
import '../features/raw_videos/bloc/raw_video_bloc.dart';
import 'alert_dialog_widget.dart';
import '../features/flags/pages/flags_by_video.dart';
import '../features/video_player/video_player_page.dart';
import 'empty_video_list_widget.dart';

class VideoItemWidget extends StatelessWidget {
  final Box<VideoModel> box;
  final bool isEditedVideo;

  const VideoItemWidget({
    Key? key,
    required this.box,
    required this.isEditedVideo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    EditedVideoBloc videoBloc = context.read<EditedVideoBloc>();
    RawVideoBloc rawVideoBloc = context.read<RawVideoBloc>();

    return Padding(
      padding: const EdgeInsets.all(MySizes.widgetSideSpace),
      child: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<VideoModel> items, _) {
          final sortedItems = box.values.toList();
          if (sortedItems.isEmpty) {
            return const EmptyVideoListWidget();
          }
          return ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(height: MySizes.verticalSpace);
            },
            itemCount: sortedItems.length,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, index) {
              List<int> keys = items.keys.cast<int>().toList();
              final key = keys[index];
              final VideoModel data = items.get(key)!;

              final String time = DateFormat().add_jm().format(data.dateTime!);
              final String date =
                  DateFormat().add_yMEd().format(data.dateTime!);
              final title = data.title == null
                  ? data.path!.split("/").last
                  : data.path!.split("_").last;

              return Builder(
                builder: (context) {
                  box.listenable();
                  context.read<EditedVideoBloc>();
                  if (!isEditedVideo) {
                    for (var flagModel in data.flags!) {
                      int durationShot = int.parse(flagModel.durationShot!);
                      final videoDuration = castingDuration(
                        duration: data.videoDuration!,
                      );
                      Duration point = castingDuration(
                        duration: flagModel.flagPoint!,
                      );
                      Duration start = point -
                          Duration(
                            seconds: point.inSeconds >= durationShot
                                ? durationShot
                                : point.inSeconds,
                          );
                      Duration end = Duration(
                        seconds: (point.inSeconds + durationShot) <=
                                videoDuration.inSeconds
                            ? point.inSeconds + durationShot
                            : videoDuration.inSeconds,
                      );

                      flagModel.startDuration = start;
                      flagModel.endDuration = end;
                    }
                  }
                  return Align(
                    child: Container(
                      height: 110.0,
                      width: double.infinity,
                      decoration: myBoxDecoration,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onLongPress: () {
                            if (videoBloc.state.uploadingState ==
                                    RequestState.loading &&
                                videoBloc.state.path == data.path!) {
                            } else {
                              showModalBottomSheet(
                                backgroundColor: Colors.white,
                                elevation: 8,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10.0),
                                  ),
                                ),
                                builder: (context) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ActionWidget(
                                        title: "Delete",
                                        icon: Icons.delete_forever_rounded,
                                        function: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialogWidget(
                                                message:
                                                    "are you sure delete $title",
                                                title: "delete video",
                                                function: () async {
                                                  await File(data.path!)
                                                      .delete()
                                                      .then((value) {
                                                    box.deleteAt(index);
                                                    Navigator.pop(context);
                                                  });
                                                },
                                              );
                                            },
                                          ).then((value) =>
                                              Navigator.pop(context));
                                        },
                                      ),
                                      ActionWidget(
                                        title: "Edit Title",
                                        icon: Icons.edit,
                                        function: () {
                                          myAlertDialog(
                                            controller: controller,
                                            context: context,
                                            function: () async {
                                              if (controller.text.isNotEmpty) {
                                                String fileName =
                                                    "${DateTime.now().microsecondsSinceEpoch}_${controller.text}.mp4";
                                                await changeFileNameOnly(
                                                    newFileName: fileName,
                                                    file: File(data.path!));

                                                await box.putAt(
                                                    index,
                                                    data
                                                      ..title =
                                                          controller.text);
                                                await box
                                                    .putAt(
                                                      index,
                                                      data..path = newPath,
                                                    )
                                                    .then(
                                                      (value) => Navigator.pop(
                                                          context),
                                                    );
                                              }
                                            },
                                          );
                                        },
                                      ),
                                      if (isEditedVideo)
                                        ActionWidget(
                                          title: "Share",
                                          icon: Icons.share,
                                          function: () async {
                                            await Share.shareFiles(
                                              [data.path!],
                                              text: data.title,
                                            ).then((value) =>
                                                Navigator.pop(context));
                                          },
                                        ),
                                      ActionWidget(
                                        title: "More Details",
                                        icon: Icons.more_horiz,
                                        function: () {
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return VideoDetailsWidget(
                                                data: data,
                                                title: title,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                                context: context,
                              );
                            }
                          },
                          onTap: () {
                            if (File(data.path.toString()).existsSync() ==
                                false) {
                              SchedulerBinding.instance
                                  .addPostFrameCallback((_) async {
                                box.deleteAt(index);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  snackBarWidget(
                                      message: "This video is deleted!"),
                                );
                              });
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    if (isEditedVideo) {
                                      return VideoPlayerPage(path: data.path);
                                    }
                                    if (data.flags!.isNotEmpty) {
                                      return FlagsByVideoPage(
                                        flags: data.flags ?? [],
                                        path: data.path ?? "",
                                        data: data,
                                        videoIndex: index,
                                      );
                                    } else {
                                      return VideoPlayerPage(path: data.path);
                                    }
                                  },
                                ),
                              );
                            }
                          },
                          child: Row(
                            children: [
                              VideoImageWidget(
                                videoThumbnailPath: data.videoThumbnail,
                              ),
                              const SizedBox(width: MySizes.widgetSideSpace),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                        height: MySizes.verticalSpace),
                                    Text(
                                      "$date At $time",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(fontSize: 10.0),
                                    ),
                                    const SizedBox(
                                        height: MySizes.verticalSpace),
                                    UploadVideoStateWidget(
                                      title: title,
                                      isEditedVideo: isEditedVideo,
                                      index: index,
                                      box: box,
                                      data: data,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
