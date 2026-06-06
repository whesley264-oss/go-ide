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
  Future<ExecutionResult> runGo(String code) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Create temp file
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/temp_go_${DateTime.now().millisecondsSinceEpoch}.go');
      await file.writeAsString(code);
      
      // Run go run
      final result = await Process.run(
        'go', ['run', file.path],
        workingDirectory: tempDir.path,
      );
      
      // Clean up
      await file.delete();
      
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
        output: 'Error: $e\n\nMake sure Go is installed on your device.',
        duration: stopwatch.elapsed,
      );
    }
  }
}
