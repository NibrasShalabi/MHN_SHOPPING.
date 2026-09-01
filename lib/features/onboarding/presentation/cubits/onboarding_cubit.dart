import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/base_cubit_state.dart';
import '../../domain/usecases/get_onboarding_usecase.dart';

class OnboardingCubit extends Cubit<BaseCubitState> {
  final GetOnboardingUsecase getOnboardingUsecase;

  OnboardingCubit(this.getOnboardingUsecase) : super(const InitialState());

  // TODO: add methods
}
