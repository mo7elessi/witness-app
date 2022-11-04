import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/util/global_variables.dart';

class DioHelper {
  static String baseUrl = "http://91.232.125.244:8085";
  static String contentType = "application/json";
  static String authorization = token ?? "";

  static Map<String, String> headers = {
    'Accept': contentType,
    'Content-Type': contentType,
    'Authorization': authorization,
  };
  static Dio? dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        validateStatus: (status) => status! <= 500,
        followRedirects: true,
        receiveTimeout: 30 * 1000,
        connectTimeout: 10 * 1000,
      ),
    );
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
  }) async {
    dio!.options.headers = headers;
    dio!.options.headers["Authorization"] = token;
    final response = await dio!.get(
      url,
      queryParameters: query,
    );
    if (response.statusCode == 200) {
      return Future.value(response);
    } else {
      throw ServerException();
    }
  }

  static Future<Unit> postData({
    required String url,
    required dynamic data,
    Map<String, dynamic>? query,
  }) async {
    dio!.options.headers = headers;
    dio!.options.headers["Authorization"] = token;
    final response = await dio!.post(
      url,
      queryParameters: query,
      data: data,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Future.value(unit);
    } else {
      throw ServerException();
    }
  }

  static Future<Unit> putData({
    required String url,
    required dynamic data,
    Map<String, dynamic>? query,
  }) async {
    dio!.options.headers = headers;
    dio!.options.headers["Authorization"] = token;
    final response = await dio!.put(url, queryParameters: query, data: data);
    if (response.statusCode == 200) {
      return Future.value(unit);
    } else {
      throw ServerException();
    }
  }

  static Future<Unit> deleteData({
    required String url,
    Map<String, dynamic>? query,
  }) async {
    dio!.options.headers = headers;
    dio!.options.headers["Authorization"] = token;
    final response = await dio!.delete(url, queryParameters: query);
    if (response.statusCode == 200) {
      return Future.value(unit);
    } else {
      throw ServerException();
    }
  }
}
