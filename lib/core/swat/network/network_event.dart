/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

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
