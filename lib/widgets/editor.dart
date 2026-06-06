import 'package:flutter/material.dart';
import '../theme.dart';

class CodeEditor extends StatefulWidget {
  const CodeEditor({super.key});

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _lineCount = 1;

  final List<_Token> _keywords = [
    'package', 'import', 'func', 'var', 'const', 'type', 'struct', 'interface',
    'if', 'else', 'for', 'range', 'switch', 'case', 'default', 'return',
    'break', 'continue', 'go', 'defer', 'select', 'chan', 'map', 'make', 'new',
    'true', 'false', 'nil', 'iota', 'fallthrough',
  ];

  final List<_Token> _types = [
    'int', 'int8', 'int16', 'int32', 'int64', 'uint', 'uint8', 'uint16', 'uint32', 'uint64',
    'float32', 'float64', 'complex64', 'complex128', 'bool', 'byte', 'rune', 'string', 'error',
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateLineCount);
  }

  void _updateLineCount() {
    final count = '\n'.allMatches(_controller.text).length + 1;
    if (count != _lineCount) setState(() => _lineCount = count);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line numbers
          Container(
            width: 50,
            color: AppTheme.surface,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _lineCount,
              itemBuilder: (context, i) => Container(
                height: 22,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
          // Divider
          Container(width: 1, color: AppTheme.border),
          // Code area
          Expanded(
            child: Stack(
              children: [
                // Syntax highlighted view
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'monospace',
                          height: 1.57,
                        ),
                        children: _highlightCode(_controller.text),
                      ),
                    ),
                  ),
                ),
                // Editable text field (invisible text)
                TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    height: 1.57,
                    color: Colors.transparent,
                  ),
                  cursorColor: AppTheme.accent,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _highlightCode(String code) {
    if (code.isEmpty) return [const TextSpan(text: '')];
    
    final spans = <TextSpan>[];
    final buffer = StringBuffer();
    int i = 0;

    while (i < code.length) {
      final char = code[i];

      // Comments
      if (char == '/' && i + 1 < code.length && code[i + 1] == '/') {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString(), style: const TextStyle(color: AppTheme.textPrimary)));
          buffer.clear();
        }
        final end = code.indexOf('\n', i);
        final endIndex = end == -1 ? code.length : end;
        spans.add(TextSpan(text: code.substring(i, endIndex), style: const TextStyle(color: AppTheme.textSecondary)));
        i = endIndex;
        continue;
      }

      // Strings
      if (char == '"' || char == '\'' || char == '`') {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString(), style: const TextStyle(color: AppTheme.textPrimary)));
          buffer.clear();
        }
        final quote = char;
        int j = i + 1;
        while (j < code.length && code[j] != quote) {
          if (code[j] == '\\' && j + 1 < code.length) j++;
          j++;
        }
        spans.add(TextSpan(text: code.substring(i, j + 1), style: const TextStyle(color: AppTheme.accentOrange)));
        i = j + 1;
        continue;
      }

      // Numbers
      if (RegExp(r'[0-9]').hasMatch(char) && buffer.isEmpty) {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString(), style: const TextStyle(color: AppTheme.textPrimary)));
          buffer.clear();
        }
        int j = i;
        while (j < code.length && RegExp(r'[0-9.]').hasMatch(code[j])) j++;
        spans.add(TextSpan(text: code.substring(i, j), style: const TextStyle(color: AppTheme.accentBlue)));
        i = j;
        continue;
      }

      // Words (keywords, types, identifiers)
      if (RegExp(r'[a-zA-Z_]').hasMatch(char)) {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString(), style: const TextStyle(color: AppTheme.textPrimary)));
          buffer.clear();
        }
        int j = i;
        while (j < code.length && RegExp(r'[a-zA-Z0-9_]').hasMatch(code[j])) j++;
        final word = code.substring(i, j);

        if (_keywords.contains(word)) {
          spans.add(TextSpan(text: word, style: const TextStyle(color: AppTheme.accentBlue)));
        } else if (_types.contains(word)) {
          spans.add(TextSpan(text: word, style: const TextStyle(color: AppTheme.accentGreen)));
        } else if (word[0].toUpperCase() == word[0]) {
          spans.add(TextSpan(text: word, style: const TextStyle(color: AppTheme.accentYellow)));
        } else {
          spans.add(TextSpan(text: word, style: const TextStyle(color: AppTheme.textPrimary)));
        }
        i = j;
        continue;
      }

      buffer.write(char);
      i++;
    }

    if (buffer.isNotEmpty) {
      spans.add(TextSpan(text: buffer.toString(), style: const TextStyle(color: AppTheme.textPrimary)));
    }

    return spans;
  }
}

class _Token {
  final String text;
  final Color color;
  _Token(this.text, this.color);
}
