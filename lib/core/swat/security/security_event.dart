/*
 * Copyright (C) 2026 [The Organisation]
 * This file is subject to the license agreement found in the 
 * root of this project in the file: license.md
 */

part of 'security_bloc.dart';

sealed class SecurityEvent extends Equatable {
  const SecurityEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the system detects non-standard behavior
class SuspiciousActivityDetected extends SecurityEvent {
  final String reason;
  const SuspiciousActivityDetected({required this.reason});

  @override
  List<Object?> get props => [reason];
}

/// Triggered when a user fails authentication multiple times
class AuthenticationThresholdExceeded extends SecurityEvent {
  final int attempts;
  const AuthenticationThresholdExceeded(this.attempts);

  @override
  List<Object?> get props => [attempts];
}

/// Manual override to return the system to a secure state
class SecurityResetRequested extends SecurityEvent {}
