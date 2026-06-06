import 'package:flutter/material.dart';
import '../theme.dart';

class CodeEditor extends StatefulWidget {
  final VoidCallback? onRun;
  const CodeEditor({super.key, this.onRun});

  @override
  State<CodeEditor> createState() => CodeEditorState();
}

class CodeEditorState extends State<CodeEditor> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _lineCount = 1;

  String getCode() => _controller.text;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateLineCount);
    _controller.text = 'package main\n\nimport "fmt"\n\nfunc main() {\n\tfmt.Println("Hello, World!")\n}\n';
  }

  void _updateLineCount() {
    final count = '\n'.allMatches(_controller.text).length + 1;
    if (count != _lineCount) setState(() => _lineCount = count);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            color: AppTheme.surface,
            child: Column(
              children: List.generate(_lineCount, (i) => Container(
                height: 22,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontFamily: 'monospace'),
                ),
              )),
            ),
          ),
          Container(width: 1, color: AppTheme.border),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontSize: 14, fontFamily: 'monospace', height: 1.57, color: AppTheme.textPrimary),
              cursorColor: AppTheme.accent,
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(8)),
            ),
          ),
        ],
      ),
    );
  }
}
