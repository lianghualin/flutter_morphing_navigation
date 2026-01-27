import 'package:flutter/material.dart';
import '../../models/nav_item.dart';
import '../../theme/app_theme.dart';
import '../common/nav_icon.dart';

class SidebarItem extends StatefulWidget {
  final NavItem item;
  final bool isChild;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.isChild = false,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
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
          margin: EdgeInsets.only(
            left: widget.isChild ? 32 : 12,
            right: 12,
            bottom: 4,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? AppTheme.activeItemGradient : null,
            color: widget.isSelected
                ? null
                : (_isHovered ? AppTheme.sidebarItemHover : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              NavIcon(
                icon: widget.item.icon,
                color: widget.item.iconColor,
                isActive: widget.isSelected,
                size: widget.isChild ? 18 : 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: widget.isChild ? 14 : 15,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: widget.isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ),
              if (widget.item.badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppTheme.primaryRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.item.badge!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
