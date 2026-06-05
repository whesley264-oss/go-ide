import 'dart:io';

enum FileType {
  file,
  directory,
}

class FileItem {
  final String name;
  final String path;
  final FileType type;
  bool isExpanded;
  List<FileItem> children;
  
  FileItem({
    required this.name,
    required this.path,
    required this.type,
    this.isExpanded = false,
    this.children = const [],
  });
  
  static Future<List<FileItem>> fromDirectory(Directory dir, {int depth = 0}) async {
    List<FileItem> items = [];
    if (!await dir.exists()) return items;
    
    try {
      final entities = await dir.list().toList();
      entities.sort((a, b) {
        // Directories first
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;
        if (aIsDir && !bIsDir) return -1;
        if (!aIsDir && bIsDir) return 1;
        return a.path.compareTo(b.path);
      });
      
      for (final entity in entities) {
        final name = entity.path.split(Platform.pathSeparator).last;
        if (name.startsWith('.')) continue; // Skip hidden files
        
        if (entity is Directory) {
          final children = depth < 3 
              ? await fromDirectory(entity, depth: depth + 1)
              : <FileItem>[];
          items.add(FileItem(
            name: name,
            path: entity.path,
            type: FileType.directory,
            children: children,
          ));
        } else if (entity is File) {
          items.add(FileItem(
            name: name,
            path: entity.path,
            type: FileType.file,
          ));
        }
      }
    } catch (e) {
      // Permission denied or other errors
    }
    return items;
  }
  
  String get extension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }
  
  bool get isImage => ['png', 'jpg', 'jpeg', 'gif', 'webp', 'svg'].contains(extension);
  bool get isCode => ['go', 'py', 'js', 'ts', 'java', 'c', 'cpp', 'h', 'hpp', 'rs', 'rb', 'php', 'swift', 'kt', 'dart', 'html', 'css', 'scss', 'json', 'yaml', 'yml', 'xml', 'md', 'sql', 'sh', 'bash', 'zsh'].contains(extension);
}
