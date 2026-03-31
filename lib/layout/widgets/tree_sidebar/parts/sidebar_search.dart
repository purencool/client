import 'package:flutter/material.dart';

class SidebarSearch extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onExpandAll;
  final VoidCallback onCollapseAll;
  final String hintText;

  const SidebarSearch({
    super.key,
    required this.controller,
    required this.onExpandAll,
    required this.onCollapseAll,
    this.hintText = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      // 1. Wrap in SingleChildScrollView to allow clipping during animation
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: SizedBox(
          // 2. Set a fixed width that matches your "expanded" sidebar state
          width: 250, 
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: hintText,
                      prefixIcon: const Icon(Icons.search, size: 16),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.05),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _SidebarAction(
                icon: Icons.unfold_more,
                tooltip: "Expand All",
                onPressed: onExpandAll,
              ),
              _SidebarAction(
                icon: Icons.unfold_less,
                tooltip: "Collapse All",
                onPressed: onCollapseAll,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _SidebarAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
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
