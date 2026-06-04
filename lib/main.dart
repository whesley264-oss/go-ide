import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'git_panel.dart';

void main() => runApp(const GoIDE());

class GoIDE extends StatelessWidget {
  const GoIDE({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _showGit = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go IDE Nativo'),
        actions: [
          IconButton(
            icon: Icon(_showGit ? Icons.folder_open : Icons.call_split),
            onPressed: () => setState(() => _showGit = !_showGit),
          )
        ],
      ),
      body: Row(
        children: [
          if (_showGit)
            Container(
              width: 250,
              decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade800))),
              child: const GitPanel(),
            ),
          Expanded(child: EditorArea()),
        ],
      ),
    );
  }
}

class EditorArea extends StatefulWidget {
  @override
  State<EditorArea> createState() => _EditorAreaState();
}

class _EditorAreaState extends State<EditorArea> {
  final _codeController = CodeController(text: 'package main\n\nfunc main() {\n  println("Hello!")\n}');

  @override
  Widget build(BuildContext context) {
    return CodeField(controller: _codeController);
  }
}
