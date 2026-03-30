part of 'network_bloc.dart';

sealed class NetworkState extends Equatable {
  const NetworkState();

  @override
  List<Object?> get props => [];
}

class NetworkOptimal extends NetworkState {
  const NetworkOptimal();
}

class NetworkDegraded extends NetworkState {
  final String reason;
  const NetworkDegraded(this.reason);

  @override
  List<Object?> get props => [reason];
}

class NetworkBlackout extends NetworkState {
  const NetworkBlackout();
}