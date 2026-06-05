import 'package:flutter/material.dart';
import 'dart:io';
import '../models/file_item.dart';
import '../themes/app_theme.dart';
import '../services/file_service.dart';

class FileExplorer extends StatefulWidget {
  final Function(String path, String content)? onFileOpen;
  final String? selectedPath;

  const FileExplorer({super.key, this.onFileOpen, this.selectedPath});

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  final FileService _fileService = FileService();
  List<FileItem> _files = [];
  bool _loading = true;
  String? _workspacePath;
  FileItem? _clipboardItem;
  bool _cutMode = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _loading = true);
    try {
      final dir = await _fileService.workspaceDir;
      _workspacePath = dir.path;
      _files = await _fileService.loadWorkspaceFiles();
    } catch (e) {
      _files = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.sidebarBg,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _files.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _files.length,
                        itemBuilder: (context, index) => _buildFileTree(_files[index], 0),
                      ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
      child: Row(
        children: [
          const Expanded(child: Text('EXPLORER', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1))),
          _iconBtn(Icons.refresh, _loadFiles),
          _iconBtn(Icons.create_new_folder, () => _showCreateDialog(createFolder: true)),
          _iconBtn(Icons.note_add, () => _showCreateDialog(createFolder: false)),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(4), child: Padding(padding: const EdgeInsets.all(4), child: Icon(icon, size: 16, color: Colors.grey)));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 48, color: Colors.white24),
          const SizedBox(height: 8),
          const Text('No files', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          TextButton.icon(icon: const Icon(Icons.add, size: 18), label: const Text('New File'), onPressed: () => _showCreateDialog(createFolder: false)),
          TextButton.icon(icon: const Icon(Icons.create_new_folder, size: 18), label: const Text('New Folder'), onPressed: () => _showCreateDialog(createFolder: true)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white12))),
      child: Row(
        children: [
          Expanded(child: Text(_workspacePath?.split('/').last ?? 'workspace', style: const TextStyle(fontSize: 11, color: Colors.grey))),
          if (_clipboardItem != null) ...[
            Text(_cutMode ? 'Cut' : 'Copy', style: const TextStyle(fontSize: 10, color: Colors.amber)),
            const SizedBox(width: 4),
            InkWell(onTap: () => setState(() => _clipboardItem = null), child: const Icon(Icons.close, size: 14, color: Colors.grey)),
          ],
        ],
      ),
    );
  }

  Widget _buildFileTree(FileItem item, int depth) {
    if (item.type == FileType.directory) return _buildDirectory(item, depth);
    return _buildFile(item, depth);
  }

  Widget _buildDirectory(FileItem item, int depth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => item.isExpanded = !item.isExpanded),
          onLongPress: () => _showContextMenu(item),
          child: Padding(
            padding: EdgeInsets.only(left: depth * 16.0),
            child: Row(
              children: [
                Icon(item.isExpanded ? Icons.expand_more : Icons.chevron_right, size: 16, color: Colors.grey),
                Icon(item.isExpanded ? Icons.folder_open : Icons.folder, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Expanded(child: Text(item.name, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                _iconBtn(Icons.create_new_folder, () => _showCreateDialog(parentPath: item.path, createFolder: true)),
                _iconBtn(Icons.note_add, () => _showCreateDialog(parentPath: item.path, createFolder: false)),
              ],
            ),
          ),
        ),
        if (item.isExpanded) ...item.children.map((child) => _buildFileTree(child, depth + 1)),
      ],
    );
  }

  Widget _buildFile(FileItem item, int depth) {
    final isSelected = widget.selectedPath == item.path;
    return InkWell(
      onTap: () async {
        if (item.isCode) {
          try {
            final content = await _fileService.readFile(item.path);
            widget.onFileOpen?.call(item.path, content);
          } catch (e) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
      },
      onLongPress: () => _showContextMenu(item),
      child: Container(
        padding: EdgeInsets.only(left: depth * 16.0 + 20),
        color: isSelected ? AppTheme.selection : null,
        child: Row(
          children: [
            Icon(_getFileIcon(item), size: 16, color: _getFileColor(item)),
            const SizedBox(width: 4),
            Expanded(child: Text(item.name, style: TextStyle(fontSize: 13, color: item.isCode ? Colors.white : Colors.grey), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(FileItem item) {
    final colors = {'go': Icons.code, 'py': Icons.code, 'js': Icons.javascript, 'ts': Icons.javascript, 'html': Icons.html, 'css': Icons.css, 'json': Icons.data_object, 'md': Icons.article, 'dart': Icons.flutter_dash};
    return colors[item.extension] ?? Icons.description;
  }

  Color _getFileColor(FileItem item) {
    final colors = {'go': Colors.cyan, 'py': Colors.yellow, 'js': Colors.amber, 'ts': Colors.amber, 'html': Colors.orange, 'css': Colors.blue, 'json': Colors.grey};
    return colors[item.extension] ?? Colors.grey;
  }

  void _showContextMenu(FileItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.panelBg,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.add), title: const Text('New File Here'), onTap: () { Navigator.pop(ctx); _showCreateDialog(parentPath: item.type == FileType.directory ? item.path : null); }),
            ListTile(leading: const Icon(Icons.create_new_folder), title: const Text('New Folder Here'), onTap: () { Navigator.pop(ctx); _showCreateDialog(parentPath: item.type == FileType.directory ? item.path : null, createFolder: true); }),
            const Divider(color: Colors.white12),
            ListTile(leading: const Icon(Icons.edit), title: const Text('Rename'), onTap: () { Navigator.pop(ctx); _showRenameDialog(item); }),
            ListTile(leading: const Icon(Icons.content_copy), title: const Text('Copy'), onTap: () { Navigator.pop(ctx); setState(() { _clipboardItem = item; _cutMode = false; }); }),
            ListTile(leading: const Icon(Icons.content_cut), title: const Text('Cut'), onTap: () { Navigator.pop(ctx); setState(() { _clipboardItem = item; _cutMode = true; }); }),
            if (_clipboardItem != null && item.type == FileType.directory) ListTile(leading: const Icon(Icons.paste), title: Text(_cutMode ? 'Move Here' : 'Paste Here'), onTap: () { Navigator.pop(ctx); _pasteItem(item.path); }),
            const Divider(color: Colors.white12),
            ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('Delete', style: TextStyle(color: Colors.red)), onTap: () { Navigator.pop(ctx); _showDeleteConfirm(item); }),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog({String? parentPath, bool createFolder = false}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panelBg,
        title: Text(createFolder ? 'New Folder' : 'New File'),
        content: TextField(controller: controller, autofocus: true, decoration: InputDecoration(hintText: createFolder ? 'folder name' : 'filename.go', suffix: createFolder ? null : const Text('.go', style: TextStyle(color: Colors.grey)))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (controller.text.isEmpty) return;
              String basePath = parentPath ?? _workspacePath ?? '';
              String name = controller.text;
              if (!createFolder && !name.contains('.')) name = '$name.go';
              String newPath = '$basePath/$name';
              try {
                if (createFolder) await _fileService.createDirectory(newPath);
                else await _fileService.createFile(newPath);
                _loadFiles();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(FileItem item) {
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panelBg,
        title: const Text('Rename'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (controller.text.isEmpty) return;
              final dir = item.path.substring(0, item.path.lastIndexOf('/'));
              final newPath = '$dir/${controller.text}';
              try {
                await _fileService.rename(item.path, newPath);
                _loadFiles();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(FileItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panelBg,
        title: const Text('Delete'),
        content: Text('Delete "${item.name}"? This cannot be undone.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _fileService.delete(item.path);
              _loadFiles();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _pasteItem(String targetDir) async {
    if (_clipboardItem == null || _workspacePath == null) return;
    final baseName = _clipboardItem!.name;
    String newPath = '$targetDir/$baseName';
    int counter = 1;
    while (await File(newPath).exists() || await Directory(newPath).exists()) {
      final parts = baseName.split('.');
      if (parts.length > 1 && _clipboardItem!.type == FileType.file) {
        newPath = '$targetDir/${parts[0]}_$counter.${parts.sublist(1).join('.')}';
      } else {
        newPath = '$targetDir/${baseName}_$counter';
      }
      counter++;
    }
    try {
      if (_cutMode) await _fileService.move(_clipboardItem!.path, newPath);
      else await _fileService.copy(_clipboardItem!.path, newPath);
      setState(() { _clipboardItem = null; _cutMode = false; });
      _loadFiles();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
