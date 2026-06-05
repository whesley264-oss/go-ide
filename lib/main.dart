import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'themes/app_theme.dart';
import 'widgets/file_explorer.dart';
import 'widgets/editor_panel.dart';
import 'widgets/terminal_panel.dart';
import 'services/file_service.dart';
import 'services/code_execution_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
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
  
  String? _currentFilePath;
  String _currentContent = '';
  String _unsavedContent = '';
  
  final GlobalKey<_FileExplorerState> _explorerKey = GlobalKey();
  final GlobalKey<_TerminalPanelState> _terminalKey = GlobalKey();
  final GlobalKey<_EditorPanelState> _editorKey = GlobalKey();
  
  bool _showExplorer = true;
  bool _showTerminal = false;
  double _explorerWidth = 220;
  double _terminalHeight = 200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            _buildAppBar(),
            // Main content
            Expanded(
              child: Row(
                children: [
                  // File Explorer
                  if (_showExplorer)
                    GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _explorerWidth -= details.delta.dx;
                          _explorerWidth = _explorerWidth.clamp(150, 400);
                        });
                      },
                      child: SizedBox(
                        width: _explorerWidth,
                        child: FileExplorer(
                          key: _explorerKey,
                          selectedPath: _currentFilePath,
                          onFileOpen: (path, content) {
                            setState(() {
                              _currentFilePath = path;
                              _currentContent = content;
                              _unsavedContent = content;
                            });
                          },
                        ),
                      ),
                    ),
                  // Resize handle
                  if (_showExplorer)
                    GestureDetector(
                      onVerticalDragUpdate: (details) {
                        setState(() {
                          _explorerWidth -= details.delta.dx;
                          _explorerWidth = _explorerWidth.clamp(150, 400);
                        });
                      },
                      child: Container(
                        width: 4,
                        color: Colors.transparent,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.white12,
                        ),
                      ),
                    ),
                  // Editor + Terminal
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: EditorPanel(
                            key: _editorKey,
                            filePath: _currentFilePath,
                            initialContent: _currentContent,
                            onContentChanged: (content) {
                              _unsavedContent = content;
                            },
                            onSave: _saveFile,
                            onRun: _runCode,
                          ),
                        ),
                        // Resize handle for terminal
                        if (_showTerminal)
                          GestureDetector(
                            onVerticalDragUpdate: (details) {
                              setState(() {
                                _terminalHeight += details.delta.dy;
                                _terminalHeight = _terminalHeight.clamp(100, 500);
                              });
                            },
                            child: Container(
                              height: 6,
                              color: Colors.transparent,
                              child: Center(
                                child: Container(
                                  height: 3,
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  color: Colors.white12,
                                ),
                              ),
                            ),
                          ),
                        // Terminal
                        if (_showTerminal)
                          SizedBox(
                            height: _terminalHeight,
                            child: TerminalPanel(key: _terminalKey),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Status bar
            _buildStatusBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 48,
      color: AppTheme.sidebarBg,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_showExplorer ? Icons.menu_open : Icons.menu, size: 22),
            onPressed: () => setState(() => _showExplorer = !_showExplorer),
            tooltip: 'Toggle Explorer',
          ),
          const SizedBox(width: 8),
          const Text(
            'Code Editor',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _showTerminal ? Icons.terminal : Icons.terminal_outlined,
              size: 22,
            ),
            onPressed: () => setState(() => _showTerminal = !_showTerminal),
            tooltip: 'Toggle Terminal',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            onPressed: () {
              // Refresh explorer
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 24,
      color: AppTheme.statusBarBg,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (_currentFilePath != null) ...[
            Icon(Icons.description, size: 14, color: Colors.white.withOpacity(0.8)),
            const SizedBox(width: 4),
            Text(
              _currentFilePath!.split('/').last,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(width: 16),
          ],
          const Spacer(),
          Text(
            'Dart 3 | UTF-8 |Ln 1, Col 1',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveFile() async {
    if (_currentFilePath == null) return;
    
    try {
      await _fileService.writeFile(_currentFilePath!, _unsavedContent);
      setState(() => _currentContent = _unsavedContent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File saved'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      }
    }
  }

  Future<void> _runCode() async {
    if (_currentFilePath == null) {
      // Need to save first
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please save the file first')),
      );
      return;
    }
    
    // Show terminal if hidden
    if (!_showTerminal) {
      setState(() => _showTerminal = true);
    }
    
    // Get terminal and write running message
    final terminal = _terminalKey.currentState;
    terminal?.writeOutput('Running ${_currentFilePath!.split('/').last}...');
    
    // Execute
    final result = await _executionService.execute(
      _currentFilePath!,
      onOutput: (data) {
        terminal?.writeOutput(data);
      },
    );
    
    // Show result
    if (result.exitCode == 0) {
      terminal?.writeOutput('\n\x1b[32m✓ Done in ${result.duration.inMilliseconds}ms\x1b[0m');
    } else {
      terminal?.writeError('\n\x1b[31m✗ Exit code: ${result.exitCode}\x1b[0m');
    }
  }
}

// Type alias for the explorer state key
class _FileExplorerState extends State<FileExplorer> {}
class _TerminalPanelState extends State<TerminalPanel> {}
class _EditorPanelState extends State<EditorPanel> {}
