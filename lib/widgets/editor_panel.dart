import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/highlight.dart' show highlight;
import '../themes/app_theme.dart';

class CodeEditor extends StatefulWidget {
  final String initialCode;
  final String language;
  final Function(String)? onCodeChanged;
  
  const CodeEditor({
    super.key,
    this.initialCode = '',
    this.language = 'plaintext',
    this.onCodeChanged,
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
    'root': TextStyle(color: Colors.white, backgroundColor: AppTheme.editorBg, fontFamily: 'monospace', fontSize: 14),
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
    _controller.addListener(_onTextChanged);
    
    _scrollController.addListener(() {
      if (_lineNumberScrollController.hasClients) {
        _lineNumberScrollController.jumpTo(_scrollController.offset);
      }
    });
  }
  
  void _onTextChanged() {
    _updateLineCount();
    widget.onCodeChanged?.call(_controller.text);
  }

  void _updateLineCount() {
    final lines = '\n'.allMatches(_controller.text).length + 1;
    if (lines != _lineCount) {
      setState(() => _lineCount = lines);
    }
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
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    _lineNumberScrollController.dispose();
    super.dispose();
  }
  
  List<TextSpan> _highlightCode(String code, String language) {
    if (code.isEmpty) return [const TextSpan(text: '')];
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
            width: 48,
            color: AppTheme.editorBg,
            child: ListView.builder(
              controller: _lineNumberScrollController,
              itemCount: _lineCount,
              itemBuilder: (context, index) {
                return Container(
                  height: 22,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: AppTheme.lineNumber, fontSize: 13, fontFamily: 'monospace'),
                  ),
                );
              },
            ),
          ),
          // Vertical divider
          Container(width: 1, color: Colors.white10),
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
                        style: GoogleFonts.firaCode(fontSize: 13, height: 1.69),
                        children: _highlightCode(_controller.text, widget.language),
                      ),
                    ),
                  ),
                ),
                // Editable text field (transparent text)
                Positioned.fill(
                  child: TextField(
                    controller: _controller,
                    scrollController: _scrollController,
                    maxLines: null,
                    expands: true,
                    style: GoogleFonts.firaCode(
                      fontSize: 13,
                      height: 1.69,
                      color: Colors.transparent,
                    ),
                    cursorColor: AppTheme.cursor,
                    cursorWidth: 2,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(8),
                      isDense: true,
                    ),
                  ),
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
    if (widget.filePath == null) return 'plaintext';
    final ext = widget.filePath!.split('.').last.toLowerCase();
    final langMap = {
      'go': 'go', 'py': 'python', 'js': 'javascript', 'ts': 'typescript',
      'java': 'java', 'c': 'c', 'cpp': 'cpp', 'h': 'c',
      'rs': 'rust', 'rb': 'ruby', 'php': 'php', 'swift': 'swift',
      'kt': 'kotlin', 'dart': 'dart', 'html': 'xml', 'css': 'css',
      'json': 'json', 'yaml': 'yaml', 'md': 'markdown',
    };
    return langMap[ext] ?? 'plaintext';
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent ?? '');
    _controller.addListener(() {
      if (!_hasUnsavedChanges && _controller.text != (widget.initialContent ?? '')) {
        setState(() => _hasUnsavedChanges = true);
      }
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
                icon: Icon(_hasUnsavedChanges ? Icons.save : Icons.save_outlined, size: 20),
                onPressed: _hasUnsavedChanges ? widget.onSave : null,
                tooltip: 'Save',
                color: _hasUnsavedChanges ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                widget.filePath?.split('/').last ?? 'untitled',
                style: TextStyle(
                  fontSize: 13,
                  color: _hasUnsavedChanges ? Colors.orange : Colors.white,
                ),
              ),
              if (_hasUnsavedChanges) const Text(' *', style: TextStyle(color: Colors.orange)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _language.toUpperCase(),
                  style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        // Editor
        Expanded(
          child: _controller.text.isEmpty
              ? _buildEmptyState()
              : CodeEditor(
                  initialCode: _controller.text,
                  language: _language,
                  onCodeChanged: widget.onContentChanged,
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: AppTheme.editorBg,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.code, size: 64, color: Colors.white12),
            SizedBox(height: 16),
            Text(
              'Open a file to start editing',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Tap on a file in the Explorer panel',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
