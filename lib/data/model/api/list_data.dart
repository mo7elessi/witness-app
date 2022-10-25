import 'package:nice_shot/data/model/api/User_model.dart';

class ListData {
  ListData({
      this.data,});

  ListData.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(UserModel.fromJson(v));
      });
    }
  }
  List<UserModel>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}
