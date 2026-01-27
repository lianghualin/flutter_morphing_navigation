import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/nav_item.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_theme.dart';

class TabBarSection extends StatefulWidget {
  final NavItem section;
  final bool compact;
  final bool hasSelectedChild;
  final NavItem? selectedChild;
  final VoidCallback? onChildSelected;

  const TabBarSection({
    super.key,
    required this.section,
    required this.hasSelectedChild,
    this.selectedChild,
    this.compact = false,
    this.onChildSelected,
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
    final isBottom = navProvider.tabBarPosition == TabBarPosition.bottom;

    showDialog<String>(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Stack(
          children: [
            // Invisible barrier to detect taps outside
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(dialogContext).pop(),
              ),
            ),
            Positioned(
              left: offset.dx,
              top: isBottom
                  ? offset.dy - (widget.section.children!.length * 56 + 16)
                  : offset.dy + size.height + 8,
              child: Material(
                color: Colors.transparent,
                child: Consumer<NavigationProvider>(
                  builder: (context, provider, _) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.dropdownShadow,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: widget.section.children!.map((child) {
                            final isSelected = provider.isItemSelected(child.id);
                            return _DropdownItem(
                              item: child,
                              isSelected: isSelected,
                              onTap: () {
                                Navigator.of(dialogContext).pop();
                                provider.selectItem(child.id);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use selected child's icon/label if available, otherwise use section's
    final displayItem = widget.selectedChild ?? widget.section;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        key: _buttonKey,
        behavior: HitTestBehavior.opaque,
        onTap: _showDropdown,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 12 : 16,
            vertical: widget.compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            gradient: widget.hasSelectedChild ? AppTheme.activeItemGradient : null,
            color: widget.hasSelectedChild
                ? null
                : (_isHovered ? Colors.black.withValues(alpha: 0.05) : Colors.transparent),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    displayItem.icon,
                    size: widget.compact ? 20 : 24,
                    color: widget.hasSelectedChild
                        ? Colors.white
                        : (displayItem.iconColor ?? AppTheme.textSecondary),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 16,
                    color: widget.hasSelectedChild
                        ? Colors.white
                        : AppTheme.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                displayItem.label,
                style: TextStyle(
                  fontSize: widget.compact ? 10 : 11,
                  fontWeight:
                      widget.hasSelectedChild ? FontWeight.w600 : FontWeight.w500,
                  color:
                      widget.hasSelectedChild ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownItem extends StatefulWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DropdownItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_DropdownItem> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<_DropdownItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.hoverDuration,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                : (_isHovered ? Colors.grey.withValues(alpha: 0.1) : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                size: 20,
                color: widget.isSelected
                    ? AppTheme.primaryBlue
                    : (widget.item.iconColor ?? AppTheme.textSecondary),
              ),
              const SizedBox(width: 12),
              Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
