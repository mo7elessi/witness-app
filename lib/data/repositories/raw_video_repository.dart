import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nice_shot/core/error/exceptions.dart';
import 'package:nice_shot/core/error/failure.dart';
import 'package:nice_shot/data/model/api/data_model.dart';
import 'package:nice_shot/data/model/api/video_model.dart';
import 'package:nice_shot/data/network/end_points.dart';
import 'package:nice_shot/data/network/remote/dio_helper.dart';
import 'package:flutter_uploader/flutter_uploader.dart';

import '../../core/network/network_info.dart';
import '../../core/util/global_variables.dart';
import '../model/api/pagination.dart';

typedef Generic = Either<Failure, UploadTaskResponse>;
typedef TagResponse = Either<Failure, Response>;

abstract class RawVideosRepository {
  Future<Generic> uploadVideo({required VideoModel video});

  Future<Either<Failure, Pagination>> getRawVideos({required String id});

  Future<Either<Failure, Data<VideoModel>>> getRawVideo({required String id});

  Future<MyResponse> deleteRawVideo({required String id});

  Future<MyResponse> cancelUploadVideo({required String id});

  Future<MyResponse> updateVideo({required VideoModel video});

  abstract FlutterUploader rawVideoUploader;
}

class RawVideosRepositoryImpl extends RawVideosRepository {
  final NetworkInfo networkInfo;

  RawVideosRepositoryImpl({required this.networkInfo});

  @override
  FlutterUploader rawVideoUploader = FlutterUploader();

  @override
  Future<Generic> uploadVideo({required VideoModel video}) async {
    Map<String, String> data = {
      "name": video.name!,
      "user_id": video.userId!,
      "category_id": video.categoryId!,
      "duration": video.duration!,
    };
    if (await networkInfo.isConnected) {
      try {
        DioHelper.dio!.options.headers = DioHelper.headers;
        await rawVideoUploader.enqueue(
          MultipartFormDataUpload(
            method: UploadMethod.POST,
            url: "${DioHelper.baseUrl}${Endpoints.rawVideos}",
            headers: DioHelper.headers,
            tag: "upload",
            data: data,
            files: [
              FileItem(path: video.file!.path, field: 'file'),
              FileItem(path: video.thumbnail!.path, field: 'thumbnail')
            ],
          ),
        );
        final response = await rawVideoUploader.result.firstWhere(
          (element) => element.statusCode == 201,
        );

        return Right(response);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Pagination>> getRawVideos({
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
  Future<MyResponse> deleteRawVideo({required String id}) async {
    return await _getMessage(() {
      return DioHelper.deleteData(
        url: "${Endpoints.rawVideos}/$id",
      );
    });
  }

  @override
  Future<MyResponse> cancelUploadVideo({required String id}) async {
    try {
      await rawVideoUploader.cancel(taskId: id);
      return const Right(unit);
    } on CancelUploadVideoException {
      return Left(CRUDVideoFailure());
    }
  }

  @override
  Future<MyResponse> updateVideo({
    required VideoModel video,
  }) async {
    return await _getMessage(() {
      return DioHelper.putData(
        url: "${Endpoints.rawVideos}/${video.id}",
        data: {
          "name": "${video.name}.mp4",
          "user_id": userId,
          "category_id": video.categoryId,
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
