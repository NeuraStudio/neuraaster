import 'dart:io';
import 'dart:typed_data';

import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileService {
  static const _extensionMap = <String, String>{
    'dart': 'dart',
    'flutter': 'dart',
    'python': 'py',
    'py': 'py',
    'javascript': 'js',
    'js': 'js',
    'typescript': 'ts',
    'ts': 'ts',
    'java': 'java',
    'kotlin': 'kt',
    'swift': 'swift',
    'cpp': 'cpp',
    'c++': 'cpp',
    'c': 'c',
    'rust': 'rs',
    'go': 'go',
    'json': 'json',
    'yaml': 'yaml',
    'yml': 'yml',
    'xml': 'xml',
    'html': 'html',
    'css': 'css',
    'sql': 'sql',
    'bash': 'sh',
    'shell': 'sh',
    'sh': 'sh',
    'txt': 'txt',
  };

  Future<String> saveCode({
    required String code,
    required String language,
    String? requestedName,
  }) async {
    final dir = await _appFileDirectory();
    final extension = _extensionMap[language.toLowerCase().trim()] ?? 'txt';
    final base = _sanitizeFileName(
      requestedName?.trim().isNotEmpty == true ? requestedName! : 'neuraaster_script',
    );
    final fileName = base.toLowerCase().endsWith('.$extension') ? base : '$base.$extension';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(code);
    return file.path;
  }

  Future<String> saveBinary(Uint8List bytes, String fileName) async {
    final dir = await _appFileDirectory();
    final file = File('${dir.path}/${_sanitizeFileName(fileName)}');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<bool> saveImageToGallery(String pathOrUrl) async {
    if (Platform.isAndroid && (await Permission.photos.request()).isDenied) {
      // Android 13+ uses media permission. Older Android versions may not expose photos.
      await Permission.storage.request();
    }

    if (pathOrUrl.startsWith('http')) {
      final result = await GallerySaver.saveImage(pathOrUrl);
      return result ?? false;
    }

    final bytes = await File(pathOrUrl).readAsBytes();
    final result = await ImageGallerySaverPlus.saveImage(
      bytes,
      quality: 100,
      name: 'neuraaster_${DateTime.now().millisecondsSinceEpoch}',
    );
    return result['isSuccess'] == true;
  }

  Future<bool> saveVideoToGallery(String path) async {
    final result = await GallerySaver.saveVideo(path);
    return result ?? false;
  }

  Future<Directory> _appFileDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final target = Directory('${directory.path}/NeuraAster');
    if (!await target.exists()) await target.create(recursive: true);
    return target;
  }

  String _sanitizeFileName(String value) {
    final sanitized = value.replaceAll(RegExp(r'[<>:"/\\\\|?*]'), '_');
    return sanitized.isEmpty ? 'file' : sanitized;
  }
}
