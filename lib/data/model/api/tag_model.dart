class TagModel {
  String? tag;
  String? rawVideoId;
  String? startAt;
  String? endAt;
  String? updatedAt;
  String? createdAt;
  int? id;
  TagModel({
    this.tag,
    this.rawVideoId,
    this.startAt,
    this.endAt,
    this.updatedAt,
    this.createdAt,
    this.id,
  });
  TagModel.fromJson(dynamic json) {
    tag = json['tag'];
    rawVideoId = json['raw_video_id'];
    startAt = json['start_at'];
    endAt = json['end_at'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }



  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['tag'] = tag;
    map['raw_video_id'] = rawVideoId;
    map['start_at'] = startAt;
    map['end_at'] = endAt;
    map['updated_at'] = updatedAt;
    map['created_at'] = createdAt;
    map['id'] = id;
    return map;
  }
}
