import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile.dart';

enum AccountStatus { loading, ready, error }

class AccountState extends Equatable {
  final AccountStatus status;
  final UserProfile profile;
  final bool busy;
  final Failure? failure;

  const AccountState({
    this.status = AccountStatus.loading,
    this.profile = const UserProfile(),
    this.busy = false,
    this.failure,
  });

  AccountState copyWith({AccountStatus? status, UserProfile? profile, bool? busy, Failure? failure}) => AccountState(
        status: status ?? this.status,
        profile: profile ?? this.profile,
        busy: busy ?? this.busy,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, profile, busy, failure];
}
