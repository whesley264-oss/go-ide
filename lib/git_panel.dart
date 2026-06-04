import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GitPanel extends StatefulWidget {
  const GitPanel({super.key});

  @override
  State<GitPanel> createState() => _GitPanelState();
}

class _GitPanelState extends State<GitPanel> {
  final _shell = Shell();
  String _status = '';
  final _messageController = TextEditingController();

  Future<void> _updateStatus() async {
    final result = await _shell.run('git status -s');
    setState(() => _status = result.outText);
  }

  Future<void> _commit() async {
    await _shell.run('git add .');
    await _shell.run('git commit -m "${_messageController.text}"');
    _messageController.clear();
    _updateStatus();
  }

  @override
  void initState() {
    super.initState();
    _updateStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Text('Status:\n$_status')),
        TextField(controller: _messageController, decoration: const InputDecoration(hintText: 'Commit message')),
        ElevatedButton(onPressed: _commit, child: const Text('Commit')),
      ],
    );
  }
}
