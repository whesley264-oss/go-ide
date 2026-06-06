import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class GitPanel extends StatelessWidget {
  final String? repoPath;

  const GitPanel({super.key, this.repoPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.sidebarBg,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: repoPath == null
                ? _buildNoRepo()
                : _buildGitInfo(context),
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
      child: const Row(
        children: [
          Icon(Icons.account_tree, size: 16, color: Colors.orange),
          SizedBox(width: 4),
          Text(
            'GIT',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRepo() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.source, size: 48, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'No Git Repository',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Open a folder that contains a .git folder to use Git features',
              style: TextStyle(color: Colors.white38, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGitInfo(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildSection(
          'INFO',
          [
            _buildInfoRow('Path', repoPath!.split('/').last),
            _buildInfoRow('Status', 'Ready'),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          'ACTIONS',
          [
            _buildActionButton(
              context,
              icon: Icons.sync,
              label: 'Pull',
              color: Colors.blue,
              onTap: () => _showMessage(context, 'Pull: Git command executed'),
            ),
            _buildActionButton(
              context,
              icon: Icons.cloud_upload,
              label: 'Push',
              color: Colors.green,
              onTap: () => _showMessage(context, 'Push: Git command executed'),
            ),
            _buildActionButton(
              context,
              icon: Icons.check_circle,
              label: 'Commit',
              color: Colors.purple,
              onTap: () => _showCommitDialog(context),
            ),
            _buildActionButton(
              context,
              icon: Icons.refresh,
              label: 'Fetch',
              color: Colors.orange,
              onTap: () => _showMessage(context, 'Fetch: Git command executed'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          'BRANCH',
          [
            _buildBranchItem('main', true),
            _buildBranchItem('develop', false),
            _buildBranchItem('feature/xyz', false),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(color: color, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranchItem(String name, bool isCurrent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isCurrent ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: isCurrent ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              color: isCurrent ? Colors.green : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showCommitDialog(BuildContext context) {
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
          decoration: const InputDecoration(
            hintText: 'Enter commit message...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Commit created (demo)')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Commit'),
          ),
        ],
      ),
    );
  }
}
