import 'package:flutter/material.dart';
import 'package:nice_shot/presentation/features/raw_videos/bloc/raw_video_bloc.dart';

import '../../core/themes/app_theme.dart';
import '../features/edited_videos/bloc/edited_video_bloc.dart';

class UploadVideoLoadingWidget extends StatelessWidget {
  final EditedVideoBloc? videoBloc;
  final RawVideoBloc? rawVideoBloc;
  final bool isEditedVideo;

  const UploadVideoLoadingWidget(
      {Key? key,
      this.videoBloc,
      this.rawVideoBloc,
      required this.isEditedVideo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int progress = isEditedVideo
        ? videoBloc!.state.progressValue!
        : rawVideoBloc!.state.progressValue!;
    String taskId =  isEditedVideo ? videoBloc!.state.taskId! : rawVideoBloc!.state.taskId!;
    return Align(
      alignment: Alignment.bottomRight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: LinearProgressIndicator(
              color: MyColors.primaryColor,
              value: progress.toDouble() / 100,
              backgroundColor: Colors.grey.shade100,
              minHeight: 10.0,
            ),
          ),
          const SizedBox(width: MySizes.horizontalSpace),
          Expanded(
            child: Text(
              "$progress%",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: MySizes.horizontalSpace),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                if (isEditedVideo) {
                  videoBloc!.add(CancelUploadVideoEvent(taskId: taskId));
                } else {
                  rawVideoBloc!.add(CancelUploadRawVideoEvent(taskId: taskId));
                }
              },
              child: const Icon(Icons.cancel),
            ),
          ),
        ],
      ),
    );
  }
}
