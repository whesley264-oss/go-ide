import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../services/git_service.dart';

class GitPanel extends StatefulWidget {
  final String? repoPath;
  const GitPanel({super.key, this.repoPath});

  @override
  State<GitPanel> createState() => _GitPanelState();
}

class _GitPanelState extends State<GitPanel> {
  final GitService _git = GitService();
  
  String _branch = '';
  List<String> _branches = [];
  List<String> _staged = [];
  List<String> _modified = [];
  List<String> _untracked = [];
  String _log = '';
  bool _loading = true;
  String? _remoteUrl;

  @override
  void initState() {
    super.initState();
    _loadGitInfo();
  }

  Future<void> _loadGitInfo() async {
    if (widget.repoPath == null) {
      setState(() => _loading = false);
      return;
    }
    
    setState(() => _loading = true);
    try {
      final isRepo = await _git.isGitRepo(widget.repoPath!);
      if (!isRepo) {
        setState(() => _loading = false);
        return;
      }

      _branch = (await _git.getCurrentBranch(widget.repoPath!)).trim();
      _remoteUrl = (await _git.getRemoteUrl(widget.repoPath!)).trim();
      
      final branchesRaw = await _git.getBranches(widget.repoPath!);
      _branches = branchesRaw.split('\n').where((b) => b.isNotEmpty).toList();
      
      final stagedRaw = await _git.getStagedFiles(widget.repoPath!);
      _staged = stagedRaw.split('\n').where((f) => f.isNotEmpty).toList();
      
      final modifiedRaw = await _git.getModifiedFiles(widget.repoPath!);
      _modified = modifiedRaw.split('\n').where((f) => f.isNotEmpty).toList();
      
      final untrackedRaw = await _git.getUntrackedFiles(widget.repoPath!);
      _untracked = untrackedRaw.split('\n').where((f) => f.isNotEmpty).toList();
      
      _log = await _git.getLog(widget.repoPath!);
    } catch (e) {
      // Git not available or error
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.sidebarBg,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : widget.repoPath == null
                    ? _buildNotARepo()
                    : _buildGitContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
      child: Row(
        children: [
          const Icon(Icons.merge_type, size: 16, color: Colors.orange),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _branch.isEmpty ? 'GIT' : _branch,
              style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          IconButton(icon: const Icon(Icons.refresh, size: 16), onPressed: _loadGitInfo, padding: EdgeInsets.zero, constraints: const BoxConstraints(), color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildNotARepo() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.source, size: 48, color: Colors.white24),
          SizedBox(height: 8),
          Text('Not a Git repository', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 4),
          Text('Initialize with: git init', style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildGitContent() {
    final hasChanges = _staged.isNotEmpty || _modified.isNotEmpty || _untracked.isNotEmpty;
    
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // Branch selector
        _buildSection('BRANCHES', _branches.map((b) {
          final isCurrent = b.contains('*');
          final name = b.replaceAll('*', '').trim();
          return _buildListTile(
            Icons.account_tree,
            name,
            isCurrent ? Colors.green : Colors.white70,
            onTap: isCurrent ? null : () => _checkout(name),
          );
        }).toList()),
        
        const SizedBox(height: 8),
        
        // Staged
        if (_staged.isNotEmpty)
          _buildSection('STAGED (${_staged.length})', _staged.map((f) => _buildFileTile(f, Colors.green, Icons.add)).toList()),
        
        // Modified
        if (_modified.isNotEmpty)
          _buildSection('MODIFIED (${_modified.length})', _modified.map((f) => _buildFileTile(f, Colors.orange, Icons.edit)).toList()),
        
        // Untracked
        if (_untracked.isNotEmpty)
          _buildSection('UNTRACKED (${_untracked.length})', _untracked.map((f) => _buildFileTile(f, Colors.grey, Icons.help_outline)).toList()),
        
        // Commit button
        if (hasChanges) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Commit'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: _showCommitDialog,
          ),
        ],
        
        // Remote info
        if (_remoteUrl != null && _remoteUrl!.isNotEmpty && !_remoteUrl!.startsWith('Error')) ...[
          const SizedBox(height: 16),
          _buildSection('REMOTE', [
            _buildListTile(Icons.cloud, _remoteUrl!, Colors.blue, onTap: null),
          ]),
        ],
        
        // Push/Pull buttons
        if (_remoteUrl != null && !_remoteUrl!.startsWith('Error')) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.arrow_downward), label: const Text('Pull'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), onPressed: _pull)),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.arrow_upward), label: const Text('Push'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: _push)),
            ],
          ),
        ],
        
        // Commit log
        if (_log.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('COMMIT HISTORY', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...(_log.split('\n').where((l) => l.isNotEmpty).take(10).map((line) {
            final parts = line.split(' ');
            final hash = parts.isNotEmpty ? parts[0] : '';
            final msg = parts.length > 1 ? parts.sublist(1).join(' ') : '';
            return _buildListTile(Icons.commit, '$hash $msg', Colors.white54, onTap: null);
          })),
        ],
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        ...children,
      ],
    );
  }

  Widget _buildListTile(IconData icon, String text, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 12), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTile(String file, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(file, style: TextStyle(color: color, fontSize: 11), overflow: TextOverflow.ellipsis),
        ),
        TextButton(
          onPressed: () async {
            if (icon == Icons.help_outline) {
              await _git.stageFile(widget.repoPath!, file);
              _loadGitInfo();
            } else if (icon == Icons.edit) {
              await _git.stageFile(widget.repoPath!, file);
              _loadGitInfo();
            }
          },
          style: TextButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 4)),
          child: Text(icon == Icons.help_outline ? 'Add' : 'Stage', style: const TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  Future<void> _checkout(String branch) async {
    if (widget.repoPath == null) return;
    final result = await _git.checkout(widget.repoPath!, branch);
    if (result.startsWith('Error')) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    }
    _loadGitInfo();
  }

  Future<void> _pull() async {
    if (widget.repoPath == null) return;
    final result = await _git.pull(widget.repoPath!);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.startsWith('Error') ? result : 'Pull completed')));
    _loadGitInfo();
  }

  Future<void> _push() async {
    if (widget.repoPath == null) return;
    final result = await _git.push(widget.repoPath!);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.startsWith('Error') ? result : 'Push completed')));
    _loadGitInfo();
  }

  void _showCommitDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panelBg,
        title: const Text('Commit Changes'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Commit message...', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (controller.text.isEmpty) return;
              // Stage all first
              await _git.stageAll(widget.repoPath!);
              final result = await _git.commit(widget.repoPath!, controller.text);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.startsWith('Error') ? result : 'Committed!')));
              _loadGitInfo();
            },
            child: const Text('Commit'),
          ),
        ],
      ),
    );
  }
}
