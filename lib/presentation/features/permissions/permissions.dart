import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  static Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  static Future<PermissionStatus> requestMicrophonePermission() async {
    return await Permission.microphone.request();
  }

  static Future<PermissionStatus> requestStoragePermission() async {
    return await Permission.storage.request();
  }

  static Future<bool> checkPermissions() async {
    if ((await Permission.storage.status) == PermissionStatus.granted &&
        (await Permission.camera.status) == PermissionStatus.granted &&
        (await Permission.microphone.status) == PermissionStatus.granted) {
      return true;
    }else{
      return false;
    }
  }
}
