import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/base_cubit_state.dart';
import '../../domain/usecases/get_checkout_usecase.dart';

class CheckoutCubit extends Cubit<BaseCubitState> {
  final GetCheckoutUsecase getCheckoutUsecase;

  CheckoutCubit(this.getCheckoutUsecase) : super(const InitialState());

  // TODO: add methods
}
