import 'package:nice_shot/data/model/api/User_model.dart';

class LoginModel {
  LoginModel({this.token, this.tokenType, this.user});

  LoginModel.fromJson(dynamic json) {
    token = json['token'];
    tokenType = json['token_type'];
    user = json['user'] != null ? UserModel.fromJson(json['user']) : null;
  }

  String? token;
  String? tokenType;
  UserModel? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = token;
    map['token_type'] = tokenType;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    return map;
  }
}
