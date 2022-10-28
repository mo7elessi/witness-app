import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:nice_shot/core/network/network_info.dart';
import 'package:nice_shot/data/repositories/edited_video_repository.dart';
import 'package:nice_shot/data/repositories/flag_repository.dart';
import 'package:nice_shot/data/repositories/raw_video_repository.dart';
import 'package:nice_shot/data/repositories/user_repository.dart';
import 'package:nice_shot/logic/network_bloc/network_bloc.dart';
import 'package:nice_shot/logic/ui_bloc/ui_bloc.dart';
import 'package:nice_shot/presentation/features/auth/bloc/auth_bloc.dart';
import 'package:nice_shot/presentation/features/camera/bloc/bloc.dart';
import 'package:nice_shot/presentation/features/edited_videos/bloc/edited_video_bloc.dart';
import 'package:nice_shot/presentation/features/editor/bloc/trimmer_bloc.dart';
import 'package:nice_shot/presentation/features/flags/bloc/flag_bloc.dart';
import 'package:nice_shot/presentation/features/main_layout/bloc/main_layout_bloc.dart';
import 'package:nice_shot/presentation/features/profile/bloc/user_bloc.dart';
import 'package:nice_shot/presentation/features/raw_videos/bloc/raw_video_bloc.dart';

GetIt sl = GetIt.instance;

Future<void> init() async {

  sl.registerLazySingleton(() => CameraBloc());
  sl.registerLazySingleton(() => EditedVideoBloc(
        rawVideoBloc: sl(),
        videosRepository: sl(),
        mainBloc: sl(),
      ));
  sl.registerLazySingleton(() => RawVideoBloc(
        videosRepository: sl(),
        flagRepository: sl(),
      ));
  sl.registerLazySingleton(() => FlagBloc());

  sl.registerLazySingleton(() => NetworkBloc());
  sl.registerLazySingleton(() => UiBloc());
  sl.registerLazySingleton(() => MainLayoutBloc());
  sl.registerLazySingleton(() => TrimmerBloc());
  sl.registerLazySingleton(() => AuthBloc(userRepository: sl(), networkBloc: sl()));
  sl.registerLazySingleton(() => UserBloc(userRepository: sl(), networkBloc: sl()));

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectionChecker: sl.call()),
  );
  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton(() => VideosRepositoryImpl(networkInfo: sl()));
  sl.registerLazySingleton(() => RawVideosRepositoryImpl(networkInfo: sl()));
  sl.registerLazySingleton(() => FlagRepositoryImpl(networkInfo: sl()));
  sl.registerLazySingleton(() => NetworkInfoImpl(connectionChecker: sl()));
  sl.registerLazySingleton(() => UserRepositoryImpl(networkInfo: sl()));
}
