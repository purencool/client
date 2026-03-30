part of 'security_bloc.dart';

sealed class SecurityState extends Equatable {
  const SecurityState();

  @override
  List<Object?> get props => [];
}

/// The default "All Clear" state
class SecuritySecure extends SecurityState {}

/// The transition state while the system is locking down
class SecurityLockdownInitiated extends SecurityState {
  final DateTime timestamp;
  SecurityLockdownInitiated() : timestamp = DateTime.now();

  @override
  List<Object?> get props => [timestamp];
}

/// Total system lockdown - requires manual intervention or reset
class SecurityCompromised extends SecurityState {
  final String breachReason;
  const SecurityCompromised(this.breachReason);

  @override
  List<Object?> get props => [breachReason];
}
