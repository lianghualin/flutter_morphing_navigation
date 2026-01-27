import 'package:flutter/material.dart';
import '../../models/nav_item.dart';
import '../../theme/app_theme.dart';

class TabBarItem extends StatefulWidget {
  final NavItem item;
  final bool compact;
  final bool isSelected;
  final VoidCallback onTap;

  const TabBarItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
  });

  @override
  State<TabBarItem> createState() => _TabBarItemState();
}

class _TabBarItemState extends State<TabBarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 12 : 16,
            vertical: widget.compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? AppTheme.activeItemGradient : null,
            color: widget.isSelected
                ? null
                : (_isHovered ? Colors.black.withValues(alpha: 0.05) : Colors.transparent),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.item.icon,
                size: widget.compact ? 20 : 24,
                color: widget.isSelected
                    ? Colors.white
                    : (widget.item.iconColor ?? AppTheme.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: widget.compact ? 10 : 11,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
              // Badge
              if (widget.item.badge != null) ...[
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppTheme.primaryRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.item.badge!,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
