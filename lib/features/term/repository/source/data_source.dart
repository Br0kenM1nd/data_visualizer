import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

class DataSource {
  const DataSource();


  Future<List<File>?> pickDirs() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return null;
    List<File> files = [];
    Directory directory = Directory(selectedDirectory);
    List<FileSystemEntity> entities = directory.listSync(recursive: true);
    for (FileSystemEntity entity in entities) {
      if (entity is File && _isLas(entity)) files.add(entity);
    }
    return files;
  }

  bool _isLas(FileSystemEntity entity) => entity.path.split('.').last == 'las';

  Future<List<File>?> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['las'],
      withReadStream: true,
    );
    return result?.paths.map((file) => File(file!)).toList();
  }
}
