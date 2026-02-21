import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DirectorySelection {
  const DirectorySelection({required this.path, required this.files});

  final String path;
  final List<File> files;
}

class DataSource {
  const DataSource();

  static const String _lastDirectoryKey = 'last_selected_directory';

  Future<List<File>> pickDirs() async {
    final selectedDirectory = await pickDirectoryPath();
    if (selectedDirectory == null) {
      return <File>[];
    }

    return getLasFilesFromDirectory(selectedDirectory);
  }

  Future<DirectorySelection?> pickDirectorySelection() async {
    final selectedDirectory = await pickDirectoryPath();
    if (selectedDirectory == null) {
      return null;
    }

    final files = await getLasFilesFromDirectory(selectedDirectory);
    return DirectorySelection(path: selectedDirectory, files: files);
  }

  Future<String?> pickDirectoryPath() => FilePicker.platform.getDirectoryPath();

  Future<List<File>> getLasFilesFromDirectory(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      return <File>[];
    }

    final files = <File>[];
    await for (final FileSystemEntity entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File && _isLas(entity.path)) {
        files.add(entity);
      }
    }

    return files;
  }

  Future<List<File>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: <String>['las'],
      withReadStream: true,
    );

    if (result == null) {
      return <File>[];
    }

    return result.paths
        .whereType<String>()
        .map((path) => File(path))
        .toList(growable: false);
  }

  bool _isLas(String path) {
    final parts = path.toLowerCase().split('.');
    if (parts.length < 2) {
      return false;
    }

    return parts.last == 'las';
  }

  Future<void> saveLastDirectory(String directoryPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastDirectoryKey, directoryPath);
  }

  Future<String?> getLastDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastDirectoryKey);
  }

  Future<void> clearLastDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastDirectoryKey);
  }
}
