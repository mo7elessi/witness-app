part of 'trimmer_bloc.dart';

@immutable
abstract class TrimmerState {}

class TrimmerInitial extends TrimmerState {}

class InitTrimmerState extends TrimmerState {
  final Trimmer trimmer;

  InitTrimmerState({required this.trimmer});
}

class ExportVideoLoadingState extends TrimmerState{}

class ExportVideoSuccessState extends TrimmerState{}

class ExportVideoErrorState extends TrimmerState{
  final String error;

  ExportVideoErrorState({required this.error});
}
