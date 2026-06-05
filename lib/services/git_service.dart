import 'dart:io';

class GitRepo {
  final String name;
  final String path;
  final String? remoteUrl;
  final String branch;
  final bool hasChanges;

  GitRepo({required this.name, required this.path, this.remoteUrl, required this.branch, this.hasChanges = false});

  factory GitRepo.fromPath(String path) {
    return GitRepo(
      name: path.split('/').last,
      path: path,
      branch: 'main',
    );
  }
}

class GitService {
  Future<String> runGit(List<String> args, {String? cwd}) async {
    try {
      final result = await Process.run(
        'git',
        args,
        workingDirectory: cwd ?? Directory.current.path,
        stdoutEncoding: SystemEncoding().decoder,
        stderrEncoding: SystemEncoding().decoder,
      );
      if (result.exitCode != 0) {
        return 'Error: ${result.stderr}';
      }
      return result.stdout as String;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<bool> isGitInstalled() async {
    try {
      final result = await Process.run('git', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isGitRepo(String path) async {
    final result = await runGit(['rev-parse', '--is-inside-work-tree'], cwd: path);
    return result.trim() == 'true';
  }

  Future<String> getStatus(String repoPath) async {
    return await runGit(['status', '--porcelain'], cwd: repoPath);
  }

  Future<String> getBranches(String repoPath) async {
    return await runGit(['branch', '-a'], cwd: repoPath);
  }

  Future<String> getCurrentBranch(String repoPath) async {
    return await runGit(['rev-parse', '--abbrev-ref', 'HEAD'], cwd: repoPath);
  }

  Future<String> getStagedFiles(String repoPath) async {
    return await runGit(['diff', '--cached', '--name-only'], cwd: repoPath);
  }

  Future<String> getModifiedFiles(String repoPath) async {
    return await runGit(['diff', '--name-only'], cwd: repoPath);
  }

  Future<String> getUntrackedFiles(String repoPath) async {
    return await runGit(['ls-files', '--others', '--exclude-standard'], cwd: repoPath);
  }

  Future<String> stageFile(String repoPath, String filePath) async {
    return await runGit(['add', filePath], cwd: repoPath);
  }

  Future<String> stageAll(String repoPath) async {
    return await runGit(['add', '-A'], cwd: repoPath);
  }

  Future<String> unstageFile(String repoPath, String filePath) async {
    return await runGit(['reset', 'HEAD', '--', filePath], cwd: repoPath);
  }

  Future<String> commit(String repoPath, String message) async {
    return await runGit(['commit', '-m', message], cwd: repoPath);
  }

  Future<String> push(String repoPath, {String? remote, String? branch}) async {
    final args = ['push'];
    if (remote != null) args.add(remote);
    if (branch != null) args.add(branch);
    return await runGit(args, cwd: repoPath);
  }

  Future<String> pull(String repoPath, {String? remote, String? branch}) async {
    final args = ['pull'];
    if (remote != null) args.add(remote);
    if (branch != null) args.add(branch);
    return await runGit(args, cwd: repoPath);
  }

  Future<String> fetch(String repoPath, {String? remote}) async {
    final args = ['fetch'];
    if (remote != null) args.add(remote);
    return await runGit(args, cwd: repoPath);
  }

  Future<String> checkout(String repoPath, String branch) async {
    return await runGit(['checkout', branch], cwd: repoPath);
  }

  Future<String> createBranch(String repoPath, String branchName, {bool checkout = true}) async {
    if (checkout) {
      return await runGit(['checkout', '-b', branchName], cwd: repoPath);
    }
    return await runGit(['branch', branchName], cwd: repoPath);
  }

  Future<String> cloneRepo(String url, String targetPath) async {
    return await runGit(['clone', url, targetPath]);
  }

  Future<String> getRemoteUrl(String repoPath) async {
    return await runGit(['remote', 'get-url', 'origin'], cwd: repoPath);
  }

  Future<String> getLog(String repoPath, {int limit = 10}) async {
    return await runGit(['log', '--oneline', '-n', '$limit'], cwd: repoPath);
  }
}
