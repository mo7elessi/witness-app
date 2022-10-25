part of 'raw_video_bloc.dart';

abstract class RawVideoEvent {}

class GetRawVideosEvent extends RawVideoEvent {
  final String id;

  GetRawVideosEvent({required this.id});
}

class UploadRawVideoEvent extends RawVideoEvent {
  final VideoModel video;
  final List<FlagModel> tags;
  final int index;

  UploadRawVideoEvent({
    required this.video,
    required this.index,
    required this.tags,
  });
}

class DeleteRawVideoEvent extends RawVideoEvent {
  final String id;

  DeleteRawVideoEvent({required this.id});
}

class CancelUploadRawVideoEvent extends RawVideoEvent {
  final String taskId;

  CancelUploadRawVideoEvent({required this.taskId});
}

class UploadFlagEvent extends RawVideoEvent {
  final List<FlagModel> tags;
  final String rawVideoId;

  UploadFlagEvent({required this.tags,required this.rawVideoId});
}

class DeleteFlagEvent extends RawVideoEvent {
  final String id;

  DeleteFlagEvent({required this.id});
}
