part of 'main_layout_bloc.dart';

@immutable
abstract class MainLayoutState extends Equatable{}

class MainLayoutInitial extends MainLayoutState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
class ChangeScaffoldBodyState extends MainLayoutState {
  final int currentIndex;

  ChangeScaffoldBodyState(this.currentIndex);
  @override
  // TODO: implement props
  List<Object?> get props => [currentIndex];
}
