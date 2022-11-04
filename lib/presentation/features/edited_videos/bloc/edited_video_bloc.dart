import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nice_shot/core/functions/functions.dart';
import 'package:nice_shot/core/util/boxes.dart';
import 'package:nice_shot/core/util/global_variables.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/data/model/api/data_model.dart';
import 'package:nice_shot/data/model/api/pagination.dart';
import 'package:nice_shot/data/repositories/edited_video_repository.dart';
import 'package:nice_shot/presentation/features/main_layout/bloc/main_layout_bloc.dart';
import '../../../../data/model/api/video_model.dart';
import '../../../../data/model/video_model.dart' as localVideo;
import '../../../../data/model/flag_model.dart';
import '../../../../data/network/end_points.dart';
import '../../raw_videos/bloc/raw_video_bloc.dart';

part 'edited_video_event.dart';

part 'edited_video_state.dart';

class EditedVideoBloc extends Bloc<EditedVideoEvent, EditedVideoState> {
  final VideoRepositoryImpl videosRepository;
  final RawVideoBloc rawVideoBloc;
  final MainLayoutBloc mainBloc;
  StreamSubscription? _progressSubscription;
  StreamSubscription? _resultSubscription;

  EditedVideoBloc({
    required this.rawVideoBloc,
    required this.videosRepository,
    required this.mainBloc,
  }) : super(const EditedVideoState()) {
    on<UploadVideoEvent>(_uploadVideo);
    on<GetEditedVideosEvent>(_getEditedVideos);
    on<DeleteEditedVideoEvent>(_deleteEditedVideo);
    on<CancelUploadVideoEvent>(_cancelUploadVideo);
    on<UpdateVideoEvent>(_updateEditedVideo);
    on<UploadEvent>(_uploadEvent);
  }

  Future<void> _uploadVideo(
    UploadVideoEvent event,
    Emitter<EditedVideoState> emit,
  ) async {
    await _progressSubscription?.cancel();
    await videosRepository.videoUploader.clearUploads();

    final uploader = videosRepository.videoUploader;

    _progressSubscription = uploader.progress.listen((progress) {
      emit(state.copyWith(
        uploadingState: RequestState.loading,
        path: event.video.file!.path,
        taskId: progress.taskId,
        progressValue: progress.progress! >= 0 ? progress.progress : 0,
        box: event.box,
      ));
    });

    final upload = await videosRepository.uploadVideo(
      video: event.video,
      videoEndPoint: event.videoEndPoint,
    );
    upload.fold(
      (failure) async {
        emit(state.copyWith(
          uploadingState: RequestState.error,
          message: mapFailureToMessage(failure: failure),
        ));
        await _progressSubscription?.cancel();
      },
      (response) {
        emit(state.copyWith(uploadingState: RequestState.loaded));
        add(UploadEvent());
        if (event.isEditedVideo) {
          add(GetEditedVideosEvent());
        } else if (event.tags.isNotEmpty) {
          rawVideoBloc.add(
            UploadFlagEvent(
              tags: event.tags,
              rawVideoId: id(response: response.response!),
            ),
          );
        } else {
          rawVideoBloc.add(GetRawVideosEvent());
        }
      },
    );
  }

  String id({required String response}) {
    return response.split(":")[15].split(",").first.replaceAll('"', "");
  }

  Future<void> _cancelUploadVideo(
    CancelUploadVideoEvent event,
    Emitter<EditedVideoState> emit,
  ) async {
    emit(state.copyWith(uploadingState: RequestState.loading));
    final result = await videosRepository.cancelUploadVideo(id: event.taskId);
    result.fold(
      (failure) => emit(state.copyWith(
        uploadingState: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (canceled) async => {
        emit(state.copyWith(uploadingState: RequestState.none)),
        await _progressSubscription?.cancel(),
      },
    );
  }

  Future<void> _getEditedVideos(
    GetEditedVideosEvent event,
    Emitter<EditedVideoState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final data = await videosRepository.getVideos(
      videoEndPoint: Endpoints.editedVideos,
    );
    data.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (data) => emit(state.copyWith(
        requestState: RequestState.loaded,
        data: data,
      )),
    );
  }

  Future<void> _updateEditedVideo(
    UpdateVideoEvent event,
    Emitter<EditedVideoState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final data = await videosRepository.updateVideo(
      video: event.video,
      videoEndPoint: Endpoints.editedVideos,
    );
    data.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (data) {
        emit(state.copyWith(requestState: RequestState.loaded));
        add(GetEditedVideosEvent());
      },
    );
  }

  Future<void> _deleteEditedVideo(
    DeleteEditedVideoEvent event,
    Emitter<EditedVideoState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final data = await videosRepository.deleteVideo(
      id: event.id,
      videoEndPoint: Endpoints.editedVideos,
    );
    data.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (r) {
        emit(state.copyWith(requestState: RequestState.loaded));
        add(GetEditedVideosEvent());
      },
    );
  }

  Future<void> _uploadEvent(
    UploadEvent event,
    Emitter<EditedVideoState> emit,
  ) async {
    Box<localVideo.VideoModel>? box;
    String? videoEndPoint;
    if (mainBloc.isSync == true) {
      final rawVideos = Boxes.videoBox.values.where((element) {
        return element.isUploaded != true;
      });
      final editedVideos = Boxes.exportedVideoBox.values.where(
        (element) => element.isUploaded != true,
      );
      if (rawVideos.isNotEmpty) {
        box = Boxes.videoBox;
        videoEndPoint = Endpoints.rawVideos;
      } else if (editedVideos.isNotEmpty) {
        box = Boxes.exportedVideoBox;
        videoEndPoint = Endpoints.editedVideos;
      } else {
        box = Boxes.videoBox;
      }
      Iterable<localVideo.VideoModel> list =
          box == Boxes.videoBox ? rawVideos : editedVideos;

      if (list.isNotEmpty) {
        final element = list.toList().first;

        final video = VideoModel(
          categoryId: "1",
          name: element.title == null
              ? element.path!.split("/").last
              : element.path!.split("_").last,
          userId: userId,
          duration: "${element.videoDuration}",
          thumbnail: File(element.videoThumbnail!),
          file: File(element.path!),
        );
        add(UploadVideoEvent(
          video: video,
          tags: element.flags ?? [],
          isEditedVideo: box == Boxes.videoBox ? false : true,
          videoEndPoint: videoEndPoint!,
          box: box,
        ));
      }
    }
  }

  @override
  Future<void> close() async {
    await _progressSubscription?.cancel();
    return super.close();
  }
}
