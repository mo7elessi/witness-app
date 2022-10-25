import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/presentation/widgets/alert_dialog_widget.dart';
import 'package:nice_shot/presentation/widgets/loading_widget.dart';
import 'package:nice_shot/presentation/widgets/action_widget.dart';
import '../../../../core/routes/routes.dart';
import '../../../widgets/logout_widget.dart';
import '../../auth/bloc/auth_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MySizes.widgetSideSpace),
      child: context.read<AuthBloc>().state.logoutState == RequestState.loading
          ? const LoadingWidget()
          : Column(
              children: [
                ActionWidget(
                  icon: Icons.lock_clock_rounded,
                  function: () => Navigator.pushNamed(
                    context,
                    Routes.resetPassword,
                  ),
                  title: "Reset Password",
                ),
                const SizedBox(height: MySizes.verticalSpace),
                BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state.logoutState == RequestState.loaded) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Routes.registerPage,
                        (route) => false,
                      );
                    }
                  },
                  child: ActionWidget(
                    icon: Icons.delete_forever_rounded,
                    function: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialogWidget(
                            message:
                                "NOTE: If you delete the account, you will not be able to recover it permanently.",
                            title: "Delete My Account",
                            function: () {
                              context
                                  .read<AuthBloc>()
                                  .add(DeleteAccountEvent());
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                    title: "Delete My Account",
                  ),
                ),
                const SizedBox(height: MySizes.verticalSpace),
                const LogoutWidget(),
              ],
            ),
    );
  }
}
