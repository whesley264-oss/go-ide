import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class GitConfig {
  String platform = 'github'; // github, gitlab, bitbucket
  String username = '';
  String token = '';
  String repoUrl = '';
  bool isConfigured = false;
}

class GitPanelWidget extends StatefulWidget {
  final String? repoPath;
  
  const GitPanelWidget({super.key, this.repoPath});

  @override
  State<GitPanelWidget> createState() => _GitPanelWidgetState();
}

class _GitPanelWidgetState extends State<GitPanelWidget> {
  final GitConfig _config = GitConfig();
  bool _showSettings = false;
  String _currentBranch = 'main';
  List<String> _changes = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadChanges();
  }

  Future<void> _loadChanges() async {
    // Simulate loading changes
    setState(() {
      _changes = ['main.dart', 'pubspec.yaml'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.sidebarBg,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _showSettings ? _buildSettings() : _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'GIT',
              style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 16),
            onPressed: () => setState(() => _showSettings = !_showSettings),
            color: Colors.grey,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // Branch info
        _buildSection('BRANCH', [
          _buildBranchSelector(),
        ]),
        const SizedBox(height: 16),
        
        // Changes
        _buildSection('CHANGES (${_changes.length})', [
          if (_changes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('No changes', style: TextStyle(color: Colors.grey, fontSize: 12)),
            )
          else
            ..._changes.map((f) => _buildChangeItem(f)),
        ]),
        const SizedBox(height: 16),
        
        // Actions
        _buildSection('ACTIONS', [
          _buildActionButton('Pull', Icons.arrow_downward, Colors.blue, _pull),
          const SizedBox(height: 4),
          _buildActionButton('Push', Icons.arrow_upward, Colors.green, _push),
          const SizedBox(height: 4),
          _buildActionButton('Commit', Icons.check_circle, Colors.purple, _commit),
          const SizedBox(height: 4),
          _buildActionButton('Fetch', Icons.sync, Colors.orange, _fetch),
        ]),
        const SizedBox(height: 16),
        
        // Remote info
        if (_config.isConfigured)
          _buildSection('REMOTE', [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                _config.repoUrl.isNotEmpty ? _config.repoUrl : 'Not configured',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
      ],
    );
  }

  Widget _buildBranchSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_tree, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _currentBranch,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildChangeItem(String file) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              file,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        const Text('GIT SETTINGS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        // Platform selector
        const Text('Platform', style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        _buildPlatformSelector(),
        const SizedBox(height: 16),
        
        // Username
        const Text('Username', style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'your-username',
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          onChanged: (v) => _config.username = v,
        ),
        const SizedBox(height: 12),
        
        // Token
        const Text('Access Token', style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          obscureText: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'ghp_xxx or glpat-xxx',
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          onChanged: (v) => _config.token = v,
        ),
        const SizedBox(height: 12),
        
        // Repo URL
        const Text('Repository URL', style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'https://github.com/user/repo',
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          onChanged: (v) => _config.repoUrl = v,
        ),
        const SizedBox(height: 16),
        
        // Save button
        ElevatedButton(
          onPressed: () {
            setState(() {
              _config.isConfigured = _config.token.isNotEmpty;
              _showSettings = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Git configuration saved')),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Save Configuration'),
        ),
      ],
    );
  }

  Widget _buildPlatformSelector() {
    return Row(
      children: [
        _buildPlatformChip('GitHub', _config.platform == 'github', () => setState(() => _config.platform = 'github')),
        const SizedBox(width: 8),
        _buildPlatformChip('GitLab', _config.platform == 'gitlab', () => setState(() => _config.platform = 'gitlab')),
        const SizedBox(width: 8),
        _buildPlatformChip('Bitbucket', _config.platform == 'bitbucket', () => setState(() => _config.platform = 'bitbucket')),
      ],
    );
  }

  Widget _buildPlatformChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.withOpacity(0.3) : Colors.white10,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: selected ? Colors.blue : Colors.transparent),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.blue : Colors.grey, fontSize: 11)),
      ),
    );
  }

  void _pull() {
    if (!_config.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configure Git settings first')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pull completed')),
    );
  }

  void _push() {
    if (!_config.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configure Git settings first')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Push completed')),
    );
  }

  void _commit() {
    if (!_config.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configure Git settings first')),
      );
      return;
    }
    _showCommitDialog();
  }

  void _fetch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fetch completed')),
    );
  }

  void _showCommitDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panelBg,
        title: const Text('Commit'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Commit message...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Commit created')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Commit'),
          ),
        ],
      ),
    );
  }
}
