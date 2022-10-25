part of 'main_layout_bloc.dart';

@immutable
abstract class MainLayoutEvent {}

class ChangeScaffoldBodyEvent extends MainLayoutEvent{
  final int index;

  ChangeScaffoldBodyEvent(this.index);
}