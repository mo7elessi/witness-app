
class UserModel {
  String? name;
  dynamic status;
  String? userName;
  String? email;
  String? mobile;
  String? birthDate;
  String? password;
  String? nationality;
  dynamic logo;
  String? updatedAt;
  String? createdAt;
  dynamic id;
  String? logoUrl;

  UserModel({
    this.name,
    this.status,
    this.userName,
    this.email,
    this.mobile,
    this.birthDate,
    this.nationality,
    this.logo,
    this.logoUrl,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.password,
  });

  UserModel.fromJson(dynamic json) {
    name = json['name'];
    status = json['status'];
    userName = json['user_name'];
    email = json['email'];
    mobile = json['mobile'];
    birthDate = json['birth_date'];
    nationality = json['nationality'];
    logo = json['logo'];
    logoUrl = json['logo_url'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['status'] = status;
    map['user_name'] = userName;
    map['email'] = email;
    map['mobile'] = mobile;
    map['birth_date'] = birthDate;
    map['nationality'] = nationality;
    map['logo'] = logo;
    map['updated_at'] = updatedAt;
    map['created_at'] = createdAt;
    map['id'] = id;
    map['password'] = password;
    map['logo_url'] = logoUrl;
    return map;
  }
}
