import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/core/util/my_box_decoration.dart';
import 'package:nice_shot/data/model/api/video_model.dart' as video;
import 'package:nice_shot/presentation/features/edited_videos/bloc/edited_video_bloc.dart';
import 'package:nice_shot/presentation/widgets/flag_count_widget.dart';
import 'package:nice_shot/presentation/widgets/slidable_action_widget.dart';
import 'package:nice_shot/presentation/widgets/snack_bar_widget.dart';
import 'package:nice_shot/presentation/widgets/upload_button_widget.dart';
import 'package:nice_shot/presentation/widgets/upload_video_loading_widget.dart';
import 'package:nice_shot/presentation/widgets/video_image_widget.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/functions/functions.dart';
import '../../core/util/enums.dart';
import '../../core/util/global_variables.dart';
import '../../core/util/my_alert_dialog.dart';
import '../../data/model/video_model.dart';
import '../features/raw_videos/bloc/raw_video_bloc.dart';
import 'alert_dialog_widget.dart';
import '../features/flags/pages/flags_by_video.dart';
import '../features/video_player/video_player_page.dart';
import 'empty_video_list_widget.dart';
import 'loading_widget.dart';

final videoInfo = FlutterVideoInfo();
VideoData? videoData;

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
          List<int> keys = items.keys.cast<int>().toList();
          if (items.isNotEmpty) {
            return ListView.separated(
              separatorBuilder: (context, index) {
                final key = keys[index];
                final VideoModel data = items.get(key)!;
                return File(data.path.toString()).existsSync() == true
                    ? const SizedBox(height: MySizes.verticalSpace)
                    : const SizedBox();
              },
              itemCount: keys.length,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (_, index) {
                final key = keys[index];

                final VideoModel data = items.get(key)!;

                final String time =
                    DateFormat().add_jm().format(data.dateTime!);
                final String date =
                    DateFormat().add_yMEd().format(data.dateTime!);
                final title = data.title == null
                    ? data.path!.split("/").last
                    : data.path!.split("_").last;

                return Builder(builder: (context) {
                  if(!isEditedVideo && data != null) {
                    for (var flagModel in data.flags!) {
                      List duration = data.videoDuration!.split(":");
                      final videoDuration = Duration(
                        seconds: int.parse(
                            duration.last.toString().split(".").first),
                        minutes: int.parse(duration[1]),
                        hours: int.parse(duration.first),
                      );

                      List flagPoint = flagModel.flagPoint!.split(":");
                      Duration point = Duration(
                        seconds: int.parse(
                            flagPoint.last.toString().split(".").first),
                        minutes: int.parse(flagPoint[1]),
                        hours: int.parse(flagPoint.first),
                      );

                      Duration start = point -
                          Duration(
                            seconds:
                                point.inSeconds >= 10 ? 10 : point.inSeconds,
                            minutes: 0,
                          );
                      Duration end = Duration(
                        seconds:
                            (point.inSeconds + 10) <= videoDuration.inSeconds
                                ? point.inSeconds + 10
                                : videoDuration.inSeconds,
                        minutes: 0,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                  items.deleteAt(index);
                                                  Navigator.pop(context);
                                                });
                                              },
                                            );
                                          },
                                        ).then(
                                            (value) => Navigator.pop(context));
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

                                              await items.putAt(
                                                  index,
                                                  data
                                                    ..title = controller.text);
                                              await items
                                                  .putAt(
                                                    index,
                                                    data..path = newPath,
                                                  )
                                                  .then(
                                                    (value) =>
                                                        Navigator.pop(context),
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
                                      title: "Upload",
                                      icon: Icons.upload,
                                      function: () {
                                        if(isEditedVideo) {
                                          videoBloc.add(

                                          UploadVideoEvent(
                                            index: index,
                                            video: video.VideoModel(
                                              categoryId: "1",
                                              name: title,
                                              userId: userId,
                                              file: File(data.path!),
                                            ),
                                          ),
                                        );
                                        }else{

                                          rawVideoBloc.add(
                                              UploadRawVideoEvent(
                                                index: index,
                                                video: video.VideoModel(
                                                  categoryId: "1",
                                                  name: title,
                                                  userId: userId,
                                                  file:
                                                  File(data.path!),
                                                ),
                                                tags: data.flags!,
                                              ));
                                        }
                                        Navigator.pop(context);
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
                                            return AlertDialog(
                                              actionsAlignment:
                                                  MainAxisAlignment.center,
                                              actionsPadding:
                                                  const EdgeInsets.all(4.0),
                                              alignment:
                                                  AlignmentDirectional.center,
                                              title: const Text(
                                                "MORE DETAILS",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              content: FutureBuilder(
                                                  future: getVideoInfo(
                                                      path: data.path!),
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<dynamic>
                                                              state) {
                                                    if (state.connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Center(
                                                          child:
                                                              LoadingWidget());
                                                    } else {
                                                      Duration duration =
                                                          Duration(
                                                        milliseconds: videoData!
                                                            .duration!
                                                            .toInt(),
                                                      );
                                                      int size =
                                                          videoData!.filesize!;
                                                      return Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Title: $title",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText2,
                                                          ),
                                                          const SizedBox(
                                                            height: MySizes
                                                                    .verticalSpace /
                                                                2,
                                                          ),
                                                          Text(
                                                            "File Size: ${size.readableFileSize()}",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText2,
                                                          ),
                                                          const SizedBox(
                                                            height: MySizes
                                                                    .verticalSpace /
                                                                2,
                                                          ),
                                                          Text(
                                                            "Duration: ${formatDuration(duration)}",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText2,
                                                          ),
                                                          const SizedBox(
                                                            height: MySizes
                                                                    .verticalSpace /
                                                                2,
                                                          ),
                                                          Text(
                                                            "Location: ${data.path!}",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText2,
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                  }),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("CLOSE")),
                                              ],
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
                          },
                          onTap: () {
                            if (File(data.path.toString())
                                .existsSync() ==
                                false) {
                              SchedulerBinding.instance
                                  .addPostFrameCallback((_) async {
                                items.deleteAt(index);

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  snackBarWidget(
                                      message:
                                      "This video is deleted!"),
                                );
                              });
                            }else {
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  if (isEditedVideo) {

                                   return VideoPlayerPage(path: data.path);
                                  }
                                  return FlagsByVideoPage(
                                    flags: data.flags ?? [],
                                    path: data.path ?? "",
                                    data: data,
                                    videoIndex: index,
                                  );
                                },
                              ),
                            );
                            }
                          },
                          child: Row(
                            children: [
                              VideoImageWidget(
                                  videoThumbnailPath: data.videoThumbnail),
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
                                        const Spacer(),
                                        !isEditedVideo
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: FlagCountWidget(
                                                    count: data.flags!.length),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                    Text(
                                      "$date At $time",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(fontSize: 10.0),
                                    ),
                                    const SizedBox(
                                        height: MySizes.verticalSpace),
                                    if (isEditedVideo)
                                      BlocBuilder<EditedVideoBloc,
                                          EditedVideoState>(
                                        builder: (context, state) {
                                          switch (state.uploadingState) {
                                            case RequestState.loading:
                                              if (state.index == index) {
                                                return UploadVideoLoadingWidget(
                                                  videoBloc: videoBloc,
                                                  isEditedVideo: isEditedVideo,
                                                );
                                              }
                                              return UploadButtonWidget(
                                                color: Colors.grey.shade100,
                                                function: () {
                                                  _showHint(
                                                    context: context,
                                                    function: () {
                                                      videoBloc.add(
                                                          CancelUploadVideoEvent(
                                                              taskId: state
                                                                  .taskId!));
                                                      videoBloc
                                                          .add(UploadVideoEvent(
                                                        index: index,
                                                        video: video.VideoModel(
                                                          categoryId: "1",
                                                          name: title,
                                                          userId: userId,
                                                          file:
                                                              File(data.path!),
                                                        ),
                                                      ));
                                                      Navigator.pop(context);
                                                    },
                                                  );
                                                },
                                              );
                                            default:
                                              return UploadButtonWidget(
                                                function: () {
                                                  videoBloc
                                                      .add(UploadVideoEvent(
                                                    index: index,
                                                    video: video.VideoModel(
                                                      categoryId: "1",
                                                      name: title,
                                                      userId: userId,
                                                      file: File(data.path!),
                                                    ),
                                                  ));
                                                },
                                              );
                                          }
                                        },
                                      ),
                                    if (!isEditedVideo)
                                      BlocBuilder<RawVideoBloc, RawVideoState>(
                                        builder: (context, state) {
                                          switch (state.uploadingState) {
                                            case RequestState.loading:
                                              if (state.index == index) {
                                                return UploadVideoLoadingWidget(
                                                  rawVideoBloc: rawVideoBloc,
                                                  isEditedVideo: false,
                                                );
                                              }
                                              return UploadButtonWidget(
                                                color: Colors.grey.shade100,
                                                function: () {
                                                  _showHint(
                                                    context: context,
                                                    function: () {
                                                      rawVideoBloc.add(
                                                          CancelUploadRawVideoEvent(
                                                              taskId: state
                                                                  .taskId!));
                                                      rawVideoBloc.add(
                                                          UploadRawVideoEvent(
                                                        index: index,
                                                        video: video.VideoModel(
                                                          categoryId: "1",
                                                          name: title,
                                                          userId: userId,
                                                          file:
                                                              File(data.path!),
                                                        ),
                                                        tags: data.flags!,
                                                      ));
                                                      Navigator.pop(context);
                                                    },
                                                  );
                                                },
                                              );

                                            default:
                                              return UploadButtonWidget(
                                                function: () {
                                                  rawVideoBloc
                                                      .add(UploadRawVideoEvent(
                                                    index: index,
                                                    tags: data.flags!,
                                                    video: video.VideoModel(
                                                      categoryId: "1",
                                                      name: title,
                                                      userId: userId,
                                                      file: File(data.path!),
                                                    ),
                                                  ));
                                                },
                                              );
                                          }
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                });
              },
            );
          }
          return const EmptyVideoListWidget();
        },
      ),
    );
  }

  Future getVideoInfo({required String path}) async {
    videoData = await videoInfo.getVideoInfo(path);
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
