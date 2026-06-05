import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/highlight.dart' show highlight;
import '../themes/app_theme.dart';

class CodeEditor extends StatefulWidget {
  final String initialCode;
  final String language;
  final Function(String)? onCodeChanged;
  final Function(String)? onSave;
  
  const CodeEditor({
    super.key,
    this.initialCode = '',
    this.language = 'go',
    this.onCodeChanged,
    this.onSave,
  });
  
  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  late ScrollController _lineNumberScrollController;
  int _lineCount = 1;
  
  final Map<String, TextStyle> _theme = {
    'root': TextStyle(
      color: Colors.white,
      backgroundColor: AppTheme.editorBg,
      fontFamily: 'monospace',
      fontSize: 14,
    ),
    'keyword': const TextStyle(color: AppTheme.keyword, fontWeight: FontWeight.bold),
    'built_in': const TextStyle(color: AppTheme.type),
    'type': const TextStyle(color: AppTheme.type),
    'literal': const TextStyle(color: AppTheme.number),
    'number': const TextStyle(color: AppTheme.number),
    'string': const TextStyle(color: AppTheme.string),
    'comment': const TextStyle(color: AppTheme.comment, fontStyle: FontStyle.italic),
    'variable': const TextStyle(color: AppTheme.variable),
    'function': const TextStyle(color: AppTheme.function),
    'title': const TextStyle(color: AppTheme.function),
    'params': const TextStyle(color: AppTheme.variable),
    'meta': const TextStyle(color: Colors.purple),
    'symbol': const TextStyle(color: AppTheme.operator),
    'operator': const TextStyle(color: AppTheme.operator),
  };

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode);
    _scrollController = ScrollController();
    _lineNumberScrollController = ScrollController();
    _updateLineCount();
    _controller.addListener(_updateLineCount);
    
    // Sync scroll
    _scrollController.addListener(() {
      if (_lineNumberScrollController.hasClients) {
        _lineNumberScrollController.jumpTo(_scrollController.offset);
      }
    });
  }
  
  void _updateLineCount() {
    final lines = '\n'.allMatches(_controller.text).length + 1;
    if (lines != _lineCount) {
      setState(() => _lineCount = lines);
    }
    widget.onCodeChanged?.call(_controller.text);
  }

  @override
  void didUpdateWidget(CodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCode != oldWidget.initialCode && widget.initialCode != _controller.text) {
      _controller.text = widget.initialCode;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateLineCount);
    _controller.dispose();
    _scrollController.dispose();
    _lineNumberScrollController.dispose();
    super.dispose();
  }
  
  List<TextSpan> _highlightCode(String code, String language) {
    try {
      final result = highlight.parse(code, language: language);
      return _convertNodes(result.nodes ?? []);
    } catch (e) {
      return [TextSpan(text: code)];
    }
  }
  
  List<TextSpan> _convertNodes(List<dynamic> nodes) {
    List<TextSpan> spans = [];
    for (var node in nodes) {
      if (node.value != null) {
        spans.add(TextSpan(text: node.value, style: _theme[node.className]));
      } else if (node.children != null) {
        spans.addAll(_convertNodes(node.children));
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.editorBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line numbers
          Container(
            width: 50,
            color: AppTheme.editorBg,
            child: ListView.builder(
              controller: _lineNumberScrollController,
              itemCount: _lineCount,
              itemBuilder: (context, index) {
                return Container(
                  height: 24,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppTheme.lineNumber,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              },
            ),
          ),
          // Editor
          Expanded(
            child: Stack(
              children: [
                // Syntax highlighting layer
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.firaCode(
                          fontSize: 14,
                          height: 1.71,
                        ),
                        children: _highlightCode(_controller.text, widget.language),
                      ),
                    ),
                  ),
                ),
                // Editable text field (transparent)
                TextField(
                  controller: _controller,
                  scrollController: _scrollController,
                  maxLines: null,
                  expands: true,
                  style: GoogleFonts.firaCode(
                    fontSize: 14,
                    height: 1.71,
                    color: Colors.transparent,
                  ),
                  cursorColor: AppTheme.cursor,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  onChanged: (_) => _updateLineCount(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditorPanel extends StatefulWidget {
  final String? filePath;
  final String? initialContent;
  final Function(String)? onContentChanged;
  final VoidCallback? onSave;
  final VoidCallback? onRun;
  
  const EditorPanel({
    super.key,
    this.filePath,
    this.initialContent,
    this.onContentChanged,
    this.onSave,
    this.onRun,
  });
  
  @override
  State<EditorPanel> createState() => _EditorPanelState();
}

class _EditorPanelState extends State<EditorPanel> {
  late TextEditingController _controller;
  bool _hasUnsavedChanges = false;
  
  String get _language {
    if (widget.filePath == null) return 'go';
    final ext = widget.filePath!.split('.').last.toLowerCase();
    final langMap = {
      'go': 'go',
      'py': 'python',
      'js': 'javascript',
      'ts': 'typescript',
      'java': 'java',
      'c': 'c',
      'cpp': 'cpp',
      'h': 'c',
      'rs': 'rust',
      'rb': 'ruby',
      'php': 'php',
      'swift': 'swift',
      'kt': 'kotlin',
      'dart': 'dart',
      'html': 'xml',
      'css': 'css',
      'json': 'json',
      'yaml': 'yaml',
      'md': 'markdown',
    };
    return langMap[ext] ?? 'plaintext';
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent ?? '');
    _controller.addListener(() {
      setState(() => _hasUnsavedChanges = true);
      widget.onContentChanged?.call(_controller.text);
    });
  }

  @override
  void didUpdateWidget(EditorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filePath != oldWidget.filePath || widget.initialContent != oldWidget.initialContent) {
      _controller.text = widget.initialContent ?? '';
      _hasUnsavedChanges = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        Container(
          height: 40,
          color: AppTheme.sidebarBg,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow, size: 20),
                onPressed: widget.onRun,
                tooltip: 'Run',
                color: Colors.green,
              ),
              IconButton(
                icon: const Icon(Icons.save, size: 20),
                onPressed: _hasUnsavedChanges ? widget.onSave : null,
                tooltip: 'Save',
              ),
              const SizedBox(width: 8),
              Text(
                widget.filePath?.split('/').last ?? 'untitled',
                style: TextStyle(
                  color: _hasUnsavedChanges ? Colors.orange : Colors.white,
                ),
              ),
              if (_hasUnsavedChanges) const Text(' *', style: TextStyle(color: Colors.orange)),
              const Spacer(),
              Text(
                _language.toUpperCase(),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        // Editor
        Expanded(
          child: _controller.text.isEmpty
              ? const Center(
                  child: Text(
                    'Open a file from the explorer',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : CodeEditor(
                  initialCode: _controller.text,
                  language: _language,
                  onCodeChanged: widget.onContentChanged,
                ),
        ),
      ],
    );
  }
}
