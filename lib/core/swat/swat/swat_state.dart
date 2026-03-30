import 'package:equatable/equatable.dart';

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
