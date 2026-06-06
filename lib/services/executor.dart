import 'dart:io';

class ExecutionResult {
  final int exitCode;
  final String output;
  final Duration duration;
  final String compiler;

  ExecutionResult({
    required this.exitCode,
    required this.output,
    required this.duration,
    this.compiler = 'unknown',
  });
}

class Executor {
  // Common Go paths (Termux and others)
  static const List<String> _goPaths = [
    '/data/data/com.termux/files/usr/bin/go',
    '/data/data/com.termux/files/home/go/bin/go',
    '/usr/bin/go',
    '/usr/local/go/bin/go',
    'go', // PATH
  ];

  String? _foundGoPath;

  Future<String?> _findGo() async {
    if (_foundGoPath != null) return _foundGoPath;

    for (final path in _goPaths) {
      try {
        final file = File(path);
        final dir = Directory(path);
        
        if (path == 'go') {
          // Check if 'go' is in PATH
          final result = await Process.run('which', ['go']);
          if (result.exitCode == 0) {
            _foundGoPath = result.stdout.toString().trim();
            return _foundGoPath;
          }
        } else if (await file.exists() || await dir.exists()) {
          // Test if go works
          final result = await Process.run(path, ['version']);
          if (result.exitCode == 0) {
            _foundGoPath = path;
            return _foundGoPath;
          }
        }
      } catch (_) {}
    }
    return null;
  }

  Future<ExecutionResult> runGo(String code) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Try to find Go
      final goPath = await _findGo();
      
      if (goPath == null) {
        stopwatch.stop();
        return ExecutionResult(
          exitCode: 1,
          output: '''Go not found!

To run Go code, install Termux from F-Droid:
https://f-droid.org/packages/com.termux/

Then install Go in Termux:
pkg install golang

The app will automatically detect Go in Termux.''',
          duration: stopwatch.elapsed,
          compiler: 'not found',
        );
      }

      // Create temp file
      final tempDir = Directory.systemTemp;
      final fileName = 'go_ide_${DateTime.now().millisecondsSinceEpoch}.go';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(code);

      // Run go run
      final result = await Process.run(
        goPath,
        ['run', file.path],
        workingDirectory: tempDir.path,
      );

      // Clean up
      try { await file.delete(); } catch (_) {}

      stopwatch.stop();

      return ExecutionResult(
        exitCode: result.exitCode,
        output: '${result.stdout}${result.stderr}'.trim(),
        duration: stopwatch.elapsed,
        compiler: goPath,
      );
    } catch (e) {
      stopwatch.stop();
      return ExecutionResult(
        exitCode: 1,
        output: 'Error: $e',
        duration: stopwatch.elapsed,
      );
    }
  }
}
