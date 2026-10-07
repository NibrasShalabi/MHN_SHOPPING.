import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base for every Cubit in the app.
///
/// GoRouter's ShellRoute disposes pages (and their cubits) mid-navigation,
/// so async work can finish after close(). Emitting then throws
/// "Cannot emit new states after calling close" — here it's dropped instead,
/// covering awaits, timers and work started inside close() alike.
abstract class SafeCubit<S> extends Cubit<S> {
  SafeCubit(super.initialState);

  @override
  void emit(S state) {
    if (isClosed) {
      debugPrint('[$runtimeType] emit after close ignored');
      return;
    }
    super.emit(state);
  }
}