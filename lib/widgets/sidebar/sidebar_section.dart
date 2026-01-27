import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/nav_item.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_theme.dart';
import '../common/nav_icon.dart';
import 'sidebar_item.dart';

class SidebarSection extends StatefulWidget {
  final NavItem section;

  const SidebarSection({
    super.key,
    required this.section,
  });

  @override
  State<SidebarSection> createState() => _SidebarSectionState();
}

class _SidebarSectionState extends State<SidebarSection>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, _) {
        final isExpanded = navProvider.isSectionExpanded(widget.section.id);
        final hasSelectedChild = navProvider.hasSelectedChild(widget.section.id);
        final selectedItemId = navProvider.selectedItemId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section header
            MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  navProvider.toggleSection(widget.section.id);
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? AppTheme.sidebarItemHover
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      NavIcon(
                        icon: widget.section.icon,
                        color: widget.section.iconColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.section.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: hasSelectedChild
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: hasSelectedChild
                                ? AppTheme.primaryBlue
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0,
                        duration: AppTheme.accordionDuration,
                        curve: AppTheme.accordionCurve,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Expandable children
            AnimatedCrossFade(
              duration: AppTheme.accordionDuration,
              crossFadeState:
                  isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Column(
                children: widget.section.children!.map((child) {
                  return SidebarItem(
                    key: ValueKey('${child.id}_$selectedItemId'),
                    item: child,
                    isChild: true,
                    isSelected: selectedItemId == child.id,
                    onTap: () => navProvider.selectItem(child.id),
                  );
                }).toList(),
              ),
              secondChild: const SizedBox.shrink(),
              sizeCurve: AppTheme.accordionCurve,
            ),
          ],
        );
      },
    );
  }
}
