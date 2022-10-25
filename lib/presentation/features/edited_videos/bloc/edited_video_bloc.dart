import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nice_shot/core/functions/functions.dart';
import 'package:nice_shot/core/util/global_variables.dart';
import 'package:nice_shot/core/strings/messages.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/data/model/api/data_model.dart';
import 'package:nice_shot/data/model/api/pagination.dart';
import 'package:nice_shot/data/repositories/edited_video_repository.dart';
import '../../../../data/model/api/video_model.dart';

part 'edited_video_event.dart';

part 'edited_video_state.dart';

class EditedVideoBloc extends Bloc<EditedVideoEvent, EditedVideoState> {
  final EditedVideosRepository videosRepository;
  StreamSubscription? _progressSubscription;
  StreamSubscription? _resultSubscription;

  EditedVideoBloc({
    required this.videosRepository,
  }) : super(const EditedVideoState()) {
    on<EditedVideoEvent>((event, emit) {});
    on<UploadVideoEvent>(_uploadVideo);
    on<GetEditedVideosEvent>(_getEditedVideos);
    on<DeleteEditedVideoEvent>(_deleteEditedVideo);
    on<CancelUploadVideoEvent>(_cancelUploadVideo);
  }

  Future<void> _uploadVideo(
    UploadVideoEvent event,
    Emitter<EditedVideoState> emit,
  ) async {
    await videosRepository.editedVideoUploader.clearUploads();
    _progressSubscription =
        videosRepository.editedVideoUploader.progress.listen((progress) {
      emit(state.copyWith(
        uploadingState: RequestState.loading,
        index: event.index,
        taskId: progress.taskId,
        progressValue: progress.progress! >= 0 ? progress.progress : 0,
      ));
    });
    final r = await videosRepository.uploadVideo(
      video: event.video
    );
    r.fold(
      (failure) {
        emit(state.copyWith(
          uploadingState: RequestState.error,
          index: event.index,
          message: mapFailureToMessage(failure: failure),
        ));
      },
      (response) {
        emit(state.copyWith(
          uploadingState: RequestState.loaded,
          index: event.index,
          message: response.statusCode != null
              ? UPLOAD_SUCCESS_MESSAGE
              : UPLOAD_ERROR_MESSAGE,
        ));
        if (response.statusCode != null) {
          add(GetEditedVideosEvent(id: userId!));
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

  Future<void> _cancelUploadVideo(
    CancelUploadVideoEvent event,
    Emitter<EditedVideoState> emit,
  ) async {
    emit(state.copyWith(uploadingState: RequestState.loading));
    final data = await videosRepository.cancelUploadVideo(
      id: event.taskId,
    );
    data.fold(
      (l) => emit(state.copyWith(
        uploadingState: RequestState.error,
        message: mapFailureToMessage(failure: l),
      )),
      (r) => emit(state.copyWith(uploadingState: RequestState.loaded)),
    );
  }

  Future<void> _deleteEditedVideo(
    DeleteEditedVideoEvent event,
    Emitter<EditedVideoState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final data = await videosRepository.deleteEditedVideo(id: event.id);

    data.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (code) {
        if (code == 200) {
          emit(state.copyWith(requestState: RequestState.loaded));
          add(GetEditedVideosEvent(id: userId!));
        } else {
          emit(state.copyWith(
            requestState: RequestState.error,
            message: DELETE_ERROR_MESSAGE,
          ));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _progressSubscription!.cancel();
    _resultSubscription!.cancel();
    return super.close();
  }
}
