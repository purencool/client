import 'package:flutter/material.dart';

class SidebarHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final VoidCallback? onNewFolder;
  final VoidCallback? onNewFile;
  final VoidCallback? onOpenDirectory;

  const SidebarHeader({
    super.key,
    this.title = "EXPLORER",
    required this.onClose,
    this.onNewFolder,
    this.onNewFile,
    this.onOpenDirectory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: SizedBox(
          width: 250, // Ensures the Row has enough space during animation
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
              ),
              if (onOpenDirectory != null)
                _SidebarAction(
                  icon: Icons.folder_open,
                  tooltip: "Open Directory",
                  onPressed: onOpenDirectory,
                ),
              if (onNewFolder != null)
                _SidebarAction(
                  icon: Icons.create_new_folder,
                  tooltip: "New Folder",
                  onPressed: onNewFolder,
                ),
              if (onNewFile != null)
                _SidebarAction(
                  icon: Icons.note_add,
                  tooltip: "New File",
                  onPressed: onNewFile,
                ),
              _SidebarAction(
                icon: Icons.menu_open,
                tooltip: "Close Sidebar",
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Internal helper for header buttons
class _SidebarAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _SidebarAction({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(6),
      splashRadius: 18,
    );
  }
}
