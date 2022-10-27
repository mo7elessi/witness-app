import 'package:flutter/material.dart';
import 'package:nice_shot/presentation/features/raw_videos/bloc/raw_video_bloc.dart';
import 'package:nice_shot/presentation/widgets/alert_dialog_widget.dart';

import '../../core/themes/app_theme.dart';
import '../features/edited_videos/bloc/edited_video_bloc.dart';

class UploadVideoLoadingWidget extends StatelessWidget {
  final EditedVideoBloc videoBloc;

  const UploadVideoLoadingWidget(
      {Key? key,
      required this.videoBloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int progress =  videoBloc.state.progressValue!;
    String taskId =videoBloc.state.taskId!;
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
              minHeight: 5.0,
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
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialogWidget(
                      message: "Are you sure cancel upload video?",
                      title: "Cancel upload",
                      function: (){
                          videoBloc.add(CancelUploadVideoEvent(taskId: taskId));
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              child: const Icon(Icons.cancel, color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
