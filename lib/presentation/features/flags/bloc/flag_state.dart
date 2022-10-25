part of 'flag_bloc.dart';

@immutable
abstract class FlagState {}

class FlagInitial extends FlagState {}

class EditedFlagState extends FlagState {}

class DeletedFlagState extends FlagState {}

class LikedFlagState extends FlagState {}

class DislikedFlagState extends FlagState {}
