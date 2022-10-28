import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/data/network/local/cache_helper.dart';
import 'package:nice_shot/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:nice_shot/presentation/features/edited_videos/bloc/edited_video_bloc.dart';
import 'package:nice_shot/presentation/features/main_layout/bloc/main_layout_bloc.dart';
import 'package:nice_shot/presentation/widgets/action_widget.dart';
import 'package:nice_shot/presentation/widgets/snack_bar_widget.dart';

import '../../core/routes/routes.dart';
import '../../core/util/enums.dart';
import 'alert_dialog_widget.dart';

class LogoutWidget extends StatelessWidget {
  const LogoutWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.logoutState == RequestState.loaded) {
          if (context.read<MainLayoutBloc>().isSync) {
            if (context.read<EditedVideoBloc>().state.uploadingState ==
                RequestState.loading) {
              context.read<EditedVideoBloc>().add(CancelUploadVideoEvent(
                  taskId: context.read<EditedVideoBloc>().state.taskId!));
            }
            context.read<MainLayoutBloc>().add(SyncEvent());
            Navigator.pop(context);
          }
          CacheHelper.clearData(key: "user").then(
            (value) => Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.loginPage,
              (route) => false,
            ),
          );
        } else if (state.logoutState == RequestState.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            snackBarWidget(message: state.message!),
          );
        }
      },
      builder: (context, state) {
        return ActionWidget(
          function: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialogWidget(
                  title: "Logout",
                  function: () {
                    context.read<AuthBloc>().add(LogoutEvent());
                  },
                  message: "Are you sure logout from application?",
                );
              },
            );
          },
          title: "Logout",
          icon: Icons.exit_to_app,
        );
      },
    );
  }
}
