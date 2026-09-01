/// Generic base state you can extend for any Cubit (unified loading/success/error pattern).
abstract class BaseCubitState {
  const BaseCubitState();
}

class InitialState extends BaseCubitState {
  const InitialState();
}

class LoadingState extends BaseCubitState {
  const LoadingState();
}

class ErrorState extends BaseCubitState {
  final String message;
  const ErrorState(this.message);
}
