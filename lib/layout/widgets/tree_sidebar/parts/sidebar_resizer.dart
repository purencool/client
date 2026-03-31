import 'package:flutter/material.dart';

class SidebarResizer extends StatelessWidget {
  final Function(DragUpdateDetails) onDrag;

  const SidebarResizer({super.key, required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: onDrag,
        child: Container(
          height: 24.0,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Center(
            child: Icon(
              Icons.drag_indicator,
              size: 16,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}
