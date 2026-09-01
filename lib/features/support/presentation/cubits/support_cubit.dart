import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/support_repository.dart';
import '../../domain/entities/support_message.dart';
import 'support_state.dart';

class SupportCubit extends Cubit<SupportState> {
  final SupportRepository _repository;

  SupportCubit(this._repository) : super(const SupportState());

  void selectTopic(SupportTopic topic) => emit(state.copyWith(topic: topic));

  void updateBody(String body) =>
      emit(state.copyWith(body: body, clearBodyError: true));

  Future<void> send() async {
    if (state.body.trim().isEmpty) {
      emit(state.copyWith(bodyError: AppStrings.fieldRequired));
      return;
    }

    emit(state.copyWith(status: SupportStatus.submitting, failure: null));
    try {
      await _repository.sendMessage(
        SupportMessage(topic: state.topic, body: state.body.trim()),
      );
      emit(state.copyWith(status: SupportStatus.sent));
    } catch (e) {
      emit(state.copyWith(
        status: SupportStatus.failure,
        failure: mapExceptionToFailure(e),
      ));
    }
  }
}