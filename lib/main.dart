import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/data/model/api/login_model.dart';
import 'package:nice_shot/logic/network_bloc/network_bloc.dart';
import 'package:nice_shot/presentation/features/auth/pages/register_page.dart';
import 'package:nice_shot/presentation/features/main_layout/pages/home.dart';
import 'package:nice_shot/presentation/features/permissions/allow_access_page.dart';
import 'package:nice_shot/presentation/features/permissions/permissions.dart';
import 'package:nice_shot/logic/debugs/bloc_delegate.dart';
import 'package:nice_shot/presentation/router/app_router.dart';
import 'package:nice_shot/presentation/widgets/snack_bar_widget.dart';
import 'package:nice_shot/providers.dart';
import 'core/functions/functions.dart';
import 'core/util/enums.dart';
import 'core/util/global_variables.dart';
import 'data/network/local/cache_helper.dart';
import 'data/network/remote/dio_helper.dart';
import 'injection_container.dart' as di;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  DioHelper.init();
  ByteData byteData = await rootBundle.load('assets/images/red_logo.png');
  FFmpegKitConfig.enableFFmpegSessionCompleteCallback((session) {
    final sessionId = session.getSessionId();
  });
  String logoPath = await getLogoPath();
  File(logoPath).writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  await CacheHelper.init();
  await di.init();
  final directory = await path.getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  await Hive.initFlutter();
  registerAdapters();
  await openBoxes();
  await AppPermissions.checkPermissions().then((value) {
    permissionsGranted = value;
  });
  Widget? page;
  await CacheHelper.saveData(key: "sync", value: false);
  final user = CacheHelper.getData(key: "user");
  if (user != null) {
    final data = LoginResponse.fromJson(json.decode(user));
    setUser(user: data);
    setToken(token: data.token!);
    setUserId(id: "${data.user!.id}");
    page = const MainLayout();
  }
  if (user == null && permissionsGranted) page = RegisterPage();
  if (!permissionsGranted) page = const AllowAccessPage();

  BlocOverrides.runZoned(() {
    runApp(Witness(page: page!));
  }, blocObserver: ApplicationBlocObserver());
  FlutterNativeSplash.remove();
}

class Witness extends StatelessWidget {
  final Widget page;

  const Witness({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Witness',
        theme: Themes.theme,
        onGenerateRoute: Routers.generateRoute,
        home: BlocConsumer<NetworkBloc, NetworkState>(
          listener: (context, state) {
            switch (state.state!) {
              case InternetConnectionState.connected:
                ScaffoldMessenger.of(context).showSnackBar(
                  snackBarWidget(message: state.message!),
                );
                break;
              case InternetConnectionState.disconnected:
                ScaffoldMessenger.of(context).showSnackBar(
                  snackBarWidget(message: state.message!),
                );
                break;
            }
          },
          builder: (context, state) => page,
        ),
      ),
    );
  }
}
