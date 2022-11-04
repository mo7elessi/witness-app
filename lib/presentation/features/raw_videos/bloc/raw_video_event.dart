part of 'raw_video_bloc.dart';

abstract class RawVideoEvent {}

class GetRawVideosEvent extends RawVideoEvent {}

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
   List<FlagModel> tags = [];
  final String rawVideoId;

  UploadFlagEvent({required this.tags, required this.rawVideoId});
}

class UpdateFlagEvent extends RawVideoEvent {
  final TagModel tag;
  final String rawVideoId;

  UpdateFlagEvent({required this.tag,required this.rawVideoId});
}

class DeleteFlagEvent extends RawVideoEvent {
  final String id;
  final String rawVideoId;
  DeleteFlagEvent({required this.id,required this.rawVideoId});
}

class UpdateRawVideoEvent extends RawVideoEvent {
  final VideoModel video;

  UpdateRawVideoEvent({required this.video});
}
class SetFlagsEvent extends RawVideoEvent {
  final List<TagModel> tags;

  SetFlagsEvent({required this.tags});
}
class GetRawVideoEvent extends RawVideoEvent{
  final String id;
  GetRawVideoEvent({required this.id});
}