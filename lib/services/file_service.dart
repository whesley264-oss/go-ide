import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/file_item.dart';

class FileService {
  Directory? _workspaceDir;
  
  Future<Directory> get workspaceDir async {
    if (_workspaceDir != null) return _workspaceDir!;
    final appDir = await getApplicationDocumentsDirectory();
    _workspaceDir = Directory('${appDir.path}/workspace');
    if (!await _workspaceDir!.exists()) {
      await _workspaceDir!.create(recursive: true);
    }
    return _workspaceDir!;
  }
  
  Future<List<FileItem>> loadWorkspaceFiles() async {
    final dir = await workspaceDir;
    return FileItem.fromDirectory(dir);
  }
  
  Future<String> readFile(String path) async {
    final file = File(path);
    if (await file.exists()) return await file.readAsString();
    throw Exception('File not found: $path');
  }
  
  Future<void> writeFile(String path, String content) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }
  
  Future<void> createFile(String path, {String content = ''}) async {
    final file = File(path);
    if (await file.exists()) throw Exception('File already exists');
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }
  
  Future<void> createDirectory(String path) async {
    final dir = Directory(path);
    if (await dir.exists()) throw Exception('Directory already exists');
    await dir.create(recursive: true);
  }
  
  Future<void> delete(String path) async {
    final file = File(path);
    final dir = Directory(path);
    if (await file.exists()) await file.delete();
    else if (await dir.exists()) await dir.delete(recursive: true);
  }
  
  Future<void> rename(String oldPath, String newPath) async {
    final file = File(oldPath);
    final dir = Directory(oldPath);
    if (await file.exists()) await file.rename(newPath);
    else if (await dir.exists()) await dir.rename(newPath);
  }
  
  Future<void> move(String sourcePath, String destPath) async {
    final file = File(sourcePath);
    final dir = Directory(sourcePath);
    if (await file.exists()) {
      await file.rename(destPath);
    } else if (await dir.exists()) {
      // For directories, we need to copy and delete
      await _copyDirectory(dir, Directory(destPath));
      await dir.delete(recursive: true);
    }
  }
  
  Future<void> _copyDirectory(Directory source, Directory dest) async {
    await dest.create(recursive: true);
    await for (final entity in source.list()) {
      final newPath = '${dest.path}/${entity.path.split(Platform.pathSeparator).last}';
      if (entity is File) {
        await entity.copy(newPath);
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory(newPath));
      }
    }
  }
  
  Future<void> copy(String sourcePath, String destPath) async {
    final file = File(sourcePath);
    final dir = Directory(sourcePath);
    if (await file.exists()) {
      await file.copy(destPath);
    } else if (await dir.exists()) {
      await _copyDirectory(dir, Directory(destPath));
    }
  }
  
  Future<String?> pickDirectory() async {
    return await FilePicker.platform.getDirectoryPath();
  }
  
  Future<String?> pickFile() async {
    return (await FilePicker.platform.pickFiles())?.files.single.path;
  }
}
