import 'package:equatable/equatable.dart';

/// Define the base SwatEvent. 
/// Using 'sealed' is a modern Dart 
/// 3+ best practice for BLoCs.
sealed class SwatEvent extends Equatable {
  const SwatEvent();

  @override
  List<Object?> get props => [];
}


/// Define concrete event types
class OpenDirectoryRequested extends SwatEvent {
  final String? path;
  const OpenDirectoryRequested({this.path});
}
class ActivateSwatEvent extends SwatEvent {}

class LogIncidentEvent extends SwatEvent {
  final String description;
  const LogIncidentEvent({required this.description});

  @override
  List<Object?> get props => [description];
}

class DeescalateEvent extends SwatEvent {
  final dynamic identifiedDebt;
  const DeescalateEvent(this.identifiedDebt);

  @override
  List<Object?> get props => [identifiedDebt];
}
