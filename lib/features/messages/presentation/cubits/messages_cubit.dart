import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/messages_repository.dart';
import 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final MessagesRepository _repo;

  MessagesCubit(this._repo) : super(const MessagesState());

  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(status: MessagesStatus.loading));
    try {
      final messages = await _repo.getMessages();
      if (isClosed) return;
      emit(state.copyWith(status: MessagesStatus.ready, messages: messages));
    } on ServerException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: MessagesStatus.failure, failure: ServerFailure(e.message)));
    }
  }

  Future<void> dismiss(String id) async {
    await _repo.dismissMessage(id);
    if (isClosed) return;
    emit(state.copyWith(
      messages: state.messages.where((m) => m.id != id).toList(),
    ));
  }
}