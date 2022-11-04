part of 'ui_bloc.dart';

@immutable
abstract class UiEvent {}

class PickUserImageEvent extends UiEvent {}

class PickProfileImageEvent extends UiEvent {}

class ChangeIconSuffixEvent extends UiEvent {
  bool isPassword = true;

  ChangeIconSuffixEvent({required this.isPassword});
}
