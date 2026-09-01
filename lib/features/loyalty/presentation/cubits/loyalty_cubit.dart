import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/base_cubit_state.dart';
import '../../domain/usecases/get_loyalty_usecase.dart';

class LoyaltyCubit extends Cubit<BaseCubitState> {
  final GetLoyaltyUsecase getLoyaltyUsecase;

  LoyaltyCubit(this.getLoyaltyUsecase) : super(const InitialState());

  // TODO: add methods
}
