import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nice_shot/core/error/exceptions.dart';
import 'package:nice_shot/core/error/failure.dart';
import 'package:nice_shot/data/network/end_points.dart';
import 'package:nice_shot/data/network/remote/dio_helper.dart';
import '../../core/network/network_info.dart';
import '../../core/util/global_variables.dart';
import '../model/api/pagination.dart';
import '../model/api/tag_model.dart';
import '../model/flag_model.dart';

typedef TagResponse = Either<Failure, Response>;

abstract class FlagRepository {
  Future<MyResponse> postFlag({
    required List<FlagModel> tags,
    required String videoId,
  });

  Future<Either<Failure, Pagination>> getFlag({required String id});

  Future<MyResponse> deleteFlag({required String id});

  Future<MyResponse> updateFlag({required TagModel tag});
}

class FlagRepositoryImpl extends FlagRepository {
  final NetworkInfo networkInfo;

  FlagRepositoryImpl({required this.networkInfo});

  @override
  Future<Either<Failure, Pagination>> getFlag({
    required String id,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await DioHelper.getData(
          url: "${Endpoints.rawVideos}/?user_id=$id",
        );

        return Right(Pagination.fromJson(response.data));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<MyResponse> postFlag({
    required List<FlagModel> tags,
    required String videoId,
  }) async {
    List<Map<String, dynamic>> list = [];
    for (var element in tags) {
      Map<String, dynamic> data = {
        "tag": element.title ?? "No title",
        "raw_video_id": videoId,
        "start_at": element.startDuration.toString(),
        "end_at": element.endDuration.toString(),
      };
      list.add(data);
    }
    return await _getMessage(() {
      return DioHelper.postData(url: Endpoints.tags, data: {"tags": list});
    });
  }

  @override
  Future<MyResponse> deleteFlag({required String id}) async {
    return await _getMessage(() {
      return DioHelper.deleteData(url: "${Endpoints.tags}/$id");
    });
  }

  @override
  Future<MyResponse> updateFlag({required TagModel tag}) async {
    return await _getMessage(() {
      return DioHelper.putData(
        url: "${Endpoints.tags}/${tag.id}",
        data: {
          "tag": tag.tag,
          "raw_video_id": tag.rawVideoId,
        },
      );
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
