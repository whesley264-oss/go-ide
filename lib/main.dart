import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const ProIDE());

class ProIDE extends StatelessWidget {
  const ProIDE({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        textTheme: GoogleFonts.firaCodeTextTheme(ThemeData.dark().textTheme),
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 200,
            color: const Color(0xFF252526),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('EXPLORER', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                Expanded(child: ListView(children: const [ListTile(leading: Icon(Icons.description), title: Text('main.go'))])),
              ],
            ),
          ),
          // Editor
          Expanded(
            child: CodeField(
              controller: CodeController(text: 'package main\n\nfunc main() {\n  println("Pro IDE Mobile!")\n}'),
            ),
          ),
        ],
      ),
    );
  }
}
