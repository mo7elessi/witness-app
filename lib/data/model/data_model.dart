import 'package:hive_flutter/adapters.dart';
class DataModel {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? title;
  @HiveField(2)
  String? path;
  @HiveField(3)
  String? videoDuration;

  DataModel({
    this.id,
    this.title,
    this.path,
    this.videoDuration,
  });
}
