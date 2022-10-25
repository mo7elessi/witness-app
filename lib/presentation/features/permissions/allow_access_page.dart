import 'package:flutter/material.dart';
import 'package:nice_shot/core/util/global_variables.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/presentation/widgets/primary_button_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/routes/routes.dart';
import '../../../data/network/local/cache_helper.dart';
import 'permissions.dart';

class AllowAccessPage extends StatelessWidget {
  const AllowAccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(MySizes.widgetSideSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Permission Required",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: MySizes.verticalSpace),
              Text(
                  "camera app needs to access the following permission,without this permission,the application could not run properly.",
                  style: Theme.of(context).textTheme.bodyText2!),
              const SizedBox(height: MySizes.verticalSpace * 2),
              permissionWidget(
                icon: Icons.camera_alt,
                title: "CAMERA",
                subTitle: "to record edited_videos.",
                context: context,
              ),
              const SizedBox(height: MySizes.verticalSpace),
              permissionWidget(
                icon: Icons.mic,
                title: "MICROPHONE",
                subTitle: "to record edited_videos with audio.",
                context: context,
              ),
              const SizedBox(height: MySizes.verticalSpace),
              permissionWidget(
                icon: Icons.sd_storage,
                title: "STORAGE",
                subTitle: "to save data.",
                context: context,
              ),
              const Spacer(),
              PrimaryButtonWidget(
                function: () async {
                  await Permission.storage.request();
                  await Permission.camera.request();
                  await Permission.microphone.request().then((value) {
                    AppPermissions.checkPermissions().then((value) {
                      permissionsGranted = value;
                      final user = CacheHelper.getData(key: "user");
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        user == null?Routes.registerPage:Routes.homePage,
                        (route) => false,
                      );
                    });
                  });
                },
                text: 'next',
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget permissionWidget({
    required IconData icon,
    required String title,
    required String subTitle,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon,size: 30,color: Colors.black87),
        const SizedBox(width: MySizes.verticalSpace),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 2.0),
            Text(
              subTitle,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ) ,
     ],
    );
  }
}
