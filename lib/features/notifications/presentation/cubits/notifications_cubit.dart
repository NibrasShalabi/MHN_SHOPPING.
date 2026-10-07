import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/widgets/base_cubit_state.dart';
import '../../domain/usecases/get_notifications_usecase.dart';

class NotificationsCubit extends SafeCubit<BaseCubitState> {
  final GetNotificationsUsecase getNotificationsUsecase;

  NotificationsCubit(this.getNotificationsUsecase) : super(const InitialState());

  // TODO: add methods
}
