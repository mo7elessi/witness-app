import 'package:hive/hive.dart';
import 'package:nice_shot/data/model/data_model.dart';

import 'flag_model.dart';

part 'video_model.g.dart';
@HiveType(typeId: 0)
class VideoModel extends DataModel {
  @HiveField(4)
  DateTime? dateTime;
  @HiveField(5)
  List<FlagModel>? flags;
  @HiveField(6)
  String? videoThumbnail;
  @HiveField(7)
  bool? isUploaded;
  VideoModel({
    super.id,
    super.videoDuration,
    super.path,
    super.title,
    this.dateTime,
    this.flags,
    this.videoThumbnail,
    this.isUploaded,
  });
}
