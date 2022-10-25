import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nice_shot/core/functions/functions.dart';
import 'package:nice_shot/core/util/boxes.dart';
import 'package:nice_shot/core/util/global_variables.dart';
import 'package:nice_shot/core/strings/messages.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/data/model/api/data_model.dart';
import 'package:nice_shot/data/model/api/pagination.dart';
import 'package:nice_shot/data/repositories/edited_video_repository.dart';
import '../../../../data/model/api/video_model.dart';
import '../../../../data/model/video_model.dart' as video;

part 'edited_video_event.dart';

part 'edited_video_state.dart';

class EditedVideoBloc extends Bloc<EditedVideoEvent, EditedVideoState> {
  final EditedVideosRepository videosRepository;
  StreamSubscription? _progressSubscription;
  StreamSubscription? _resultSubscription;

  EditedVideoBloc({
    required this.videosRepository,
  }) : super(const EditedVideoState()) {
    on<UploadVideoEvent>(_uploadVideo);
    on<GetEditedVideosEvent>(_getEditedVideos);
    on<DeleteEditedVideoEvent>(_deleteEditedVideo);
    on<CancelUploadVideoEvent>(_cancelUploadVideo);
    on<UpdateVideoEvent>(_updateEditedVideo);
  }

  Future<void> _uploadVideo(
    UploadVideoEvent event,
    Emitter<EditedVideoState> emit,
  ) async {
    _progressSubscription?.cancel();
    await videosRepository.editedVideoUploader.clearUploads();
    _progressSubscription =
        videosRepository.editedVideoUploader.progress.listen((progress) async {
      emit(state.copyWith(
        uploadingState: RequestState.loading,
        index: event.index,
        taskId: progress.taskId,
        progressValue: progress.progress! >= 0 ? progress.progress : 0,
      ));
    });

    final upload = await videosRepository.uploadVideo(video: event.video);
    upload.fold(
      (failure) {
        emit(state.copyWith(
          uploadingState: RequestState.error,
          index: event.index,
          message: mapFailureToMessage(failure: failure),
        ));
      },
      (response) async {
        emit(state.copyWith(
          uploadingState: RequestState.loaded,
          index: event.index,
          message: response.statusCode != null
              ? UPLOAD_SUCCESS_MESSAGE
              : UPLOAD_ERROR_MESSAGE,
        ));
        _progressSubscription!.cancel();
        await videosRepository.editedVideoUploader.clearUploads();
        if (response.statusCode != null) {
          add(GetEditedVideosEvent(id: userId));
        }
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

  Future<void> _cancelUploadVideo(
    CancelUploadVideoEvent event,
    Emitter<EditedVideoState> emit,
  ) async {
    emit(state.copyWith(uploadingState: RequestState.loading));
    final data = await videosRepository.cancelUploadVideo(
      id: event.taskId,
    );
    data.fold(
      (failure) => emit(state.copyWith(
        uploadingState: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (r) => emit(state.copyWith(uploadingState: RequestState.error)),
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

  // List<video.VideoModel> videosToUpload = [];

  // Future<void> _checkNotUploadedVideos(
  //   CheckVideosEvent event,
  //   Emitter<EditedVideoState> emit,
  // ) async {
  //   videosToUpload = [];
  // }

  // Future<void> _uploadEvent(
  //   UploadEvent event,
  //   Emitter<EditedVideoState> emit,
  // ) async {
  //   Boxes.exportedVideoBox.values.toList().forEach((element) {
  //     if (element.isUploaded != true) {
  //       final video = VideoModel(
  //         categoryId: "1",
  //         name: element.title ?? "No title",
  //         userId: userId,
  //         duration: "${element.videoDuration}",
  //         thumbnail: File(element.videoThumbnail!),
  //         file: File(element.path!),
  //       );
  //       add(UploadVideoEvent(video: video));
  //     }
  //   });
  // }

  @override
  Future<void> close() {
    _progressSubscription!.cancel();
    _resultSubscription!.cancel();
    return super.close();
  }
}
