import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApplicationBlocObserver extends BlocObserver {
  String tag = "bloc_observe";

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      print("my events: event: ${bloc}\nevent: $event");
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      print("my states: change: $bloc\nchange: $change");
    }
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (kDebugMode) {
      print("$tag $bloc");
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      print("$tag transaction: $bloc\ntransaction: $transition");
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (kDebugMode) {
      print("$tag error: $bloc\nerror: $error");
    }
  }
}
