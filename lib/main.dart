import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'themes/app_theme.dart';
import 'widgets/file_explorer.dart';
import 'widgets/editor_panel.dart';
import 'widgets/terminal_panel.dart';
import 'widgets/git_panel.dart';
import 'services/file_service.dart';
import 'services/code_execution_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const CodeEditorApp());
}

class CodeEditorApp extends StatelessWidget {
  const CodeEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Code Editor',
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FileService _fileService = FileService();
  final CodeExecutionService _executionService = CodeExecutionService();
  final GlobalKey<TerminalWidgetState> _terminalKey = GlobalKey();

  String? _currentFilePath;
  String _currentContent = '';
  String _unsavedContent = '';

  int _selectedSidebarItem = 0; // 0 = Explorer, 1 = Git, 2 = Search

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Left sidebar (VS Code style icons)
            _buildIconSidebar(),
            // File Explorer or Git Panel
            _buildSidebarContent(),
            // Vertical divider
            Container(width: 1, color: Colors.white10),
            // Main editor + terminal
            Expanded(
              child: Column(
                children: [
                  _buildEditorToolbar(),
                  Expanded(child: _buildEditorArea()),
                  if (_showTerminal) _buildTerminal(),
                  _buildStatusBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSidebar() {
    return Container(
      width: 48,
      color: AppTheme.activityBarBg,
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildSidebarIcon(Icons.folder_outlined, 0, tooltip: 'Explorer'),
          _buildSidebarIcon(Icons.account_tree_outlined, 1, tooltip: 'Git'),
          _buildSidebarIcon(Icons.search, 2, tooltip: 'Search'),
          const Spacer(),
          _buildSidebarIcon(Icons.settings, 3, tooltip: 'Settings'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSidebarIcon(IconData icon, int index, {String? tooltip}) {
    final isSelected = _selectedSidebarItem == index;
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: () => setState(() => _selectedSidebarItem = index),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Container(
      width: 250,
      color: AppTheme.sidebarBg,
      child: _selectedSidebarItem == 0
          ? _buildExplorer()
          : _selectedSidebarItem == 1
              ? _buildGitPanel()
              : _buildSearchPanel(),
    );
  }

  Widget _buildExplorer() {
    return FileExplorer(
      selectedPath: _currentFilePath,
      onFileOpen: (path, content) {
        setState(() {
          _currentFilePath = path;
          _currentContent = content;
          _unsavedContent = content;
        });
      },
    );
  }

  Widget _buildGitPanel() {
    return GitPanelWidget(
      repoPath: _currentFilePath != null 
          ? _currentFilePath!.substring(0, _currentFilePath!.lastIndexOf('/'))
          : null,
    );
  }

  Widget _buildSearchPanel() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: const Text(
            'SEARCH',
            style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text('Search coming soon', style: TextStyle(color: Colors.grey)),
          ),
        ),
      ],
    );
  }

  Widget _buildEditorToolbar() {
    return Container(
      height: 40,
      color: AppTheme.editorGroupHeaderBg,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          if (_currentFilePath != null) ...[
            Text(
              _currentFilePath!.split('/').last,
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
            if (_unsavedContent != _currentContent)
              const Text(' *', style: TextStyle(color: Colors.orange)),
          ] else
            const Text('No file open', style: TextStyle(color: Colors.grey)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.play_arrow, size: 20),
            onPressed: _currentFilePath != null ? _runCode : null,
            tooltip: 'Run',
            color: Colors.green,
          ),
          IconButton(
            icon: const Icon(Icons.save, size: 20),
            onPressed: _currentFilePath != null ? _saveFile : null,
            tooltip: 'Save',
          ),
          IconButton(
            icon: Icon(_showTerminal ? Icons.terminal : Icons.terminal_outlined, size: 20),
            onPressed: () => setState(() => _showTerminal = !_showTerminal),
            tooltip: 'Toggle Terminal',
          ),
        ],
      ),
    );
  }

  Widget _buildEditorArea() {
    if (_currentFilePath == null) {
      return Container(
        color: AppTheme.editorBg,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.code, size: 64, color: Colors.white12),
              SizedBox(height: 16),
              Text('Open a file to start editing', style: TextStyle(color: Colors.grey, fontSize: 16)),
              SizedBox(height: 8),
              Text('Click on a file in the Explorer', style: TextStyle(color: Colors.white38, fontSize: 13)),
            ],
          ),
        ),
      );
    }
    return EditorPanel(
      filePath: _currentFilePath,
      initialContent: _currentContent,
      onContentChanged: (content) {
        setState(() => _unsavedContent = content);
      },
      onSave: _saveFile,
      onRun: _runCode,
    );
  }

  bool _showTerminal = false;

  Widget _buildTerminal() {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // Future: resize terminal
      },
      child: Container(
        height: 200,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: TerminalWidget(key: _terminalKey),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 24,
      color: AppTheme.statusBarBg,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          if (_currentFilePath != null) ...[
            Text(
              _currentFilePath!.split('/').last,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(width: 16),
          ],
          const Spacer(),
          Text(
            _getLanguage(),
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  String _getLanguage() {
    if (_currentFilePath == null) return '';
    final ext = _currentFilePath!.split('.').last.toUpperCase();
    return ext;
  }

  Future<void> _saveFile() async {
    if (_currentFilePath == null) return;
    try {
      await _fileService.writeFile(_currentFilePath!, _unsavedContent);
      setState(() => _currentContent = _unsavedContent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File saved'), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _runCode() async {
    if (_currentFilePath == null) return;
    await _saveFile();
    if (!_showTerminal) setState(() => _showTerminal = true);
    _terminalKey.currentState?.write('> Running ${_currentFilePath!.split('/').last}...\n');
    final result = await _executionService.execute(
      _currentFilePath!,
      onOutput: (data) => _terminalKey.currentState?.write('$data\n'),
    );
    if (result.exitCode == 0) {
      _terminalKey.currentState?.write('Done in ${result.duration.inMilliseconds}ms\n');
    } else {
      _terminalKey.currentState?.write('Exit code: ${result.exitCode}\n');
    }
  }
}
