part of 'network_bloc.dart';

@immutable
abstract class NetworkEvent {}

class InternetConnectionEvent extends NetworkEvent {
  final ConnectivityResult connectivityResult;

  InternetConnectionEvent({required this.connectivityResult});
}
