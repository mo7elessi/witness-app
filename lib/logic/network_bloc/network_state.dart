part of 'network_bloc.dart';

@immutable
class NetworkState extends Equatable {
  final String? message;
  final InternetConnectionState? state;

  const NetworkState({this.message, this.state});

  @override
  // TODO: implement props
  List<Object?> get props => [message, state];

  NetworkState copyWith({String? message, InternetConnectionState? state}) {
    return NetworkState(
      message: message ?? this.message,
      state: state ?? this.state,
    );
  }
}
