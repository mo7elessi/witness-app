import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nice_shot/data/network/remote/retry_interceptor.dart';
import '../../../core/util/global_variables.dart';
import 'package:fresh_dio/fresh_dio.dart';

import 'dio_connectivity_request_retrier.dart';

class DioHelper {
  static String baseUrl = "http://91.232.125.244:8085";
  static String contentType = "application/json";
  static String? authorization = token;

  static Map<String, String> headers = {
    'Accept': contentType,
    'Content-Type': contentType,
    'Authorization': authorization ?? "",
  };
  static Dio? dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        // validateStatus: (status) => status!,
        //validateStatus: (status) => status! < 500,
        followRedirects: false,
      ),
    );
    if (kDebugMode) {
      dio!.interceptors.add(LogInterceptor(
          responseBody: true,
          error: true,
          requestHeader: true,
          responseHeader: true,
          request: true,
          requestBody: true));
    }

    dio!.interceptors.add(
      RetryOnConnectionChangeInterceptor(
        requestRetrier: DioConnectivityRequestRetrier(
          dio: dio!,
          connectivity: Connectivity(),
        ),
      ),
    );
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
  }) async {
    dio!.options.headers = headers;
    dio!.options.headers["Authorization"] = token;
    return await dio!.get(
      url,
      queryParameters: query,
    );
  }

  static Future<Response> postData({
    required String url,
    required dynamic data,
    Map<String, dynamic>? query,
  }) async {
    dio!.options.headers = headers;
    dio!.options.headers["Authorization"] = token;
    return await dio!.post(
      url,
      queryParameters: query,
      data: data,
    );
  }

  static Future<Response> putData({
    required String url,
    required dynamic data,
    Map<String, dynamic>? query,
  }) async {
    dio!.options.headers = headers;
    dio!.options.headers["Authorization"] = token;
    return await dio!.put(url, queryParameters: query, data: data);
  }

  static Future<Response> deleteData({
    required String url,
    Map<String, dynamic>? query,
  }) async {
    dio!.options.headers = headers;
    dio!.options.headers["Authorization"] = token;
    return await dio!.delete(url, queryParameters: query);
  }
}
