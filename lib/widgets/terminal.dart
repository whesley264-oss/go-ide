import 'package:flutter/material.dart';
import '../theme.dart';

class Terminal extends StatelessWidget {
  const Terminal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: const Color(0xFF0C0C0C),
      child: Column(
        children: [
          Container(
            height: 32,
            color: AppTheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Row(
              children: [
                Icon(Icons.terminal, size: 14, color: AppTheme.textSecondary),
                SizedBox(width: 4),
                Text('TERMINAL', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Terminal output will appear here',
                style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'monospace'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
