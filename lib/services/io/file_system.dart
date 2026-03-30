import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

abstract class IOperational {
  Future<void> openDirectory(String path);
}

class FileSystem implements IOperational {

  FileSystem();
  FileSystem._internal();
  static final FileSystem instance = FileSystem._internal();

  @override
  Future<void> openDirectory(String path) async {
    final Uri uri = Uri.file(path);

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
        throw Exception("Could not launch system file browser for $path");
      }
    }
  }
}
