import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/sidebar.dart';
import '../widgets/editor.dart';
import '../widgets/terminal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedSidebarItem = 0;
  bool _showTerminal = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedSidebarItem,
            onItemSelected: (index) => setState(() => _selectedSidebarItem = index),
          ),
          Container(width: 1, color: AppTheme.border),
          Expanded(
            child: Column(
              children: [
                _buildEditorBar(),
                Expanded(child: const Editor()),
                if (_showTerminal) const Terminal(),
                _buildStatusBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorBar() {
    return Container(
      height: 40,
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Text('Editor', style: TextStyle(color: AppTheme.textPrimary)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.play_arrow, size: 20, color: AppTheme.success),
            onPressed: () => setState(() => _showTerminal = true),
            tooltip: 'Run',
          ),
          IconButton(
            icon: Icon(_showTerminal ? Icons.terminal : Icons.terminal_outlined, size: 20),
            onPressed: () => setState(() => _showTerminal = !_showTerminal),
            tooltip: 'Terminal',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 24,
      color: AppTheme.accent,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: const Row(
        children: [
          Text('Ready', style: TextStyle(color: Colors.white, fontSize: 12)),
          Spacer(),
          Text('UTF-8', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
