import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nice_shot/core/error/exceptions.dart';
import 'package:nice_shot/core/error/failure.dart';
import 'package:nice_shot/data/model/api/video_model.dart';
import 'package:nice_shot/data/network/end_points.dart';
import 'package:nice_shot/data/network/remote/dio_helper.dart';
import 'package:flutter_uploader/flutter_uploader.dart';

import '../model/api/data_model.dart';
import '../model/api/pagination.dart';
import '../model/api/tag_model.dart';
import '../model/flag_model.dart';

typedef Generic = Either<Failure, UploadTaskResponse>;
typedef TagResponse = Either<Failure, Data<TagModel>>;

abstract class RawVideosRepository {
  Future<Generic> uploadVideo({required VideoModel video});

  Future<TagResponse> uploadFlag({
    required List<FlagModel> tag,
    required String rawVideoId,
  });

  Future<Either<Failure, Pagination>> getRawVideos({required String id});

  Future<Either<Failure, int>> deleteRawVideo({required String id});

  Future<Either<Failure, int>> deleteFlag({required String id});

  Future<Either<Failure, Unit>> cancelUploadVideo({required String id});

  abstract FlutterUploader rawVideoUploader;
}

class RawVideosRepositoryImpl extends RawVideosRepository {
  @override
  FlutterUploader rawVideoUploader = FlutterUploader();

  @override
  Future<Generic> uploadVideo({required VideoModel video}) async {
    Map<String, String> data = {
      "name": video.name!,
      "user_id": video.userId!,
      "category_id": video.categoryId!,
    };
    try {
      DioHelper.dio!.options.headers = DioHelper.headers;
      await rawVideoUploader.enqueue(
        MultipartFormDataUpload(
          method: UploadMethod.POST,
          url: "${DioHelper.baseUrl}${Endpoints.rawVideos}",
          headers: DioHelper.headers,
          tag: "upload",
          data: data,
          files: [FileItem(path: video.file!.path, field: 'file')],
        ),
      );
      final response = await rawVideoUploader.result.firstWhere(
            (element) => element.statusCode == 201,
      );

      return Right(response);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
  @override
  Future<Either<Failure, Pagination>> getRawVideos({
    required String id,
  }) async {
    try {
      final response = await DioHelper.getData(
        url: "${Endpoints.rawVideos}/?user_id=$id",
      );
      return Right(Pagination.fromJson(response.data));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, int>> deleteRawVideo({required String id}) async {
    try {
      final response = await DioHelper.deleteData(
        url: "${Endpoints.rawVideos}/$id",
      );
      print("my result ${response.statusCode}");
      return Right(response.statusCode!);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<TagResponse> uploadFlag({
    required List<FlagModel> tag,
    required String rawVideoId,
  }) async {
    Response? response;
    try {
      for (FlagModel element in tag) {
        response = await DioHelper.postData(url: Endpoints.tags, data: {
          "tag": element.title ?? "No title",
          "raw_video_id": rawVideoId,
          "start_at": element.startDuration.toString(),
          "end_at": element.endDuration.toString(),
        });
      }
      return Right(Data<TagModel>.fromJson(response!.data));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelUploadVideo({required String id}) async {
    try {
      await rawVideoUploader.cancel(taskId: id);
      return const Right(unit);
    } on CancelUploadVideoException {
      return Left(CRUDVideoFailure());
    }
  }

  @override
  Future<Either<Failure, int>> deleteFlag({required String id}) async {
    try {
      final response = await DioHelper.deleteData(
        url: "${Endpoints.tags}/$id",
      );
      return Right(response.statusCode!);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
