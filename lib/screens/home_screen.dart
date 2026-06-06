import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/editor.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with Run button only
            Container(
              height: 48,
              color: AppTheme.surface,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Text(
                    'Go Editor',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Run'),
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
            // Editor
            const Expanded(child: CodeEditor()),
          ],
        ),
      ),
    );
  }
}
