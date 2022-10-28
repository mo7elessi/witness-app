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
  BlocProvider<RawVideoBloc>(
    create: (_) => di.sl<RawVideoBloc>(),
  ),
  BlocProvider<NetworkBloc>(
    create: (_) => di.sl<NetworkBloc>(),
  ),
  BlocProvider<AuthBloc>(
    create: (_) => di.sl<AuthBloc>(),
  ),
  BlocProvider<CameraBloc>(
    create: (_) => di.sl<CameraBloc>()..add(InitCameraEvent()),
  ),
  BlocProvider<TrimmerBloc>(
    create: (_) => di.sl<TrimmerBloc>(),
  ),
  BlocProvider<EditedVideoBloc>(
    create: (_) => di.sl<EditedVideoBloc>(),
  ),
  BlocProvider<UserBloc>(
    create: (_) => di.sl<UserBloc>(),
  ),
  BlocProvider<MainLayoutBloc>(
    create: (_) => di.sl<MainLayoutBloc>()..add(GetSyncStateEvent()),
  ),
  BlocProvider<UiBloc>(
    create: (_) => di.sl<UiBloc>(),
  ),
];

// List<BlocProvider> providers = [
//   BlocProvider<NetworkBloc>(create: (_) => NetworkBloc()),
//   BlocProvider<AuthBloc>(
//     create: (_) => AuthBloc(
//       userRepository: UserRepositoryImpl(
//         networkInfo: NetworkInfoImpl(
//           connectionChecker: InternetConnectionChecker(),
//         ),
//       ),
//       networkBloc: NetworkBloc(),
//     ),
//   ),
//   BlocProvider<CameraBloc>(
//     create: (_) => CameraBloc()..add(InitCameraEvent()),
//   ),
//   BlocProvider<TrimmerBloc>(
//     create: (_) => TrimmerBloc(),
//   ),
//   BlocProvider<EditedVideoBloc>(
//     create: (_) => EditedVideoBloc(
//         videosRepository: VideosRepositoryImpl(
//           networkInfo: NetworkInfoImpl(
//             connectionChecker: InternetConnectionChecker(),
//           ),
//         ),
//         rawVideoBloc: RawVideoBloc(
//           videosRepository: RawVideosRepositoryImpl(
//             networkInfo: NetworkInfoImpl(
//               connectionChecker: InternetConnectionChecker(),
//             ),
//           ),
//           flagRepository: FlagRepositoryImpl(
//             networkInfo: NetworkInfoImpl(
//               connectionChecker: InternetConnectionChecker(),
//             ),
//           ),
//         ),
//         mainBloc: MainLayoutBloc()),
//   ),
//   BlocProvider<RawVideoBloc>(
//     create: (_) => RawVideoBloc(
//       videosRepository: RawVideosRepositoryImpl(
//         networkInfo: NetworkInfoImpl(
//           connectionChecker: InternetConnectionChecker(),
//         ),
//       ),
//       flagRepository: FlagRepositoryImpl(
//         networkInfo: NetworkInfoImpl(
//           connectionChecker: InternetConnectionChecker(),
//         ),
//       ),
//     ),
//   ),
//   BlocProvider<UserBloc>(
//     create: (_) => UserBloc(
//       userRepository: UserRepositoryImpl(
//         networkInfo: NetworkInfoImpl(
//           connectionChecker: InternetConnectionChecker(),
//         ),
//       ),
//       networkBloc: NetworkBloc(),
//     ),
//   ),
//   BlocProvider<MainLayoutBloc>(
//     create: (_) => MainLayoutBloc(
//         // videoBLoc: EditedVideoBloc(
//         //   videosRepository: VideosRepositoryImpl(
//         //     networkInfo: NetworkInfoImpl(
//         //       connectionChecker: InternetConnectionChecker(),
//         //     ),
//         //   ),
//         //   rawVideoBloc: RawVideoBloc(
//         //     videosRepository: RawVideosRepositoryImpl(
//         //       networkInfo: NetworkInfoImpl(
//         //         connectionChecker: InternetConnectionChecker(),
//         //       ),
//         //     ),
//         //     flagRepository: FlagRepositoryImpl(
//         //       networkInfo: NetworkInfoImpl(
//         //         connectionChecker: InternetConnectionChecker(),
//         //       ),
//         //     ),
//         //   ),
//         // ),
//         )
//       ..add(GetSyncStateEvent()),
//   ),
//   BlocProvider<UiBloc>(
//     create: (_) => UiBloc(),
//   ),
// ];
