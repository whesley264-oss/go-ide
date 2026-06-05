import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';
import '../themes/app_theme.dart';

class TerminalPanel extends StatefulWidget {
  const TerminalPanel({super.key});

  @override
  State<TerminalPanel> createState() => _TerminalPanelState();
}

class _TerminalPanelState extends State<TerminalPanel> {
  late Terminal _terminal;
  late TerminalController _terminalController;

  @override
  void initState() {
    super.initState();
    _terminal = Terminal(maxLines: 10000);
    _terminalController = TerminalController();
    _terminal.write('Terminal ready. Use Run button to execute code.\r\n');
    _terminal.write('\x1b[32m$\x1b[0m ');
  }

  void writeOutput(String text) {
    _terminal.write(text);
    _terminal.write('\r\n\x1b[32m$\x1b[0m ');
  }

  void writeError(String text) {
    _terminal.write('\x1b[31m$text\x1b[0m\r\n\x1b[32m$\x1b[0m ');
  }

  void clear() {
    _terminal.buffer.clear();
    _terminal.write('Terminal cleared.\r\n\x1b[32m$\x1b[0m ');
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
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TerminalView(
                _terminal,
                controller: _terminalController,
                textStyle: const TerminalStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
