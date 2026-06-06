import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/editor.dart';
import '../services/executor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Executor _executor = Executor();
  final GlobalKey<CodeEditorState> _editorKey = GlobalKey();
  String _output = '';
  bool _isRunning = false;
  bool _showOutput = false;

  Future<void> _runCode() async {
    setState(() {
      _isRunning = true;
      _showOutput = true;
      _output = 'Running...\n';
    });

    final code = _editorKey.currentState?.getCode() ?? '';
    final result = await _executor.runGo(code);

    setState(() {
      _isRunning = false;
      _output = result.exitCode == 0 ? result.output : 'Error:\n${result.output}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 48,
              color: AppTheme.surface,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Text('Go Editor', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _isRunning ? null : _runCode,
                    icon: _isRunning
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.play_arrow, size: 18),
                    label: Text(_isRunning ? 'Running...' : 'Run'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            Expanded(child: CodeEditor(key: _editorKey)),
            if (_showOutput) _buildOutputPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputPanel() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Color(0xFF0C0C0C),
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        children: [
          Container(
            height: 32,
            color: AppTheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Text('OUTPUT', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  color: AppTheme.textSecondary,
                  onPressed: () => setState(() => _showOutput = false),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Text(_output.isEmpty ? 'No output' : _output, style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'monospace', fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
