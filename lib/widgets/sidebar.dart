import 'package:flutter/material.dart';
import '../theme.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      color: AppTheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildIcon(Icons.folder_outlined, 0, 'Explorer'),
          _buildIcon(Icons.account_tree_outlined, 1, 'Git'),
          _buildIcon(Icons.search, 2, 'Search'),
          const Spacer(),
          _buildIcon(Icons.settings_outlined, 3, 'Settings'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index, String tooltip) {
    final isSelected = selectedIndex == index;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => onItemSelected(index),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
