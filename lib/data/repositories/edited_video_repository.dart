import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:nice_shot/core/error/exceptions.dart';
import 'package:nice_shot/core/error/failure.dart';
import 'package:nice_shot/core/util/global_variables.dart';
import 'package:nice_shot/data/model/api/video_model.dart';
import 'package:nice_shot/data/network/remote/dio_helper.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import '../../core/network/network_info.dart';
import '../model/api/pagination.dart';

typedef Generic = Either<Failure, UploadTaskResponse>;

abstract class VideoRepository {
  Future<Generic> uploadVideo({
    required VideoModel video,
    required String videoEndPoint,
  });

  Future<Either<Failure, Pagination>> getVideos({
    required String videoEndPoint,
  });

  Future<MyResponse> deleteVideo({
    required String id,
    required String videoEndPoint,
  });

  Future<MyResponse> cancelUploadVideo({
    required String id,
  });

  Future<MyResponse> updateVideo({
    required VideoModel video,
    required String videoEndPoint,
  });

  abstract FlutterUploader videoUploader;
}

class VideoRepositoryImpl extends VideoRepository {
  final NetworkInfo networkInfo;
  StreamSubscription<UploadTaskResponse>? _subscription;

  VideoRepositoryImpl({required this.networkInfo});

  @override
  FlutterUploader videoUploader = FlutterUploader();

  @override
  Future<Generic> uploadVideo({
    required VideoModel video,
    required String videoEndPoint,
  }) async {
    Map<String, String> data = {
      "name": video.name!,
      "user_id": video.userId,
      "category_id": video.categoryId!,
      "duration": video.duration!,
    };
    if (await networkInfo.isConnected) {
      try {
        await videoUploader.enqueue(
          MultipartFormDataUpload(
            method: UploadMethod.POST,
            url: "${DioHelper.baseUrl}$videoEndPoint",
            headers: DioHelper.headers,
            tag: "upload",
            data: data,
            allowCellular: true,
            files: [
              FileItem(path: video.file!.path, field: 'file'),
              FileItem(path: "${video.thumbnail!.path}", field: 'thumbnail')
            ],
          ),
        );

        final response = await videoUploader.result.firstWhere(
          (element) => element.statusCode == 201,
        );

        if (response.statusCode == 201) {
          return Right(response);
        } else {
          return Left(ServerFailure());
        }
      } on Exception {
        return Left(ServerFailure());
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Pagination>> getVideos({
    required String videoEndPoint,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await DioHelper.getData(
          url: "$videoEndPoint/?user_id=$userId",
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
  Future<MyResponse> deleteVideo({
    required String id,
    required String videoEndPoint,
  }) async {
    return await _getMessage(() {
      return DioHelper.deleteData(
        url: "$videoEndPoint/$id",
      );
    });
  }

  @override
  Future<MyResponse> cancelUploadVideo({
    required String id,
  }) async {
    try {
      await videoUploader.cancel(taskId: id);
      //await videoUploader.cancelAll();
      await _subscription?.cancel();
      return const Right(unit);
    } on CancelUploadVideoException {
      return Left(CRUDVideoFailure());
    }
  }

  @override
  Future<MyResponse> updateVideo({
    required VideoModel video,
    required String videoEndPoint,
  }) async {
    return await _getMessage(() {
      return DioHelper.putData(
        url: "$videoEndPoint/${video.id}",
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
}
