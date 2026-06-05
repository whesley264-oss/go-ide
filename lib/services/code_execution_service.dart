import 'dart:io';
import 'dart:async';

class ExecutionResult {
  final int exitCode;
  final String stdout;
  final String stderr;
  final Duration duration;

  ExecutionResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.duration,
  });

  String get output => stdout.isNotEmpty ? stdout : stderr;
}

class CodeExecutionService {
  Process? _currentProcess;
  
  String detectLanguage(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'go':
        return 'go';
      case 'py':
        return 'python';
      case 'js':
        return 'node';
      case 'ts':
        return 'ts-node';
      case 'java':
        return 'java';
      case 'c':
        return 'gcc';
      case 'cpp':
      case 'cc':
      case 'cxx':
        return 'g++';
      case 'rb':
        return 'ruby';
      case 'php':
        return 'php';
      case 'swift':
        return 'swift';
      case 'kt':
        return 'kotlin';
      case 'sh':
      case 'bash':
      case 'zsh':
        return 'bash';
      default:
        return 'unknown';
    }
  }
  
  List<String> getRunCommand(String language, String filePath) {
    switch (language) {
      case 'go':
        return ['go', 'run', filePath];
      case 'python':
        return ['python3', filePath];
      case 'node':
        return ['node', filePath];
      case 'ts-node':
        return ['npx', 'ts-node', filePath];
      case 'java':
        return ['java', filePath];
      case 'gcc':
        return ['gcc', filePath, '-o', '/tmp/a.out']; // Need compilation first
      case 'g++':
        return ['g++', filePath, '-o', '/tmp/a.out'];
      case 'ruby':
        return ['ruby', filePath];
      case 'php':
        return ['php', filePath];
      case 'swift':
        return ['swift', filePath];
      case 'kotlin':
        return ['kotlin', filePath];
      case 'bash':
      case 'sh':
        return ['bash', filePath];
      default:
        return ['echo', 'Unknown file type: $language'];
    }
  }
  
  Future<ExecutionResult> execute(
    String filePath, {
    List<String> args = const [],
    String? workingDirectory,
    Function(String)? onOutput,
  }) async {
    final stopwatch = Stopwatch()..start();
    final language = detectLanguage(filePath);
    
    List<String> command;
    if (language == 'gcc' || language == 'g++') {
      // Two-step: compile then run
      final compileCmd = getRunCommand(language, filePath);
      final compileResult = await Process.run(
        compileCmd.first,
        compileCmd.sublist(1),
        workingDirectory: workingDirectory,
      );
      
      if (compileResult.exitCode != 0) {
        stopwatch.stop();
        return ExecutionResult(
          exitCode: compileResult.exitCode,
          stdout: compileResult.stdout as String,
          stderr: compileResult.stderr as String,
          duration: stopwatch.elapsed,
        );
      }
      
      command = ['/tmp/a.out'];
    } else {
      command = getRunCommand(language, filePath);
    }
    
    command.addAll(args);
    
    try {
      _currentProcess = await Process.start(
        command.first,
        command.sublist(1),
        workingDirectory: workingDirectory,
      );
      
      final stdoutBuffer = StringBuffer();
      final stderrBuffer = StringBuffer();
      
      _currentProcess!.stdout.transform(const SystemEncoding().decoder).listen((data) {
        stdoutBuffer.write(data);
        onOutput?.call(data);
      });
      
      _currentProcess!.stderr.transform(const SystemEncoding().decoder).listen((data) {
        stderrBuffer.write(data);
        onOutput?.call(data);
      });
      
      final exitCode = await _currentProcess!.exitCode;
      stopwatch.stop();
      
      return ExecutionResult(
        exitCode: exitCode,
        stdout: stdoutBuffer.toString(),
        stderr: stderrBuffer.toString(),
        duration: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return ExecutionResult(
        exitCode: 1,
        stdout: '',
        stderr: e.toString(),
        duration: stopwatch.elapsed,
      );
    } finally {
      _currentProcess = null;
    }
  }
  
  void kill() {
    _currentProcess?.kill();
    _currentProcess = null;
  }
  
  bool get isRunning => _currentProcess != null;
}
