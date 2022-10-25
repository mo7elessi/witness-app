import 'package:flutter/material.dart';
import 'package:nice_shot/presentation/features/auth/pages/login_page.dart';
import 'package:nice_shot/presentation/features/auth/pages/register_page.dart';
import 'package:nice_shot/presentation/features/auth/pages/verify_phone.dart';
import 'package:nice_shot/presentation/features/camera/pages/camera_page.dart';
import 'package:nice_shot/presentation/features/permissions/allow_access_page.dart';
import 'package:nice_shot/presentation/features/profile/pages/edit_profile_page.dart';
import 'package:nice_shot/presentation/features/profile/pages/profile_page.dart';
import 'package:nice_shot/presentation/features/settings/pages/reset_password_page.dart';
import 'package:nice_shot/presentation/features/settings/pages/settings.dart';
import '../../core/routes/routes.dart';
import '../features/edited_videos/pages/edited_videos_page.dart';
import '../features/main_layout/pages/home.dart';
import '../features/raw_videos/pages/raw_videos_page.dart';

class Routers {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.homePage:
        return MaterialPageRoute(builder: (_) => const MainLayout());
      case Routes.loginPage:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case Routes.registerPage:
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case Routes.videosPage:
        return MaterialPageRoute(builder: (_) => const RawVideosPage());
      // case Routes.flagsByVideoPage:
      //   return MaterialPageRoute(builder: (_) => FlagsByVideoPage());
      case Routes.extractedVideosPage:
        return MaterialPageRoute(builder: (_) => const EditedVideoPage());
      case Routes.verifyCodePage:
        return MaterialPageRoute(builder: (_) => const VerifyCodePage());
      case Routes.cameraPage:
        return MaterialPageRoute(builder: (_) =>  const CameraPage());
      case Routes.profilePage:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case Routes.editProfilePage:
        return MaterialPageRoute(builder: (_) =>  EditProfilePage());
      case Routes.allowAccessPage:
        return MaterialPageRoute(builder: (_) => const AllowAccessPage());
      case Routes.resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordPage());
        case Routes.settingsPage:
        return MaterialPageRoute(builder: (_) => const SettingsPage());

      default:
        return MaterialPageRoute(builder: (_) {
          return Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          );
        });
    }
  }
}
