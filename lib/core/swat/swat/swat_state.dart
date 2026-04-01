import 'package:equatable/equatable.dart';

// Custom Code.
import '../../../services/io/file_node.dart';

abstract class SwatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NormalPulseState extends SwatState {}

class SwatActiveState extends SwatState {
  final DateTime startTime;
  final List<String> logs;
  final int completedPoints;

  SwatActiveState({
    required this.startTime,
    this.logs = const [],
    this.completedPoints = 0,
  });

  SwatActiveState copyWith({
    List<String>? logs,
    int? completedPoints,
  }) {
    return SwatActiveState(
      startTime: startTime,
      logs: logs ?? this.logs,
      completedPoints: completedPoints ?? this.completedPoints,
    );
  }

  @override
  List<Object?> get props => [startTime, logs, completedPoints];
}

class SwatFailureState extends SwatState {
  final String error;
  SwatFailureState(this.error);

  @override
  List<Object?> get props => [error];
}

class RecoveryState extends SwatState {
  final dynamic identifiedDebt;
  RecoveryState(this.identifiedDebt);

  @override
  List<Object?> get props => [identifiedDebt];
}


// Add this class
class SwatScanningInProgress extends SwatState {
  SwatScanningInProgress();
}

// You'll also likely need a state for when the scan is finished
class SwatDirectoryLoaded extends SwatState {
  final FileNode rootNode;
  SwatDirectoryLoaded({required this.rootNode});
}