import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/nav_item.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_theme.dart';

class TabBarSection extends StatefulWidget {
  final NavItem section;
  final bool compact;

  const TabBarSection({
    super.key,
    required this.section,
    this.compact = false,
  });

  @override
  State<TabBarSection> createState() => _TabBarSectionState();
}

class _TabBarSectionState extends State<TabBarSection> {
  bool _isHovered = false;
  final GlobalKey _buttonKey = GlobalKey();

  void _showDropdown() {
    final RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final navProvider = context.read<NavigationProvider>();
    final isBottom =
        navProvider.tabBarPosition == TabBarPosition.bottom;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        isBottom ? offset.dy - (widget.section.children!.length * 48 + 16) : offset.dy + size.height + 8,
        offset.dx + size.width,
        0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      elevation: 8,
      items: widget.section.children!.map((child) {
        final isSelected = navProvider.isItemSelected(child.id);
        return PopupMenuItem<String>(
          value: child.id,
          child: Row(
            children: [
              Icon(
                child.icon,
                size: 20,
                color: isSelected
                    ? AppTheme.primaryBlue
                    : (child.iconColor ?? AppTheme.textSecondary),
              ),
              const SizedBox(width: 12),
              Text(
                child.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        navProvider.selectItem(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final hasSelectedChild = navProvider.hasSelectedChild(widget.section.id);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        key: _buttonKey,
        onTap: _showDropdown,
        child: AnimatedContainer(
          duration: AppTheme.hoverDuration,
          curve: AppTheme.dropdownCurve,
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 12 : 16,
            vertical: widget.compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            gradient: hasSelectedChild ? AppTheme.activeItemGradient : null,
            color: !hasSelectedChild && _isHovered
                ? Colors.black.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.section.icon,
                    size: widget.compact ? 20 : 24,
                    color: hasSelectedChild
                        ? Colors.white
                        : (widget.section.iconColor ?? AppTheme.textSecondary),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 16,
                    color: hasSelectedChild
                        ? Colors.white
                        : AppTheme.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.section.label,
                style: TextStyle(
                  fontSize: widget.compact ? 10 : 11,
                  fontWeight:
                      hasSelectedChild ? FontWeight.w600 : FontWeight.w500,
                  color:
                      hasSelectedChild ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
