import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/widgets/base_cubit_state.dart';
import '../../domain/usecases/get_about_usecase.dart';

class AboutCubit extends SafeCubit<BaseCubitState> {
  final GetAboutUsecase getAboutUsecase;

  AboutCubit(this.getAboutUsecase) : super(const InitialState());

  // TODO: add methods
}
