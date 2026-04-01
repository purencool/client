import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

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
      // Resolve the path either from the event or the picker.
      final String? targetPath =
          event.path ?? await FilePicker.platform.getDirectoryPath();

      if (targetPath != null) {
        emit(SwatScanningInProgress());

        try {
          // Execute the scan
          final tree = await _fileSystem.scanResources(targetPath);

          // This confirms the data is ready before the UI reflects the change
          _logger.log(
            "Audit Log: Tree created for $targetPath. Total nodes discovered: ${tree.totalNodeCount}",
            level: LogLevel.info,
          );

          // Update the state with the results
          emit(SwatDirectoryLoaded(rootNode: tree));
        } catch (e, stack) {
          // Log the failure if the tree construction crashes
          _logger.log(
            "Audit Log: Failed to create tree for $targetPath",
            level: LogLevel.error,
            error: e,
            stackTrace: stack,
          );
          emit(SwatFailureState(e.toString()));
        }
      }
    });
  }
}
