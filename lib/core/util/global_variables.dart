import 'package:dartz/dartz.dart';
import 'package:nice_shot/data/model/api/login_model.dart';

import '../error/failure.dart';

typedef MyResponse = Either<Failure, Unit>;

typedef CRUD = Future<Unit> Function();

bool permissionsGranted = false;

LoginResponse? get user => _loginResponse;

bool sync = false;

String? get token => _token;

String get userId => _id!;

LoginResponse? _loginResponse;

String? _token;

String? _id;

void setToken({required String token}) {
  _token = "Bearer $token";
}

void setUserId({required String id}) {
  _id = id;
}

void setUser({required LoginResponse user}) {
  _loginResponse = user;
}
