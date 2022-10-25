part of 'ui_bloc.dart';

class UiState extends Equatable {
  final File? file;
  final bool isPassword;
  final IconData? icon;
  final File? profileImage;

  const UiState({
    this.file,
    this.isPassword = true,
    this.icon,
    this.profileImage,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        file,
        isPassword,
        icon,
        profileImage,
      ];

  UiState copyWith({
    File? file,
    File? profileImage,
    bool? isPassword,
    IconData? icon,
  }) {
    return UiState(
      file: file ?? this.file,
      isPassword: isPassword ?? this.isPassword,
      icon: icon ?? this.icon,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
