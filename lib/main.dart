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

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Go IDE Nativo')),
      body: Row(
        children: [
          const Expanded(flex: 1, child: GitPanel()),
          Expanded(flex: 3, child: EditorArea()),
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
