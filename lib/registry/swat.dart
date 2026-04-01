export 'package:flutter_bloc/flutter_bloc.dart';

// Custom Code
export '../core/swat/swat/swat_bloc.dart';
export '../core/swat/swat/swat_event.dart';
export '../core/swat/swat/swat_state.dart';

import '../core/swat/swat/swat_bloc.dart';
import '../../../services/logging/logging.dart';
import '../services/io/resources_system.dart';

/// The SwatRegistry acts as the infrastructure 
/// coordinator. It separates the UI from how 
/// the SWAT Protocol is actually constructed.
class SwatRegistry {
  /// Private constructor to prevent instantiation.
  SwatRegistry._();

  /// A central factory method to create a fully 
  /// configured SwatBloc.This is where you inject 
  /// your world-class services.
  /// 
  /// In the future extra services can be added.
  static SwatBloc create() {
    return SwatBloc(
      logger: Logging(),
      fileSystem: ResourcesSystem(),
    );
  }
}