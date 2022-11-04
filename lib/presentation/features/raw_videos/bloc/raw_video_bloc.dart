import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nice_shot/core/functions/functions.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/data/model/api/data_model.dart';
import 'package:nice_shot/data/model/api/pagination.dart';
import 'package:nice_shot/data/model/api/tag_model.dart';
import 'package:nice_shot/data/network/end_points.dart';
import 'package:nice_shot/data/repositories/edited_video_repository.dart';
import 'package:nice_shot/data/repositories/raw_video_repository.dart';
import 'package:nice_shot/presentation/features/edited_videos/bloc/edited_video_bloc.dart';
import '../../../../data/model/api/video_model.dart';
import '../../../../data/model/flag_model.dart';
import '../../../../data/repositories/flag_repository.dart';

part 'raw_video_event.dart';

part 'raw_video_state.dart';

class RawVideoBloc extends Bloc<RawVideoEvent, RawVideoState> {
  final RawVideosRepositoryImpl videoRepository;
  final VideoRepositoryImpl videosRepository;
  final FlagRepositoryImpl flagRepository;
  StreamSubscription? _progressSubscription;

  RawVideoBloc({
    required this.videoRepository,
    required this.flagRepository,
    required this.videosRepository,
  }) : super(const RawVideoState()) {
    on<GetRawVideosEvent>(_getRawVideos);
    on<DeleteRawVideoEvent>(_deleteRawVideo);
    on<DeleteFlagEvent>(_deleteFlag);
    on<UploadFlagEvent>(_uploadFlagVideos);
    on<UpdateRawVideoEvent>(_updateRawVideo);
    on<UpdateFlagEvent>(_updateFlag);
    on<GetRawVideoEvent>(_getRawVideo);
  }

  Future<void> _getRawVideos(
    GetRawVideosEvent event,
    Emitter<RawVideoState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final data = await videosRepository.getVideos(
      videoEndPoint: Endpoints.rawVideos,
    );
    data.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (data) => emit(
        state.copyWith(requestState: RequestState.loaded, data: data),
      ),
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
      (failure) => emit(state.copyWith(
        flagRequest: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (data) {
        emit(state.copyWith(flagRequest: RequestState.loaded));
        add(GetRawVideosEvent());
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
  Future<void> _updateRawVideo(
    UpdateRawVideoEvent event,
    Emitter<RawVideoState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final data = await videosRepository.updateVideo(
      video: event.video,
      videoEndPoint: Endpoints.rawVideos,
    );
    data.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (data) {
        emit(state.copyWith(requestState: RequestState.loaded));
        add(GetRawVideosEvent());
      },
    );
  }

  Future<void> _getRawVideo(
    GetRawVideoEvent event,
    Emitter<RawVideoState> emit,
  ) async {
    emit(state.copyWith(flagRequest: RequestState.loading));
    final data = await videoRepository.getRawVideo(id: event.id);
    data.fold(
      (failure) => emit(state.copyWith(
        flagRequest: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (data) => emit(
        state.copyWith(flagRequest: RequestState.loaded, video: data),
      ),
    );
  }

  Future<void> _deleteRawVideo(
    DeleteRawVideoEvent event,
    Emitter<RawVideoState> emit,
  ) async {
    emit(state.copyWith(requestState: RequestState.loading));
    final data = await videosRepository.deleteVideo(
      videoEndPoint: Endpoints.rawVideos,
      id: event.id,
    );

    data.fold(
      (failure) => emit(state.copyWith(
        requestState: RequestState.error,
        message: mapFailureToMessage(failure: failure),
      )),
      (r) {
        emit(state.copyWith(requestState: RequestState.loaded));
        add(GetRawVideosEvent());
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
    return super.close();
  }
}
