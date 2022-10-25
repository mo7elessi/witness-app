import 'package:nice_shot/data/model/api/video_model.dart';

import 'Tag_model.dart';
import 'User_model.dart';

class Data<T> {
  T? data;

  Data({this.data});

  Data.fromJson(dynamic json) {
    data = json['data'] != null ? Generic.fromJson<T>(json['data']) : null;
  }
}

class Generic {
  static T fromJson<T>(dynamic json) {
    if (T == VideoModel) {
      return VideoModel.fromJson(json) as T;
    }  else if (T == UserModel) {
      return UserModel.fromJson(json) as T;
    }  else if (T == TagModel) {
      return TagModel.fromJson(json) as T;
    } else {
      throw Exception("Unknown class");
    }
  }
}
