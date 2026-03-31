import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/logging/logging.dart';

/// The blueprint for OS-level and application-level operations.
abstract class IOperational {
  Future<void> openResources(String path);
  Future<dynamic> recentResources(String appName);
  Future<bool> saveResources(dynamic payload);
  Future<String> openResource(String type);
  Future<bool> saveResource(String type, dynamic payload);
  Future<bool> deleteResource(String resource);
  Future<bool> createResource(String resource);
}

class ResourcesSystem implements IOperational {
  final ILogging _logger;

  /// The constructor uses an initializer list (the part after the colon)
  /// to ensure all final variables are set before the object is fully created.
  ResourcesSystem({
    ILogging? logger,
  }) : _logger = logger ?? Logging() {  
    // Now that _logger is initialized, you can use it in the constructor body
    _logger.log("ResourcesSystem successfully initialized.", level: LogLevel.info);
  }

  // Internal singleton instance
  static ResourcesSystem? _instance;

  // Private constructor with logger injection
  ResourcesSystem._internal({ILogging? logger}) 
      : _logger = logger ?? Logging();

  /// Access the singleton instance.
  static  ResourcesSystem get instance {
    _instance ??=  ResourcesSystem._internal();
    return _instance!;
  }

  /// Allows for manual initialization with a specific logger (ideal for tests).
  static void initialize(ILogging logger) {
    _instance =  ResourcesSystem._internal(logger: logger);
  }

  @override
  Future<void> openResources(String path) async {
    final Uri uri = Uri.file(path);
    _logger.log("Attempting to open directory: $path", level: LogLevel.info);

    try {
      if (Platform.isWindows) {
        await Process.run('explorer.exe', [path.replaceAll('/', '\\')]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [path]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [path]);
      } else if (Platform.isAndroid || Platform.isIOS) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception("System file browser unavailable for $path");
        }
      }
    } catch (e, stack) {
      _logger.log(
        "IO ERROR: Failed to open system directory", 
        level: LogLevel.error, 
        error: e, 
        stackTrace: stack
      );
      rethrow;
    }
  }

  @override
  Future<dynamic> recentResources(String appName) async {
    _logger.log("Retrieving tree structure for: $appName", level: LogLevel.debug);
    
    return null; 
  }

  @override
  Future<bool> saveResources(dynamic payload) async {
    _logger.log("Committing tree structure update to vault.", level: LogLevel.info);
    _logger.log("Tree Payload: $payload", level: LogLevel.debug);
    return true;
  }

  @override
  Future<String> openResource(String type) async {
    _logger.log("Fetching content for type: $type", level: LogLevel.debug);
    return type;
    
  }

  @override
  Future<bool> saveResource(String type, dynamic payload) async {
    _logger.log("SWAT Operation: Committing $type content to persistence.", level: LogLevel.info);
    return true;
  }


  @override
  Future<bool> deleteResource(String resource) async {
    _logger.log("Delete secure deletion for asset: $resource", level: LogLevel.warning);
    return true;
  }

  @override
  Future<bool> createResource(String resource) async {
    _logger.log("Initiating secure creation for asset: $resource", level: LogLevel.warning);
    return true;
  }

}
