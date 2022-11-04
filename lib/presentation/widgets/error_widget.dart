import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/presentation/widgets/secondary_button_widget.dart';

import '../../core/util/global_variables.dart';
import '../features/edited_videos/bloc/edited_video_bloc.dart';
import '../features/profile/bloc/user_bloc.dart';
import '../features/raw_videos/bloc/raw_video_bloc.dart';

class ErrorMessageWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final bool? isAction;

  const ErrorMessageWidget({
    Key? key,
    required this.message,
    this.isAction,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message),
        if (isAction == true)
          MaterialButton(
            elevation: 0.0,
            color: MyColors.primaryColor,
            child: const Text(
              "Try again",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              context.read<UserBloc>().add(GetUserDataEvent());
              context.read<EditedVideoBloc>().add(GetEditedVideosEvent());
              context.read<RawVideoBloc>().add(GetRawVideosEvent());
            },
          ),
      ],
    );
  }
}
