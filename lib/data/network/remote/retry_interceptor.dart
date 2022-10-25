import 'dart:io';

import 'package:dio/dio.dart';

import 'dio_connectivity_request_retrier.dart';

class RetryOnConnectionChangeInterceptor extends Interceptor {
  final DioConnectivityRequestRetrier requestRetrier;

  RetryOnConnectionChangeInterceptor({
    required this.requestRetrier,
  });

  @override
  Future onError(
      DioError err, ErrorInterceptorHandler interceptorHandler) async {
    if (_shouldRetry(err)) {
      try {
        return await requestRetrier.scheduleRequestRetry(err);
      } catch (e) {
        // Let any new error from the retrier pass through
        return e;
      }
    }
    // Let the error pass through if it's not the error we're looking for
    return err;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) =>
      handler.next(options);

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) =>
      handler.next(response);

  bool _shouldRetry(DioError err) {
    return err.type == DioErrorType.other &&
        err.error != null &&
        err.error is SocketException;
  }
}
