import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:nice_shot/core/error/exceptions.dart';
import 'package:nice_shot/core/error/failure.dart';
import 'package:nice_shot/data/model/api/data_model.dart';
import 'package:nice_shot/data/model/api/video_model.dart';
import 'package:nice_shot/data/network/end_points.dart';
import 'package:nice_shot/data/network/remote/dio_helper.dart';
import '../../core/network/network_info.dart';

abstract class RawVideosRepository {
  Future<Either<Failure, Data<VideoModel>>> getRawVideo({required String id});
}

class RawVideosRepositoryImpl extends RawVideosRepository {
  final NetworkInfo networkInfo;

  RawVideosRepositoryImpl({required this.networkInfo});

  @override
  Future<Either<Failure, Data<VideoModel>>> getRawVideo(
      {required String id}) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await DioHelper.getData(
          url: "${Endpoints.rawVideos}/$id",
        );

        return Right(Data.fromJson(response.data));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }
}
