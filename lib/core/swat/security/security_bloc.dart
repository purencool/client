import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../swat/swat_bloc.dart';
import '../swat/swat_event.dart'; // Ensure events are accessible

part 'security_event.dart';
part 'security_state.dart';

class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  final SwatBloc swatBloc;

  SecurityBloc({required this.swatBloc}) : super(SecuritySecure()) {
    on<SuspiciousActivityDetected>(_onSuspiciousActivity);
    on<AuthenticationThresholdExceeded>(_onAuthThresholdExceeded);
    on<SecurityResetRequested>(_onSecurityReset);
  }

  void _onSuspiciousActivity(
    SuspiciousActivityDetected event, 
    Emitter<SecurityState> emit
  ) {
    emit(SecurityLockdownInitiated());

    // Report up to the SwatBloc Command Center
    swatBloc.add(LogIncidentEvent(
      description: "SECURITY ALERT: ${event.reason}"
    ));

    emit(SecurityCompromised(event.reason));
  }

  void _onAuthThresholdExceeded(
    AuthenticationThresholdExceeded event, 
    Emitter<SecurityState> emit
  ) {
    add(SuspiciousActivityDetected(
      reason: "Brute force threshold reached: ${event.attempts} attempts."
    ));
  }

  void _onSecurityReset(
    SecurityResetRequested event, 
    Emitter<SecurityState> emit
  ) {
    swatBloc.add(LogIncidentEvent(description: "Security manually reset."));
    emit(SecuritySecure());
  }
}
