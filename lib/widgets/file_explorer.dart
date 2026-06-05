import 'package:flutter/material.dart';
import '../models/file_item.dart';
import '../themes/app_theme.dart';
import '../services/file_service.dart';

class FileExplorer extends StatefulWidget {
  final Function(String path, String content)? onFileOpen;
  final VoidCallback? onRefresh;
  final String? selectedPath;

  const FileExplorer({
    super.key,
    this.onFileOpen,
    this.onRefresh,
    this.selectedPath,
  });

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  final FileService _fileService = FileService();
  List<FileItem> _files = [];
  bool _loading = true;
  String? _workspacePath;

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
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : ListView.builder(
                    itemCount: _files.length,
                    itemBuilder: (context, index) =>
                        _buildFileTree(_files[index], 0),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'EXPLORER',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          _buildIconButton(Icons.refresh, _loadFiles),
          _buildIconButton(Icons.create_new_folder, _showNewFolderDialog),
          _buildIconButton(Icons.note_add, _showNewFileDialog),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildFileTree(FileItem item, int depth) {
    if (item.type == FileType.directory) {
      return _buildDirectory(item, depth);
    }
    return _buildFile(item, depth);
  }

  Widget _buildDirectory(FileItem item, int depth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() => item.isExpanded = !item.isExpanded);
          },
          child: Padding(
            padding: EdgeInsets.only(left: depth * 16.0),
            child: Row(
              children: [
                Icon(
                  item.isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 16,
                  color: Colors.grey,
                ),
                Icon(
                  item.isExpanded ? Icons.folder_open : Icons.folder,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (item.isExpanded)
          ...item.children.map((child) => _buildFileTree(child, depth + 1)),
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
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error opening file: $e')),
              );
            }
          }
        }
      },
      onSecondaryTap: () => _showFileContextMenu(context, item),
      child: Container(
        padding: EdgeInsets.only(left: depth * 16.0 + 20),
        color: isSelected ? AppTheme.selection : null,
        child: Row(
          children: [
            Icon(
              _getFileIcon(item),
              size: 16,
              color: _getFileColor(item),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 13,
                  color: item.isCode ? Colors.white : Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(FileItem item) {
    switch (item.extension) {
      case 'go':
        return Icons.code;
      case 'py':
        return Icons.code;
      case 'js':
      case 'ts':
        return Icons.javascript;
      case 'html':
        return Icons.html;
      case 'css':
        return Icons.css;
      case 'json':
        return Icons.data_object;
      case 'md':
        return Icons.article;
      case 'dart':
        return Icons.flutter_dash;
      default:
        return Icons.description;
    }
  }

  Color _getFileColor(FileItem item) {
    switch (item.extension) {
      case 'go':
        return Colors.cyan;
      case 'py':
        return Colors.yellow;
      case 'js':
      case 'ts':
        return Colors.amber;
      case 'html':
        return Colors.orange;
      case 'css':
        return Colors.blue;
      case 'json':
        return Colors.grey;
      case 'md':
        return Colors.white70;
      default:
        return Colors.grey;
    }
  }

  void _showFileContextMenu(BuildContext context, FileItem item) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(ctx);
                _showRenameDialog(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteConfirmation(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNewFileDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panelBg,
        title: const Text('New File'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'filename.go',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (controller.text.isNotEmpty && _workspacePath != null) {
                final path = '$_workspacePath/${controller.text}';
                await _fileService.createFile(path);
                _loadFiles();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showNewFolderDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panelBg,
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'folder name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (controller.text.isNotEmpty && _workspacePath != null) {
                final path = '$_workspacePath/${controller.text}';
                await _fileService.createDirectory(path);
                _loadFiles();
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
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (controller.text.isNotEmpty && _workspacePath != null) {
                final newPath = '${item.path.substring(0, item.path.lastIndexOf('/') + 1)}${controller.text}';
                await _fileService.rename(item.path, newPath);
                _loadFiles();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(FileItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panelBg,
        title: const Text('Delete'),
        content: Text('Delete "${item.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
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
}
