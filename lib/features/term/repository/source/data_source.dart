import 'dart:async';

import 'package:file_picker/file_picker.dart';

class DataSource {
  const DataSource();

  Future<FilePickerResult?> pickFiles() {
    return FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['las'],
      withReadStream: true,
    );
  }
}
