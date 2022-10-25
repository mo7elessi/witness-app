part of 'edited_video_bloc.dart';

class EditedVideoState extends Equatable {
  final Data<VideoModel>? video;
  final Pagination? data;
  final RequestState? requestState;
  final RequestState? uploadingState;
  final String? message;
  final String? taskId;
  final int? index;
  final int? progressValue;

  const EditedVideoState({
    this.video,
    this.data,
    this.requestState,
    this.uploadingState,
    this.message,
    this.index,
    this.progressValue,
    this.taskId,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        video,
        requestState,
        message,
        data,
        index,
        progressValue,
        uploadingState,
        taskId,
      ];

  EditedVideoState copyWith({
    Data<VideoModel>? video,
    RequestState? requestState,
    String? message,
    Pagination? data,
    int? index,
    int? progressValue,
    RequestState? uploadingState,
    String? taskId,
  }) {
    return EditedVideoState(
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
      video: video ?? this.video,
      data: data ?? this.data,
      index: index ?? this.index,
      progressValue: progressValue ?? this.progressValue,
      uploadingState: uploadingState ?? this.uploadingState,
      taskId: taskId ?? this.taskId,
    );
  }
}
