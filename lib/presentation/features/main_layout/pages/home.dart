import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/core/util/global_variables.dart';
import 'package:nice_shot/core/routes/routes.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/presentation/features/edited_videos/bloc/edited_video_bloc.dart';
import 'package:nice_shot/presentation/features/main_layout/bloc/main_layout_bloc.dart';
import 'package:nice_shot/presentation/features/profile/bloc/user_bloc.dart';
import 'package:nice_shot/presentation/features/profile/pages/profile_page.dart';
import 'package:nice_shot/presentation/features/raw_videos/bloc/raw_video_bloc.dart';
import 'package:nice_shot/presentation/features/settings/pages/settings.dart';
import 'package:nice_shot/presentation/widgets/logout_widget.dart';
import 'package:nice_shot/presentation/widgets/snack_bar_widget.dart';
import 'package:nice_shot/providers.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/functions/functions.dart';
import '../../../../core/util/enums.dart';
import '../../../../data/model/api/User_model.dart';
import '../../../../data/network/local/cache_helper.dart';
import '../../../icons/icons.dart';
import '../../../widgets/alert_dialog_widget.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../edited_videos/pages/edited_videos_page.dart';
import '../../edited_videos/pages/uploaded_videos_page.dart';
import '../../permissions/permissions.dart';
import '../../raw_videos/pages/raw_videos_page.dart';
import '../../raw_videos/pages/uploaded_raw_videos_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await AppPermissions.checkPermissions().then((value) {
        permissionsGranted = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      context.read<UserBloc>().add(GetUserDataEvent());
      context.read<EditedVideoBloc>().add(
            GetEditedVideosEvent(id: userId.toString()),
          );
      context.read<RawVideoBloc>().add(
            GetRawVideosEvent(id: userId.toString()),
          );
      return BlocBuilder<MainLayoutBloc, MainLayoutState>(
        builder: (BuildContext context, state) {
          MainLayoutBloc bloc = context.read<MainLayoutBloc>();
          return Scaffold(
            appBar: AppBar(
              title: Text(drawerTitles[bloc.currentIndex].toUpperCase()),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      UserModel? user = state.user?.data;
                      return DrawerHeader(
                        decoration:
                            const BoxDecoration(color: MyColors.primaryColor),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 40.0,
                                    backgroundColor: Colors.red.shade100,
                                    backgroundImage: NetworkImage(
                                      "${user?.logoUrl}",
                                    ),
                                  ),
                                  const SizedBox(
                                      height: MySizes.horizontalSpace),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        user?.name ?? "loading..",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: MyColors.backgroundColor,
                                            ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child:
                                  const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ListView.separated(
                    separatorBuilder: (context, index) => index == (pages.length-1)
                        ? const Padding(
                            padding: EdgeInsets.all(MySizes.widgetSideSpace),
                            child: Text("Others"),
                          )
                        : const SizedBox(),
                    shrinkWrap: true,
                    itemCount: drawerTitles.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        tileColor: bloc.currentIndex == index
                            ? Colors.grey.shade200
                            : MyColors.scaffoldBackgroundColor,
                        leading: drawerIcons[index],
                        title: Text(drawerTitles[index]),
                        onTap: () {
                          Navigator.pop(context);
                          bloc.add(ChangeScaffoldBodyEvent(index));
                        },
                      );
                    },
                  ),
                  const LogoutWidget(),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              elevation: 5.0,
              onPressed: () async {
                if (permissionsGranted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.cameraPage,
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(snackBarWidget(
                    message:
                        "Required permissions were not granted!, Open settings and give permissions.",
                    label: "SETTINGS",
                    onPressed: () => openAppSettings(),
                  ));
                }
              },
              backgroundColor: MyColors.primaryColor,
              child: const Icon(Icons.camera_alt),
            ),
            body: pages[bloc.currentIndex],
          );
        },
      );
    });
  }
}

List<Widget> pages = [
  const RawVideosPage(),
  const EditedVideoPage(),
  const UploadedEditedVideoPage(),
  const UploadedRawEditedVideoPage(),
  const ProfilePage(),
  const SettingsPage(),
];
List<String> drawerTitles = [
  'Raw Videos',
  'Edited Videos',
  'Edited Videos Uploaded',
  'Raw Videos Uploaded',
  'Profile',
  'Settings',
];
List<Icon> drawerIcons = const [
  Icon(Icons.flag, color: Colors.black54),
  Icon(Icons.video_settings, color: Colors.black54),
  Icon(Icons.upload, color: Colors.black54),
  Icon(Icons.upload, color: Colors.black54),
  Icon(Icons.person, color: Colors.black54),
  Icon(Icons.settings, color: Colors.black54),
];
