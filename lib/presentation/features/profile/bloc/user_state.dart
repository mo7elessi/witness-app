part of 'user_bloc.dart';

class UserState extends Equatable {
  final Data<UserModel>? user;
  final RequestState? requestState;
  final RequestState? updateDataState;
  final RequestState? resetPasswordState;
  final RequestState? updateImageState;
  final String? message;
  final File? file;
  const UserState({
    this.updateDataState,
    this.resetPasswordState,
    this.updateImageState,
    this.user,
    this.requestState,
    this.message,
    this.file,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        user,
        requestState,
        message,
        updateDataState,
        resetPasswordState,
    updateImageState,
    file,
      ];

  UserState copyWith({
    Data<UserModel>? user,
    RequestState? requestState,
    RequestState? updateDataState,
    RequestState? resetPasswordState,
    RequestState? updateImageState,
    String? message,
    File? file,
  }) {
    return UserState(
      requestState: requestState ?? this.requestState,
      message: message ?? this.message,
      user: user ?? this.user,
      resetPasswordState: resetPasswordState ?? this.resetPasswordState,
      updateDataState: updateDataState ?? this.updateDataState,
      updateImageState: updateImageState ?? this.updateImageState,
      file: file ?? this.file,
    );
  }
}
