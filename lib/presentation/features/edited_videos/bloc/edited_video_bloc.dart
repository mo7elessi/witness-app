import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nice_shot/core/functions/functions.dart';
import 'package:nice_shot/core/util/boxes.dart';
import 'package:nice_shot/core/util/global_variables.dart';
import 'package:nice_shot/core/strings/messages.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/data/model/api/data_model.dart';
import 'package:nice_shot/data/model/api/pagination.dart';
import 'package:nice_shot/data/repositories/edited_video_repository.dart';
import 'package:nice_shot/presentation/features/main_layout/bloc/main_layout_bloc.dart';
import '../../../../data/model/api/video_model.dart';
import '../../../../data/model/video_model.dart' as localVideo;
import '../../../../data/model/flag_model.dart';
import '../../raw_videos/bloc/raw_video_bloc.dart';

part 'edited_video_event.dart';

part 'edited_video_state.dart';

class EditedVideoBloc extends Bloc<EditedVideoEvent, EditedVideoState> {
  final VideosRepositoryImpl videosRepository;
  final RawVideoBloc rawVideoBloc;
  final MainLayoutBloc mainBloc;
  StreamSubscription? _progressSubscription;

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
    VideoModel video = event.video;
    String path = video.file!.path;
    final tags = event.tags;
    await _progressSubscription?.cancel();
    await videosRepository.editedVideoUploader.clearUploads();
    _progressSubscription =
        videosRepository.editedVideoUploader.progress.listen((progress) {
      emit(state.copyWith(
        uploadingState: RequestState.loading,
        path: path,
        taskId: progress.taskId,
        progressValue: progress.progress! >= 0 ? progress.progress : 0,
      ));
    });

    final upload = await videosRepository.uploadVideo(
      video: video,
      isEditedVideo: event.isEditedVideo,
    );
    upload.fold(
      (failure) {
        emit(state.copyWith(
          uploadingState: RequestState.error,
          box: event.box,
          message: mapFailureToMessage(failure: failure),
        ));
      },
      (response) async {
        emit(state.copyWith(
          uploadingState: RequestState.loaded,
          path: path,
          message: response.statusCode != null
              ? UPLOAD_SUCCESS_MESSAGE
              : UPLOAD_ERROR_MESSAGE,
        ));

        add(UploadEvent(context: event.context));
        if (response.statusCode == 201) {
          String id = response.response!
              .split(":")[11]
              .split(",")
              .first
              .replaceAll('"', "");
          if (event.isEditedVideo) {
            add(GetEditedVideosEvent(id: userId));
          } else if (tags!.isNotEmpty) {
            rawVideoBloc.add(
              UploadFlagEvent(
                tags: tags,
                rawVideoId: id,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _cancelUploadVideo(
    CancelUploadVideoEvent event,
    Emitter<EditedVideoState> emit,
  ) async {
    _progressSubscription!.cancel();
    emit(state.copyWith(uploadingState: RequestState.loading));

    final data = await videosRepository.cancelUploadVideo(
      id: event.taskId,
    );
    data.fold(
      (failure) => emit(state.copyWith(
        uploadingState: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (r) {
        emit(state.copyWith(uploadingState: RequestState.none));
      },
    );
  }

  Future<void> _getEditedVideos(
    GetEditedVideosEvent event,
    Emitter<EditedVideoState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final data = await videosRepository.getEditedVideos(id: event.id);
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
    final data = await videosRepository.updateVideo(video: event.video);
    data.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (data) {
        emit(state.copyWith(requestState: RequestState.loaded));
        add(GetEditedVideosEvent(id: userId));
      },
    );
  }

  Future<void> _deleteEditedVideo(
    DeleteEditedVideoEvent event,
    Emitter<EditedVideoState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final data = await videosRepository.deleteEditedVideo(id: event.id);

    data.fold(
      (failure) => emit(
        state.copyWith(
          requestState: RequestState.error,
          message: mapFailureToMessage(failure: failure),
        ),
      ),
      (r) {
        emit(state.copyWith(requestState: RequestState.loaded));
        add(GetEditedVideosEvent(id: userId));
      },
    );
  }

  Future<void> _uploadEvent(
    UploadEvent event,
    Emitter<EditedVideoState> emit,
  ) async {
    Box<localVideo.VideoModel>? box;
    if (mainBloc.isSync == true) {
      List<localVideo.VideoModel> rawVideos = Boxes.videoBox.values
          .toList()
          .where((element) => element.isUploaded != true)
          .toList();
      List<localVideo.VideoModel> editedVideos = Boxes.exportedVideoBox.values
          .toList()
          .where((element) => element.isUploaded != true)
          .toList();
      if (rawVideos.isNotEmpty) {
        box = Boxes.videoBox;
      } else if (editedVideos.isNotEmpty) {
        box = Boxes.exportedVideoBox;
      } else {
        box = Boxes.videoBox;
      }
      List list = box == Boxes.videoBox ? rawVideos : editedVideos;
      final element = list.toList();
      if (list.isNotEmpty) {
        final video = VideoModel(
          categoryId: "1",
          name: element.first.title == null
              ? element.first.path!.split("/").last
              : element.first.path!.split("_").last,
          userId: userId,
          duration: "${element.first.videoDuration}",
          thumbnail: File(element.first.videoThumbnail!),
          file: File(element.first.path!),
        );
        add(UploadVideoEvent(
          video: video,
          tags: element.first.flags,
          isEditedVideo: box == Boxes.videoBox ? false : true,
          context: event.context,
          box: box,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _progressSubscription!.cancel();
    return super.close();
  }
}
