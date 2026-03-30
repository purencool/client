part of 'network_bloc.dart';

sealed class NetworkEvent extends Equatable {
  const NetworkEvent();

  @override
  List<Object?> get props => [];
}

class CheckConnectivityEvent extends NetworkEvent {
  const CheckConnectivityEvent();
}

class ReportLatencyEvent extends NetworkEvent {
  final Duration latency;
  const ReportLatencyEvent(this.latency);

  @override
  List<Object?> get props => [latency];
}
