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
      // Create sample Go file
      final sampleFile = File('${_workspaceDir!.path}/main.go');
      await sampleFile.writeAsString('''package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
''');
    }
    return _workspaceDir!;
  }
  
  Future<List<FileItem>> loadWorkspaceFiles() async {
    final dir = await workspaceDir;
    return FileItem.fromDirectory(dir);
  }
  
  Future<String> readFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsString();
    }
    throw Exception('File not found: $path');
  }
  
  Future<void> writeFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }
  
  Future<void> createFile(String path, {String content = ''}) async {
    final file = File(path);
    if (await file.exists()) {
      throw Exception('File already exists: $path');
    }
    await file.writeAsString(content);
  }
  
  Future<void> createDirectory(String path) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      throw Exception('Directory already exists: $path');
    }
    await dir.create(recursive: true);
  }
  
  Future<void> delete(String path) async {
    final file = File(path);
    final dir = Directory(path);
    if (await file.exists()) {
      await file.delete();
    } else if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
  
  Future<void> rename(String oldPath, String newPath) async {
    final file = File(oldPath);
    final dir = Directory(oldPath);
    if (await file.exists()) {
      await file.rename(newPath);
    } else if (await dir.exists()) {
      await dir.rename(newPath);
    }
  }
  
  Future<String?> pickDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath();
    return result;
  }
  
  Future<String?> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    return result?.files.single.path;
  }
}
