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
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
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

  bool _showExplorer = true;
  bool _showTerminal = false;
  bool _showGit = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            
            if (isLandscape) {
              return _buildLandscapeLayout(constraints);
            } else {
              return _buildPortraitLayout(constraints);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(BoxConstraints constraints) {
    final sidebarWidth = constraints.maxWidth * 0.2 as double; // 20% for sidebar
    final sidebar = sidebarWidth.clamp(180.0, 280.0);
    final editorWidth = constraints.maxWidth - sidebar - (_showTerminal ? constraints.maxHeight * 0.3 : 0);
    
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: Row(
            children: [
              // Sidebar (Explorer or Git)
              if (_showExplorer && !_showGit)
                SizedBox(width: sidebar, child: _buildExplorer())
              else if (_showGit)
                SizedBox(width: sidebar, child: _buildGitPanel()),
              if (_showExplorer || _showGit)
                _buildResizeHandle(
                  onDrag: (dx) {
                    // Handle sidebar resize if needed
                  },
                ),
              // Editor
              Expanded(
                child: _buildEditor(),
              ),
              // Terminal
              if (_showTerminal)
                _buildResizeHandle(
                  axis: Axis.vertical,
                  onDrag: (dy) {
                    // Handle terminal resize if needed
                  },
                ),
              if (_showTerminal)
                SizedBox(
                  width: _showTerminal ? (constraints.maxHeight * 0.35).clamp(120.0, 400.0) : 0.0,
                  child: _buildTerminal(),
                ),
            ],
          ),
        ),
        _buildStatusBar(),
      ],
    );
  }

  Widget _buildPortraitLayout(BoxConstraints constraints) {
    return Column(
      children: [
        _buildToolbar(),
        // Main content area
        Expanded(
          child: IndexedStack(
            index: _getActivePanel(),
            children: [
              _buildExplorer(),
              _buildEditor(),
              _buildGitPanel(),
            ],
          ),
        ),
        // Bottom panel (terminal or tabs)
        if (_showTerminal) SizedBox(height: constraints.maxHeight * 0.3, child: _buildTerminal()),
        _buildStatusBar(),
      ],
    );
  }

  int _getActivePanel() {
    if (_showGit) return 2;
    if (_showExplorer) return 0;
    return 1;
  }

  Widget _buildToolbar() {
    return Container(
      height: 56,
      color: AppTheme.sidebarBg,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _buildToolbarButton(
            icon: Icons.folder_outlined,
            label: 'Files',
            isActive: _showExplorer && !_showGit,
            onTap: () => setState(() {
              _showExplorer = !_showExplorer;
              if (_showExplorer) _showGit = false;
            }),
          ),
          _buildToolbarButton(
            icon: Icons.account_tree_outlined,
            label: 'Git',
            isActive: _showGit,
            onTap: () => setState(() {
              _showGit = !_showGit;
              if (_showGit) _showExplorer = false;
            }),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 32, color: Colors.white12),
          const SizedBox(width: 8),
          _buildToolbarButton(
            icon: _showTerminal ? Icons.terminal : Icons.terminal_outlined,
            label: 'Output',
            isActive: _showTerminal,
            onTap: () => setState(() => _showTerminal = !_showTerminal),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.green),
            onPressed: _runCode,
            tooltip: 'Run',
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _currentFilePath != null ? _saveFile : null,
            tooltip: 'Save',
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: isActive ? AppTheme.selection : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: isActive ? Colors.white : Colors.grey),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 13, color: isActive ? Colors.white : Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResizeHandle({Axis axis = Axis.horizontal, required Function(double) onDrag}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: (details) {
        if (axis == Axis.horizontal) {
          onDrag(details.delta.dx);
        } else {
          onDrag(details.delta.dy);
        }
      },
      child: Container(
        width: axis == Axis.horizontal ? 6 : double.infinity,
        height: axis == Axis.horizontal ? double.infinity : 6,
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: axis == Axis.horizontal ? 2 : 40,
            height: axis == Axis.horizontal ? 40 : 2,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
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
          // In portrait mode, switch to editor when file opened
          _showExplorer = false;
        });
      },
    );
  }

  Widget _buildEditor() {
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

  Widget _buildGitPanel() {
    final repoPath = _currentFilePath != null
        ? _currentFilePath!.substring(0, _currentFilePath!.lastIndexOf('/'))
        : null;
    return GitPanel(repoPath: repoPath);
  }

  Widget _buildTerminal() {
    return TerminalWidget(key: _terminalKey);
  }

  Widget _buildStatusBar() {
    return Container(
      height: 28,
      color: AppTheme.statusBarBg,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (_currentFilePath != null) ...[
            const Icon(Icons.description, size: 14, color: Colors.white70),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _currentFilePath!.split('/').last,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ] else
            const Expanded(
              child: Text('No file open', style: TextStyle(fontSize: 12, color: Colors.white54)),
            ),
          const SizedBox(width: 16),
          Text(
            _getFileType(),
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  String _getFileType() {
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
    if (_currentFilePath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Save and open a file first')),
        );
      }
      return;
    }
    
    await _saveFile();
    
    if (!_showTerminal) setState(() => _showTerminal = true);
    
    _terminalKey.currentState?.write('> Running ${_currentFilePath!.split('/').last}...');
    
    final result = await _executionService.execute(
      _currentFilePath!,
      onOutput: (data) => _terminalKey.currentState?.write(data),
    );
    
    if (result.exitCode == 0) {
      _terminalKey.currentState?.write('\n✓ Completed in ${result.duration.inMilliseconds}ms');
    } else {
      _terminalKey.currentState?.write('\n✗ Exit code: ${result.exitCode}');
    }
  }
}
