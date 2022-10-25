import 'package:flutter/material.dart';
import 'package:nice_shot/presentation/widgets/slidable_action_widget.dart';

import '../../core/routes/routes.dart';
import '../../data/network/local/cache_helper.dart';
import 'alert_dialog_widget.dart';

class LogoutWidget extends StatelessWidget {
  const LogoutWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  ActionWidget(
          function: () => showDialog(
            context: context,
            builder: (context) {
              return AlertDialogWidget(
                title: "Logout",
                function: () {
                  CacheHelper.clearData(key: "user")
                      .then((value) => Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.loginPage,
                        (route) => false,
                  ));
                },
                message: "Are you sure logout from application?",
              );
            },
          ),
          title: "Logout", icon: Icons.exit_to_app,
        );

  }
}
