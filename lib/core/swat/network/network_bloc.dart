/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'network_event.dart';
part 'network_state.dart';

class NetworkIntegrityBloc extends Bloc<NetworkEvent, NetworkState> {
  NetworkIntegrityBloc() : super(const NetworkOptimal()) {
    
    // Handler for latency reporting
    on<ReportLatencyEvent>((event, emit) {
      if (event.latency.inMilliseconds > 500) {
        emit(const NetworkDegraded("High Latency Detected"));
      } else {
        emit(const NetworkOptimal());
      }
    });

    // Handler for manual connectivity checks
    on<CheckConnectivityEvent>((event, emit) async {
      // Logic for checking actual internet reachability would go here
      // For now, we simply maintain the current state or trigger a refresh
    });
  }
}
