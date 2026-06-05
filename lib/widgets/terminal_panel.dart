import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_theme.dart';

class TerminalWidget extends StatefulWidget {
  const TerminalWidget({super.key});

  @override
  State<TerminalWidget> createState() => TerminalWidgetState();
}

class TerminalWidgetState extends State<TerminalWidget> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _lines = [];
  bool _autoScroll = true;

  void write(String text) {
    if (text.isEmpty) return;
    setState(() {
      // Split by newlines and add each line
      final parts = text.split('\n');
      for (final part in parts) {
        if (part.isNotEmpty) {
          _lines.add(part);
        }
      }
      // Keep only last 1000 lines to prevent memory issues
      if (_lines.length > 1000) {
        _lines.removeRange(0, _lines.length - 1000);
      }
    });
    // Auto-scroll to bottom
    if (_autoScroll && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void clear() {
    setState(() => _lines.clear());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0C0C0C),
      child: Column(
        children: [
          // Header
          Container(
            height: 32,
            color: AppTheme.panelBg,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(Icons.terminal, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                const Text('OUTPUT', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const Spacer(),
                // Auto-scroll toggle
                GestureDetector(
                  onTap: () => setState(() => _autoScroll = !_autoScroll),
                  child: Icon(_autoScroll ? Icons.vertical_align_bottom : Icons.vertical_align_top, size: 16, color: _autoScroll ? Colors.green : Colors.grey),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: clear,
                  child: const Icon(Icons.delete_outline, size: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Output area
          Expanded(
            child: _lines.isEmpty
                ? const Center(child: Text('Output will appear here when you run code', style: TextStyle(color: Colors.white38, fontSize: 12)))
                : GestureDetector(
                    onTapDown: (_) => setState(() => _autoScroll = false),
                    onTapUp: (_) => setState(() => _autoScroll = true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: _lines.length,
                      itemBuilder: (context, index) {
                        final line = _lines[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: SelectableText(
                            line,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: _getLineColor(line),
                              height: 1.4,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getLineColor(String line) {
    if (line.contains('Error') || line.contains('error') || line.contains('FAILURE')) {
      return Colors.red.shade300;
    }
    if (line.contains('Done') || line.contains('success') || line.contains('Success')) {
      return Colors.green.shade300;
    }
    if (line.startsWith('Running') || line.contains('>')) {
      return Colors.cyan.shade300;
    }
    if (line.contains('Warning') || line.contains('warning')) {
      return Colors.orange.shade300;
    }
    return Colors.white70;
  }
}
