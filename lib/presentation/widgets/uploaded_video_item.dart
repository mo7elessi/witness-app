import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/data/model/api/video_model.dart';
import 'package:nice_shot/presentation/widgets/action_widget.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/functions/functions.dart';
import '../../core/themes/app_theme.dart';
import '../../core/util/my_alert_dialog.dart';
import '../../core/util/my_box_decoration.dart';
import '../features/edited_videos/bloc/edited_video_bloc.dart';
import '../features/flags/pages/uploaded_flags.dart';
import '../features/raw_videos/bloc/raw_video_bloc.dart';
import '../features/video_player/video_player_page.dart';
import 'alert_dialog_widget.dart';
import 'loading_widget.dart';

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onLongPress: () {
          showModalBottomSheet(
            backgroundColor: Colors.white,
            elevation: MySizes.elevation,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(MySizes.sheetRadius),
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
                              message: "are you sure delete ${videoModel.name}",
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
                            final video = VideoModel(
                              id: videoModel.id,
                              name: controller.text,
                              categoryId: "1",
                            );
                            if (isEditedVideo) {
                              editedVideoBloc
                                  .add(UpdateVideoEvent(video: video));
                            } else {
                              rawVideoBloc
                                  .add(UpdateRawVideoEvent(video: video));
                            }
                          }
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                  ActionWidget(
                    title: "Share",
                    icon: Icons.share,
                    function: () async {
                      await Share.shareWithResult(
                        videoModel.videoUrl!,
                      ).then((value) => Navigator.pop(context));
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
                          TextStyle infoStyle =
                              Theme.of(context).textTheme.bodyText2!;
                          return AlertDialog(
                            actionsAlignment: MainAxisAlignment.center,
                            actionsPadding: const EdgeInsets.all(4.0),
                            alignment: AlignmentDirectional.center,
                            title: const Text(
                              "MORE DETAILS",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Title: ${videoModel.name}",
                                  style: infoStyle,
                                ),
                                const SizedBox(
                                  height: MySizes.verticalSpace / 2,
                                ),
                                Text(
                                  "Duration: ${formatDuration(castingDuration(duration: videoModel.duration!))}",
                                  style: infoStyle,
                                ),
                                const SizedBox(
                                  height: MySizes.verticalSpace / 2,
                                ),
                                Text(
                                  "URL: ${videoModel.videoUrl}",
                                  style: infoStyle,
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
              return isEditedVideo
                  ? VideoPlayerPage(url: videoModel.videoUrl)
                  : UploadedFlagsPage(rawVideoId: videoModel.id.toString());
            },
          ));
        },
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: myBoxDecoration,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: "${videoModel.thumbnailUrl}",
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            const LoadingWidget(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  width: 50.0,
                  height: 50.0,
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white.withOpacity(0.8),
                    size: 50.0,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      videoModel.name.toString(),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            //videoModel.duration
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.all(5.0),
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Text(
                  formatDuration(castingDuration(duration: videoModel.duration ?? "00:00:00.00")),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
