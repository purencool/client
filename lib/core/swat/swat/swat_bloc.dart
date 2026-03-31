import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

// Imports for your state and event logic
import 'swat_state.dart';
import 'swat_event.dart';
import '../../../services/logging/logging.dart';
import '../../../services/io/resources_system.dart';

class SwatBloc extends Bloc<SwatEvent, SwatState> {
  final ILogging _logger;
  final ResourcesSystem _fileSystem;

  /// Single unified constructor using Dependency Injection.
  /// Standardizing on 'NormalPulseState' as the high-integrity initial state.
  SwatBloc({ILogging? logger, ResourcesSystem? fileSystem})
    : _logger = logger ?? Logging(),
      _fileSystem = fileSystem ?? ResourcesSystem(),
      super(NormalPulseState()) {
    // Activate the Protocol
    on<ActivateSwatEvent>((event, emit) {
      emit(SwatActiveState(startTime: DateTime.now()));
    });

    // Log Incidents (Technical log + UI Audit trail)
    on<LogIncidentEvent>((event, emit) {
      _logger.log(event.description, level: LogLevel.warning);

      if (state is SwatActiveState) {
        final current = state as SwatActiveState;
        emit(current.copyWith(logs: [...current.logs, event.description]));
      }
    });

    // Handle Directory Requests from UI
    on<OpenDirectoryRequested>((event, emit) async {
      _logger.log(
        "Manual directory request: ${event.path}",
        level: LogLevel.info,
      );
      await _fileSystem.openResources(event.path);
    });

    // 4. Handle Operational/Audit Directory opening
    on<OpenOperationalDirectoriesEvent>((event, emit) async {
      final String auditPath = Directory.current.absolute.path;
      _logger.log(
        "Opening operational audit directory: $auditPath",
        level: LogLevel.info,
      );

      // Using the injected instance instead of FileSystem.instance for consistency
      await _fileSystem.openResources(auditPath);
    });
  }
}
