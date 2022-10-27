import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nice_shot/core/functions/functions.dart';
import 'package:nice_shot/core/util/boxes.dart';
import 'package:nice_shot/core/util/global_variables.dart';
import 'package:nice_shot/core/strings/messages.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/data/model/api/data_model.dart';
import 'package:nice_shot/data/model/api/pagination.dart';
import 'package:nice_shot/data/repositories/edited_video_repository.dart';
import '../../../../data/model/api/video_model.dart';
import '../../../../data/model/flag_model.dart';
import '../../../../data/model/video_model.dart' as video;
import '../../raw_videos/bloc/raw_video_bloc.dart';

part 'edited_video_event.dart';

part 'edited_video_state.dart';

class EditedVideoBloc extends Bloc<EditedVideoEvent, EditedVideoState> {
  final EditedVideosRepository videosRepository;
  final RawVideoBloc rawVideoBloc;
  StreamSubscription? _progressSubscription;
  StreamSubscription? _resultSubscription;

  EditedVideoBloc({
    required this.rawVideoBloc,
    required this.videosRepository,
  }) : super(const EditedVideoState()) {
    // on((event, emit){
    //   if(state.uploadingState == RequestState.loaded){
    //     add(UploadEvent());
    //   }
    // });
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
    _progressSubscription?.cancel();
    await videosRepository.editedVideoUploader.clearUploads();
    VideoModel video = event.video;
    String path = video.file!.path;
    final tags = event.tags;
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
          message: mapFailureToMessage(failure: failure),
        ));
      },
      (response) async {
        emit(state.copyWith(
          uploadingState: RequestState.loaded,
          message: response.statusCode != null
              ? UPLOAD_SUCCESS_MESSAGE
              : UPLOAD_ERROR_MESSAGE,
        ));
        _progressSubscription!.cancel();
        await videosRepository.editedVideoUploader.clearUploads();

        if (response.statusCode != null) {
          String id = response.response!
              .split(":")[11]
              .split(",")
              .first
              .replaceAll('"', "");
          if (event.isEditedVideo) {
            add(GetEditedVideosEvent(id: userId));
          } else {
            if (tags!.isNotEmpty) {
              rawVideoBloc.add(UploadFlagEvent(tags: tags, rawVideoId: id));
            }
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
    Boxes.videoBox.values.toList().forEach((element) {
      if (element.isUploaded != true) {
        final video = VideoModel(
          categoryId: "1",
          name: element.title ?? "No title",
          userId: userId,
          duration: "${element.videoDuration}",
          thumbnail: File(element.videoThumbnail!),
          file: File(element.path!),
        );
        add(UploadVideoEvent(
          video: video,
          tags: element.flags,
          isEditedVideo: false,
        ));
      } else {
        _resultSubscription?.cancel();
      }
    });
  }

  @override
  Future<void> close() {
    _progressSubscription!.cancel();
    _resultSubscription!.cancel();
    return super.close();
  }
}
