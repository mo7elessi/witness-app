import 'dart:io';

import 'tag_model.dart';


class VideoModel {
  String? name;
  String? url;
  String? videoUrl;
  dynamic userId;
  dynamic categoryId;
  File? file;
  dynamic thumbnail;
  String? updatedAt;
  String? createdAt;
  num? id;
  String? th;
  String? duration;
  String? thumbnailUrl;
  List<TagModel>? tags;
  VideoModel({
    this.name,
    this.url,
    this.videoUrl,
    this.userId,
    this.file,
    this.categoryId,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.duration,
    this.thumbnail,
    this.tags,
    this.thumbnailUrl,
  });

  VideoModel.fromJson(dynamic json) {
    name = json['name'];
    url = json['url'];
    videoUrl = json['video_url'];
    userId = json['user_id'];
    categoryId = json['category_id'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
    duration = json['duration'];
    file = json['file'];
    thumbnail = json['thumbnail'];
    thumbnailUrl = json['thumbnail_url'];
    if (json['tags'] != null) {
      tags = [];
      json['tags'].forEach((v) {
        tags?.add(TagModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['url'] = url;
    map['video_url'] = videoUrl;
    map['user_id'] = userId;
    map['category_id'] = categoryId;
    map['updated_at'] = updatedAt;
    map['created_at'] = createdAt;
    map['id'] = id;
    map['file'] = file;
    map['duration'] = duration;
    map['thumbnail'] = thumbnail;
    map['thumbnail_url'] = thumbnailUrl;

    return map;
  }
}
