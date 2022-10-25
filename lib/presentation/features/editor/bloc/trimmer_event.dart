part of 'trimmer_bloc.dart';

@immutable
abstract class TrimmerEvent extends Equatable{}

class InitTrimmerEvent extends TrimmerEvent {
  final File file;

  InitTrimmerEvent({required this.file});

  @override
  // TODO: implement props
  List<Object?> get props => [file];
}

class ChangeStartPointEvent extends TrimmerEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];

}

class ChangeEndPointEvent extends TrimmerEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class ExportVideoEvent extends TrimmerEvent {
  final FlagModel flagModel;
  ExportVideoEvent({required this.flagModel});
  @override
  // TODO: implement props
  List<Object?> get props => [flagModel];
}

class PauseVideoPlayerEvent extends TrimmerEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class ResumeVideoPlayerEvent extends TrimmerEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
