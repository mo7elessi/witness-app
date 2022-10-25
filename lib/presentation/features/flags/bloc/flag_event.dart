part of 'flag_bloc.dart';

@immutable
abstract class FlagEvent {}

class EditFlagEvent extends FlagEvent {
  final TextEditingController controller;

  EditFlagEvent({required this.controller});
}

class DeleteFlagEvent extends FlagEvent {}

class LikeFlagEvent extends FlagEvent {}

class DislikeFlagEvent extends FlagEvent {}
