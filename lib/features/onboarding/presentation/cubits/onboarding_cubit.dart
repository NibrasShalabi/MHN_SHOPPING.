import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/widgets/base_cubit_state.dart';
import '../../domain/usecases/get_onboarding_usecase.dart';

class OnboardingCubit extends SafeCubit<BaseCubitState> {
  final GetOnboardingUsecase getOnboardingUsecase;

  OnboardingCubit(this.getOnboardingUsecase) : super(const InitialState());

  // TODO: add methods
}
