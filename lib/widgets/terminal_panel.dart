import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class TerminalWidget extends StatefulWidget {
  const TerminalWidget({super.key});

  @override
  State<TerminalWidget> createState() => TerminalWidgetState();
}

class TerminalWidgetState extends State<TerminalWidget> {
  String _buffer = '';
  final ScrollController _scrollController = ScrollController();
  
  void write(String text) {
    setState(() => _buffer += text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void clear() {
    setState(() => _buffer = '');
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
          Container(
            height: 32,
            color: AppTheme.panelBg,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Text(
                  'TERMINAL',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16),
                  onPressed: clear,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              child: Text(
                _buffer.isEmpty ? 'Terminal ready.\n> ' : _buffer,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
