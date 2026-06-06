import 'dart:io';

class ExecutionResult {
  final int exitCode;
  final String output;
  final Duration duration;

  ExecutionResult({
    required this.exitCode,
    required this.output,
    required this.duration,
  });
}

class Executor {
  // Common Termux and Android Go paths
  static const List<String> _goPaths = [
    '/data/data/com.termux/files/usr/bin/go',
    '/data/data/com.termux/files/home/go/bin/go',
    '/data/data/com.termux/files/usr/local/go/bin/go',
    '/data/data/com.termux/home/go/bin/go',
    '/system/usr/bin/go',
    '/system/xbin/go',
    '/vendor/bin/go',
  ];

  String? _cachedPath;

  Future<String?> _findGo() async {
    if (_cachedPath != null) return _cachedPath;

    // Try PATH first
    try {
      final whichResult = await Process.run('which', ['go']);
      if (whichResult.exitCode == 0) {
        final path = whichResult.stdout.toString().trim();
        if (path.isNotEmpty && path != '/') {
          _cachedPath = path;
          return _cachedPath;
        }
      }
    } catch (_) {}

    // Try common paths
    for (final path in _goPaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          // Test if executable
          final result = await Process.run(path, ['version']);
          if (result.exitCode == 0) {
            _cachedPath = path;
            return _cachedPath;
          }
        }
      } catch (_) {}
    }

    // Try /system/bin and /system/xbin
    final systemPaths = ['/system/bin/go', '/system/xbin/go', '/system/xbin:/system/bin'];
    for (final sp in systemPaths) {
      try {
        final result = await Process.run(sp, ['version']);
        if (result.exitCode == 0) {
          _cachedPath = sp;
          return _cachedPath;
        }
      } catch (_) {}
    }

    return null;
  }

  Future<ExecutionResult> runGo(String code) async {
    final stopwatch = Stopwatch()..start();

    // Find Go
    final goPath = await _findGo();

    if (goPath == null) {
      stopwatch.stop();
      return ExecutionResult(
        exitCode: 1,
        output: '''Go not found!

Make sure Go is installed:
- Termux: pkg install golang
- Or ensure Go is in your PATH

The app will search in:
${_goPaths.join('\n')}''',
        duration: stopwatch.elapsed,
      );
    }

    try {
      // Create temp file in app's private directory
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
      );
    } catch (e) {
      stopwatch.stop();
      return ExecutionResult(
        exitCode: 1,
        output: 'Failed to execute Go:\n$e',
        duration: stopwatch.elapsed,
      );
    }
  }
}
