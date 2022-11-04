import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nice_shot/core/error/failure.dart';
import 'package:nice_shot/core/util/global_variables.dart';
import 'package:nice_shot/data/model/api/User_model.dart';
import 'package:nice_shot/data/model/api/data_model.dart';
import 'package:nice_shot/data/model/api/login_model.dart';
import 'package:nice_shot/data/network/end_points.dart';
import 'package:nice_shot/data/network/local/cache_helper.dart';
import 'package:nice_shot/data/network/remote/dio_helper.dart';
import '../../core/error/exceptions.dart';
import 'package:http_parser/http_parser.dart';

import '../../core/network/network_info.dart';
import '../../core/strings/messages.dart';

abstract class UserRepository {
  Future<MyResponse> createUser({required UserModel userModel});

  Future<MyResponse> login({required String email, required String password});

  Future<Either<Failure, Data<UserModel>>> getUserData({required String id});

  Future<MyResponse> deleteAccount();

  Future<MyResponse> updateUserData({required UserModel userModel});

  Future<MyResponse> updateUserImage({required String path});

  Future<MyResponse> logout();

  Future<MyResponse> getCurrentUserData();

  Future<MyResponse> resetPassword({
    required String oldPassword,
    required String newPassword,
  });
}

class UserRepositoryImpl extends UserRepository {
  final NetworkInfo networkInfo;

  UserRepositoryImpl({required this.networkInfo});

  @override
  Future<MyResponse> createUser({required UserModel userModel}) async {
    final data = FormData.fromMap({
      'name': userModel.name,
      'user_name': userModel.userName,
      'email': userModel.email,
      'mobile': userModel.mobile,
      'birth_date': userModel.birthDate,
      'password': userModel.password,
      'file': await MultipartFile.fromFile(
        userModel.logo!.path,
        filename: "upload.jpg",
        contentType: MediaType("jpeg", "jpg"),
      ),
    });
    if (await networkInfo.isConnected) {
      DioHelper.dio!.options.headers = DioHelper.headers;
      final response =
          await DioHelper.dio!.post(Endpoints.user, data: data).timeout(
                const Duration(minutes: 1),
              );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(unit);
      } else if (response.statusCode == 422) {
        REGISTER_ERROR_MESSAGE = response.data['message'];
        return Left(RegisterFailure());
      }
      return Left(ServerFailure());
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<MyResponse> login({
    required String email,
    required String password,
  }) async {
    final data = FormData.fromMap({
      'email': email,
      'password': password,
    });
    if (await networkInfo.isConnected) {
      try {
        DioHelper.dio!.options.headers = DioHelper.headers;
        final response = await DioHelper.dio!.post(Endpoints.login, data: data);
        if (response.statusCode == 200) {
          final user = LoginResponse.fromJson(response.data);
          setUser(user: user);
          setToken(token: user.token!);
          setUserId(id: "${user.user!.id}");
          await CacheHelper.saveData(key: "user", value: json.encode(user));
          return const Right(unit);
        }
        return Left(LoginFailure());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Data<UserModel>>> getUserData({
    required String id,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await DioHelper.getData(url: "${Endpoints.user}/$id");
        return Right(Data.fromJson(response.data));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<MyResponse> updateUserData({required UserModel userModel}) async {
    Map<String, dynamic> data = {
      'name': userModel.name,
      'user_name': userModel.userName,
      'email': userModel.email,
      'mobile': userModel.mobile,
      'nationality': userModel.nationality,
      'birth_date': userModel.birthDate,
    };
    if (await networkInfo.isConnected) {
      try {
        DioHelper.dio!.options.headers = DioHelper.headers;
        DioHelper.dio!.options.headers["Authorization"] = token;
        final response =
            await DioHelper.dio!.put("${Endpoints.user}/$userId", data: data);
        if (response.statusCode == 200) {
          return const Right(unit);
        } else if (response.statusCode == 422) {
          REGISTER_ERROR_MESSAGE = response.data['message'];
          return Left(RegisterFailure());
        }
        return Left(ServerFailure());
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<MyResponse> resetPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await _getMessage(() {
      return DioHelper.postData(
        url: Endpoints.passwordReset,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
    });
  }

  @override
  Future<MyResponse> updateUserImage({required String path}) async {
    var data = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        path,
        filename: "upload.jpg",
        contentType: MediaType("jpeg", "jpg"),
      ),
    });
    return await _getMessage(() {
      return DioHelper.postData(
        url: Endpoints.userImage,
        data: data,
      );
    });
  }

  @override
  Future<MyResponse> logout() async {
    return await _getMessage(() {
      return DioHelper.postData(url: Endpoints.logout, data: {});
    });
  }

  @override
  Future<MyResponse> getCurrentUserData() async {
    return await _getMessage(() {
      return DioHelper.postData(url: Endpoints.me, data: {});
    });
  }

  @override
  Future<MyResponse> deleteAccount() async {
    return await _getMessage(() {
      return DioHelper.deleteData(url: "${Endpoints.user}/$userId");
    });
  }

  Future<Either<Failure, Unit>> _getMessage(CRUD crud) async {
    if (await networkInfo.isConnected) {
      try {
        await crud();
        return const Right(unit);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }
}
