import 'dart:io';
import 'dart:math';

import 'package:external_path/external_path.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../data/model/api/login_model.dart';
import '../../data/model/duration.g.dart';
import '../../data/model/flag_model.dart';
import 'package:path_provider/path_provider.dart';
import '../error/failure.dart';
import '../../data/model/video_model.dart';
import '../strings/failures.dart';
import '../util/global_variables.dart';
import 'package:path_provider/path_provider.dart' as path;

extension FileFormatter on num {
  String readableFileSize() {
    int base = 1024;
    if (this <= 0) return "0";
    final units = ["B", "kB", "MB", "GB", "TB"];
    int digitGroups = (log(this) / log(base)).round();
    return "${NumberFormat("#,##0.#").format(this / pow(base, digitGroups))} ${units[digitGroups]}";
  }
}

String? newPath;

Future<FileSystemEntity> changeFileNameOnly({
  required FileSystemEntity file,
  required String newFileName,
}) async {
  var path = file.path;
  var lastSeparator = path.lastIndexOf(Platform.pathSeparator);

  newPath = path.substring(0, lastSeparator + 1) + newFileName;
  return await file.rename(newPath!);
}

String strDigits(int n) => n.toString().padLeft(2, '0');

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  String twoDigitHours = twoDigits(duration.inHours.remainder(60));
  return "${twoDigitHours != "00" ? twoDigitHours : ""}${twoDigitHours != "00" ? ":" : ""}$twoDigitMinutes:$twoDigitSeconds";
}

Future<Directory> getExternalStoragePath() async {
  var path = await ExternalPath.getExternalStoragePublicDirectory(
    ExternalPath.DIRECTORY_DCIM,
  );
  Directory directory = Directory("$path/witness/records");
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  return directory;
}

Future<Directory> getThumbnailPath() async {
  var path = await ExternalPath.getExternalStoragePublicDirectory(
    ExternalPath.DIRECTORY_DCIM,
  );
  Directory directory = Directory("$path/witness/thumbnails");
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  return directory;
}
Future<Directory> getApplicationStoragePath() async {
  Directory directory = await path.getApplicationDocumentsDirectory();
  return directory;
}

void registerAdapters() {
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(VideoModelAdapter());
  Hive.registerAdapter(FlagModelAdapter());
}

Future openBoxes() async {
  await Hive.openBox<VideoModel>('video_db');
  await Hive.openBox<VideoModel>('exported_video_db');
}

String mapFailureToMessage({required Failure failure}) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return SERVER_FAILURE_MESSAGE;
    case EmptyCacheFailure:
      return EMPTY_CACHE_FAILURE_MESSAGE;
    case OfflineFailure:
      return OFFLINE_FAILURE_MESSAGE;
    default:
      return DEFAULT_FAILURE_MESSAGE;
  }
}

void setToken({required String token}) {
  myToken = "Bearer $token";
}

void setUserId({required String id}) {
  myId = id;
}

void setUser({required LoginModel user}) {
  currentUserData = user;
}

String logoPath = "";

Future<String> getLogoPath() async {
  final Directory extDir = await getApplicationDocumentsDirectory();
  File file = File('${extDir.path}/logo.png');
  logoPath = file.path;
  return file.path;
}
