import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:nice_shot/data/model/api/video_model.dart';
import 'package:nice_shot/presentation/widgets/slidable_action_widget.dart';
import 'package:video_player/video_player.dart';

import '../../core/functions/functions.dart';
import '../../core/themes/app_theme.dart';
import '../../core/util/my_alert_dialog.dart';
import '../../core/util/my_box_decoration.dart';
import '../features/edited_videos/bloc/edited_video_bloc.dart';
import '../features/raw_videos/bloc/raw_video_bloc.dart';
import '../features/video_player/video_player_page.dart';
import 'alert_dialog_widget.dart';
import 'loading_widget.dart';

VideoData? videoData;
final videoInfo = FlutterVideoInfo();
Duration? duration;
VideoPlayerController? _videoPlayerController;

class UploadedVideoItem extends StatelessWidget {
  final VideoModel videoModel;
  final bool isEditedVideo;

  const UploadedVideoItem({
    Key? key,
    required this.videoModel,
    required this.isEditedVideo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    final editedVideoBloc = context.read<EditedVideoBloc>();
    final rawVideoBloc = context.read<RawVideoBloc>();
    return FutureBuilder(
        future: getVideoInfo(url: videoModel.videoUrl.toString()),
        builder: (BuildContext context, AsyncSnapshot<dynamic> state) {
          if (state.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingWidget());
          } else {
            return Material(
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
                                          "are you sure delete ${videoModel.name}",
                                      title: "delete video",
                                      function: () async {
                                        if (isEditedVideo) {
                                          editedVideoBloc.add(
                                            DeleteEditedVideoEvent(
                                                id: videoModel.id.toString()),
                                          );
                                        } else {
                                          rawVideoBloc.add(
                                            DeleteRawVideoEvent(
                                                id: videoModel.id.toString()),
                                          );
                                        }
                                        Navigator.pop(context);
                                      });
                                },
                              ).then((value) => Navigator.pop(context));
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
                                    if (isEditedVideo) {
                                    } else {}
                                  }
                                  Navigator.pop(context);
                                },
                              );
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
                                    actionsAlignment: MainAxisAlignment.center,
                                    actionsPadding: const EdgeInsets.all(4.0),
                                    alignment: AlignmentDirectional.center,
                                    title: const Text(
                                      "MORE DETAILS",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Title: ${videoModel.name}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                        ),
                                        const SizedBox(
                                          height: MySizes.verticalSpace / 2,
                                        ),
                                        Text(
                                          "Duration: ${formatDuration(duration ?? const Duration())}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                        ),
                                        const SizedBox(
                                          height: MySizes.verticalSpace / 2,
                                        ),
                                        Text(
                                          "URL: ${videoModel.videoUrl}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                        ),
                                      ],
                                    ),
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
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return VideoPlayerPage(url: videoModel.videoUrl);
                    },
                  ));
                },
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: myBoxDecoration.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                    const Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.play_arrow,
                          size: 60,
                          color: Colors.white70,
                        )),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              videoModel.name.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              formatDuration(duration ?? const Duration()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Colors.white,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }

  Future<VideoPlayerController> _initVideoPlayer({required String url}) async {
    _videoPlayerController = VideoPlayerController.network(url);
    await _videoPlayerController!.initialize();
    return  _videoPlayerController!;
  }

  Future getVideoInfo({required String url}) async {
    await _initVideoPlayer(url: url).then((value)async {
      duration = value.value.duration;
    });
  }
}
