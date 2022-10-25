import 'package:flutter/material.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:nice_shot/core/functions/functions.dart';

import '../../core/themes/app_theme.dart';
import '../../data/model/video_model.dart';
import 'loading_widget.dart';

class VideoDetailsWidget extends StatelessWidget {
  final videoInfo = FlutterVideoInfo();
  VideoData? videoData;
  final VideoModel data;
  final String title;

  VideoDetailsWidget({
    Key? key,
    required this.data,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.all(4.0),
      alignment: AlignmentDirectional.center,
      title: const Text(
        "MORE DETAILS",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      content: FutureBuilder(
          future: getVideoInfo(path: data.path!),
          builder: (BuildContext context, AsyncSnapshot<dynamic> state) {
            if (state.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingWidget());
            } else {
              Duration duration = Duration(
                milliseconds: videoData!.duration!.toInt(),
              );
              int size = videoData!.filesize!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Title: $title",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  const SizedBox(
                    height: MySizes.verticalSpace / 2,
                  ),
                  Text(
                    "File Size: ${size.readableFileSize()}",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  const SizedBox(
                    height: MySizes.verticalSpace / 2,
                  ),
                  Text(
                    "Duration: ${formatDuration(duration)}",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  const SizedBox(
                    height: MySizes.verticalSpace / 2,
                  ),
                  Text(
                    "Location: ${data.path!}",
                    style: Theme.of(context).textTheme.bodyText2,
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
  }

  Future getVideoInfo({required String path}) async {
    videoData = await videoInfo.getVideoInfo(path);
  }
}
