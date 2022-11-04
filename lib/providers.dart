import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/logic/network_bloc/network_bloc.dart';
import 'package:nice_shot/logic/ui_bloc/ui_bloc.dart';
import 'package:nice_shot/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:nice_shot/presentation/features/camera/bloc/bloc.dart';
import 'package:nice_shot/presentation/features/edited_videos/bloc/edited_video_bloc.dart';
import 'package:nice_shot/presentation/features/editor/bloc/trimmer_bloc.dart';
import 'package:nice_shot/presentation/features/main_layout/bloc/main_layout_bloc.dart';
import 'package:nice_shot/presentation/features/profile/bloc/user_bloc.dart';
import 'package:nice_shot/presentation/features/raw_videos/bloc/raw_video_bloc.dart';
import 'injection_container.dart' as di;

List<BlocProvider> providers = [
  BlocProvider<MainLayoutBloc>(
    create: (_) => di.sl<MainLayoutBloc>()..add(GetSyncStateEvent()),
  ),
  BlocProvider<CameraBloc>(
      create: (_) => di.sl<CameraBloc>()..add(InitCameraEvent())),
  BlocProvider<RawVideoBloc>(create: (_) => di.sl<RawVideoBloc>()),
  BlocProvider<NetworkBloc>(create: (_) => di.sl<NetworkBloc>()),
  BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
  BlocProvider<TrimmerBloc>(create: (_) => di.sl<TrimmerBloc>()),
  BlocProvider<EditedVideoBloc>(create: (_) => di.sl<EditedVideoBloc>()),
  BlocProvider<UserBloc>(create: (_) => di.sl<UserBloc>()),
  BlocProvider<UiBloc>(create: (_) => di.sl<UiBloc>()),
];
