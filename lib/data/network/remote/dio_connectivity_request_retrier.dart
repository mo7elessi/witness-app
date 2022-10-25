import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/data/repositories/user_repository.dart';
import 'package:nice_shot/presentation/features/profile/bloc/user_bloc.dart';

import '../../../core/util/global_variables.dart';
import '../../../logic/connected_bloc/network_bloc.dart';

class DioConnectivityRequestRetrier {
  final Connectivity connectivity;
  final Dio dio;

  const DioConnectivityRequestRetrier({
    required this.connectivity,
    required this.dio,
  });

  Future<Response> scheduleRequestRetry(DioError err) async {
    late StreamSubscription streamSubscription;
    final responseCompleter = Completer<Response>();
    streamSubscription = connectivity.onConnectivityChanged.listen(
      (connectivityResult) async {
        if (connectivityResult != ConnectivityResult.none) {
          streamSubscription.cancel();
          // Complete the completer instead of returning
          responseCompleter.complete(
            dio
                .request(
              err.requestOptions.path,
              cancelToken: err.requestOptions.cancelToken,
              data: err.requestOptions.data,
              onReceiveProgress: err.requestOptions.onReceiveProgress,
              onSendProgress: err.requestOptions.onSendProgress,
              queryParameters: err.requestOptions.queryParameters,
              options: Options(
                  method: err.requestOptions.method,
                  sendTimeout: err.requestOptions.sendTimeout,
                  receiveTimeout: err.requestOptions.receiveTimeout,
                  headers: err.requestOptions.headers,
                  responseType: err.requestOptions.responseType,
                  contentType: err.requestOptions.contentType),
            ),
          );
        }
      },
    );

    return responseCompleter.future;
  }
}
