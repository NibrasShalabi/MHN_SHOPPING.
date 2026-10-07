import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/messages_repository.dart';
import '../../domain/entities/admin_message.dart';
import 'messages_state.dart';

/// App-level: one instance feeds both the nav badge and the inbox page.
class MessagesCubit extends Cubit<MessagesState> {
  final MessagesRepository _repo;
  StreamSubscription<List<AdminMessage>>? _sub;

  MessagesCubit(this._repo) : super(const MessagesState());

  void watch() {
    _sub?.cancel();
    emit(state.copyWith(status: MessagesStatus.loading));
    _sub = _repo.watchInbox().listen(
      (messages) {
        if (isClosed) return;
        emit(state.copyWith(status: MessagesStatus.ready, messages: messages));
      },
      onError: (Object e) {
        if (isClosed) return;
        emit(state.copyWith(status: MessagesStatus.failure, failure: _failureOf(e)));
      },
    );
  }

  /// Optimistic: the tile is already gone (Dismissible), roll back on failure.
  Future<void> dismiss(AdminMessage message) async {
    final previous = state.messages;
    emit(state.copyWith(messages: previous.where((m) => m.id != message.id).toList()));
    try {
      await _repo.dismiss(message);
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(messages: previous, failure: _failureOf(e)));
    }
  }

  Failure _failureOf(Object e) =>
      e is ServerException && e.message.isNotEmpty ? ServerFailure(e.message) : const ServerFailure();

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
