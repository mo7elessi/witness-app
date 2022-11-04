part of 'edited_video_bloc.dart';

class EditedVideoState extends Equatable {
  final Data<VideoModel>? video;
  final Pagination? data;
  final RequestState? requestState;
  final RequestState? uploadingState;
  final String? message;
  final String? taskId;
  final String? path;
  final int? progressValue;
  final Box<localVideo.VideoModel>? box;

  const EditedVideoState({
    this.video,
    this.data,
    this.requestState,
    this.uploadingState,
    this.message,
    this.path,
    this.progressValue,
    this.taskId,
    this.box,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        video,
        requestState,
        message,
        data,
        path,
        progressValue,
        uploadingState,
        taskId,
        box,
      ];

  EditedVideoState copyWith({
    Data<VideoModel>? video,
    RequestState? requestState,
    String? message,
    Pagination? data,
    String? path,
    int? progressValue,
    RequestState? uploadingState,
    String? taskId,
    Box<localVideo.VideoModel>? box,
  }) {
    return EditedVideoState(
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
      video: video ?? this.video,
      data: data ?? this.data,
      path: path ?? this.path,
      progressValue: progressValue ?? this.progressValue,
      uploadingState: uploadingState ?? this.uploadingState,
      taskId: taskId ?? this.taskId,
      box: box ?? this.box,
    );
  }
}
