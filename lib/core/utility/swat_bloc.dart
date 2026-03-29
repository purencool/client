import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

/// Events that trigger transitions in the SWAT Protocol.
sealed class SwatEvent {}

class ActivateSwatEvent extends SwatEvent {}

class LogIncidentEvent extends SwatEvent {
  final String description;
  LogIncidentEvent(this.description);
}

class DeescalateEvent extends SwatEvent {
  final List<String> identifiedDebt;
  DeescalateEvent(this.identifiedDebt);
}

/// Event to trigger opening the audited operational directories.
class OpenOperationalDirectoriesEvent extends SwatEvent {}

/// States representing the current organizational "Pulse".
sealed class SwatState {}

/// Standard 20/70/10 Pulse rhythm.
class NormalPulseState extends SwatState {}

/// High-intensity SWAT mode (100% Ops).
class SwatActiveState extends SwatState {
  final DateTime startTime;
  final List<String> logs;
  final int completedPoints;

  SwatActiveState({
    required this.startTime,
    this.logs = const [],
    this.completedPoints = 0,
  });

  /// Calculates Resolution Velocity (Rv) per Section 5 of the protocol.
  double get resolutionVelocity {
    final hours = DateTime.now().difference(startTime).inHours;
    if (hours == 0) return 0.0;
    return completedPoints / hours;
  }
}

/// Post-SWAT recovery and debt remediation phase.
class RecoveryState extends SwatState {
  final List<String> pendingTechnicalDebt;
  RecoveryState(this.pendingTechnicalDebt);
}

/// The BLoC that manages the Sovereign Intelligence SWAT Protocol.
class SwatBloc extends Bloc<SwatEvent, SwatState> {
  SwatBloc() : super(NormalPulseState()) {
    on<ActivateSwatEvent>((event, emit) {
      emit(SwatActiveState(startTime: DateTime.now()));
    });

    on<LogIncidentEvent>((event, emit) {
      if (state is SwatActiveState) {
        final current = state as SwatActiveState;
        emit(SwatActiveState(
          startTime: current.startTime,
          logs: List.from(current.logs)..add(event.description),
          completedPoints: current.completedPoints,
        ));
      }
    });

    on<DeescalateEvent>((event, emit) {
      emit(RecoveryState(event.identifiedDebt));
    });

    on<OpenOperationalDirectoriesEvent>((event, emit) async {
      // auditPath targets the entire application context
      final String auditPath = Directory.current.absolute.path;
      final Uri uri = Uri.file(auditPath);

      try {
        if (Platform.isLinux) {
          await Process.run('xdg-open', [auditPath]);
        } else if (Platform.isMacOS) {
          await Process.run('open', [auditPath]);
        } else if (Platform.isWindows) {
          // Windows handles paths better with backslashes for the explorer process
          await Process.run('explorer.exe', [auditPath.replaceAll('/', '\\')]);
        } else if (Platform.isAndroid || Platform.isIOS) {
          // Mobile platforms use url_launcher to trigger the system File browser
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            print("SWAT Alert: Could not launch system file browser for $auditPath");
          }
        } else {
          print("Audit triggered. Application Path: $auditPath");
        }
      } catch (e) {
        print("Error opening audit path: $e");
      }
    });
  }
}