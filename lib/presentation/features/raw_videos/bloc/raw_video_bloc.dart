import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nice_shot/core/functions/functions.dart';
import 'package:nice_shot/core/util/global_variables.dart';
import 'package:nice_shot/core/strings/messages.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/data/model/api/data_model.dart';
import 'package:nice_shot/data/model/api/pagination.dart';
import 'package:nice_shot/data/model/api/tag_model.dart';
import 'package:nice_shot/data/repositories/raw_video_repository.dart';
import '../../../../data/model/api/video_model.dart';
import '../../../../data/model/flag_model.dart';
import '../../../../data/repositories/flag_repository.dart';

part 'raw_video_event.dart';

part 'raw_video_state.dart';

class RawVideoBloc extends Bloc<RawVideoEvent, RawVideoState> {
  final RawVideosRepository videosRepository;
  final FlagRepository flagRepository;
  StreamSubscription? _progressSubscription;
  StreamSubscription? _resultSubscription;

  RawVideoBloc({
    required this.videosRepository,
    required this.flagRepository,
  }) : super(const RawVideoState()) {
    on<RawVideoEvent>((event, emit) {});
    on<UploadRawVideoEvent>(_uploadVideo);
    on<GetRawVideosEvent>(_getRawVideos);
    on<DeleteRawVideoEvent>(_deleteRawVideo);
    on<DeleteFlagEvent>(_deleteFlag);
    on<CancelUploadRawVideoEvent>(_cancelUploadVideo);
    on<UploadFlagEvent>(_uploadFlagVideos);
    on<UpdateRawVideoEvent>(_updateRawVideo);
    on<UpdateFlagEvent>(_updateFlag);
    on<GetRawVideoEvent>(_getRawVideo);
  }

  Future<void> _uploadVideo(
    UploadRawVideoEvent event,
    Emitter<RawVideoState> emit,
  ) async {
    await videosRepository.rawVideoUploader.clearUploads();
    _progressSubscription =
        videosRepository.rawVideoUploader.progress.listen((progress) {
      emit(state.copyWith(
        uploadingState: RequestState.loading,
        index: event.index,
        taskId: progress.taskId,
        progressValue: progress.progress! >= 0 ? progress.progress : 0,
      ));
    });
    final upload = await videosRepository.uploadVideo(video: event.video);
    upload.fold((failure) {
      emit(state.copyWith(
        uploadingState: RequestState.error,
        index: event.index,
        message: mapFailureToMessage(failure: failure),
      ));
    }, (response) {
      emit(state.copyWith(
        uploadingState: RequestState.loaded,
        index: event.index,
        message: response.statusCode != null
            ? UPLOAD_SUCCESS_MESSAGE
            : UPLOAD_ERROR_MESSAGE,
      ));
      if (event.tags.isNotEmpty) {
        if (response.statusCode != null) {
          String id = response.response!
              .split(":")[11]
              .split(",")
              .first
              .replaceAll('"', "");
          add(UploadFlagEvent(tags: event.tags, rawVideoId: id));
        }
      }
    });
  }

  Future<void> _getRawVideos(
    GetRawVideosEvent event,
    Emitter<RawVideoState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final data = await videosRepository.getRawVideos(id: event.id);
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

  Future<void> _uploadFlagVideos(
    UploadFlagEvent event,
    Emitter<RawVideoState> emit,
  ) async {
    emit(state.copyWith(flagRequest: RequestState.loading));
    final data = await flagRepository.postFlag(
      tags: event.tags,
      videoId: event.rawVideoId,
    );
    data.fold(
      (failure) => emit(
        state.copyWith(
          flagRequest: RequestState.error,
          message: mapFailureToMessage(failure: failure),
        ),
      ),
      (data) {
        emit(
          state.copyWith(flagRequest: RequestState.loaded),
        );
        add(GetRawVideosEvent(id: userId));
      },
    );
  }

  Future<void> _updateFlag(
    UpdateFlagEvent event,
    Emitter<RawVideoState> emit,
  ) async {
    emit(state.copyWith(flagRequest: RequestState.loading));
    final data = await flagRepository.updateFlag(tag: event.tag);
    data.fold(
      (failure) => emit(state.copyWith(
        flagRequest: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (data) {
        emit(state.copyWith(flagRequest: RequestState.loaded));
        add(GetRawVideoEvent(id: event.rawVideoId));
      },
    );
  }

  Future<void> _cancelUploadVideo(
    CancelUploadRawVideoEvent event,
    Emitter<RawVideoState> emit,
  ) async {
    emit(state.copyWith(uploadingState: RequestState.loading));
    final data = await videosRepository.cancelUploadVideo(
      id: event.taskId,
    );
    data.fold(
      (failure) => emit(
        state.copyWith(
          uploadingState: RequestState.error,
          message: mapFailureToMessage(failure: failure),
        ),
      ),
      (r) => emit(state.copyWith(uploadingState: RequestState.error)),
    );
  }

  Future<void> _updateRawVideo(
    UpdateRawVideoEvent event,
    Emitter<RawVideoState> emit,
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
        add(GetRawVideosEvent(id: userId));
      },
    );
  }

  Future<void> _getRawVideo(
    GetRawVideoEvent event,
    Emitter<RawVideoState> emit,
  ) async {
    emit(state.copyWith(flagRequest: RequestState.loading));
    final data = await videosRepository.getRawVideo(id: event.id);
    data.fold(
      (failure) => emit(state.copyWith(
        flagRequest: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (data) => emit(
        state.copyWith(
          flagRequest: RequestState.loaded,
          video: data,
        ),
      ),
    );
  }

  Future<void> _deleteRawVideo(
    DeleteRawVideoEvent event,
    Emitter<RawVideoState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final data = await videosRepository.deleteRawVideo(id: event.id);

    data.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (r) {
        emit(state.copyWith(requestState: RequestState.loaded));
        add(GetRawVideosEvent(id: userId));
      },
    );
  }

  Future<void> _deleteFlag(
    DeleteFlagEvent event,
    Emitter<RawVideoState> emit,
  ) async {
    emit(state.copyWith(flagRequest: RequestState.loading));
    final data = await flagRepository.deleteFlag(id: event.id);
    data.fold(
      (failure) => emit(state.copyWith(
        flagRequest: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (r) {
        emit(state.copyWith(flagRequest: RequestState.loaded));
        add(GetRawVideoEvent(id: event.rawVideoId));
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
