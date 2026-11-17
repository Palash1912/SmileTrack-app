import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class PickedFile {
  final String name;
  final Uint8List? bytes;   // used on Web
  final File? file;         // used on Mobile

  PickedFile({required this.name, this.bytes, this.file});

  bool get isWeb => bytes != null;
}

class FilePickerHelper {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<List<PickedFile>> pickImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage();
      List<PickedFile> result = [];
      for (final xFile in pickedFiles) {
        if (kIsWeb) {
          final bytes = await xFile.readAsBytes();
          result.add(PickedFile(name: xFile.name, bytes: bytes));
        } else {
          result.add(PickedFile(name: xFile.name, file: File(xFile.path)));
        }
      }
      return result;
    } catch (e) {
      print('Error picking images: $e');
      return [];
    }
  }

  static Future<List<PickedFile>> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'png', 'jpeg'],
        withData: true, // IMPORTANT: needed for Web to get bytes
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.map((f) {
          if (kIsWeb) {
            return PickedFile(name: f.name, bytes: f.bytes);
          } else {
            return PickedFile(
                name: f.name, file: f.path != null ? File(f.path!) : null);
          }
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error picking files: $e');
      return [];
    }
  }

  static String getFileName(String filePath) {
    return filePath.split('/').last;
  }
}
