import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_theme.dart';
import 'sidebar_header.dart';
import 'sidebar_item.dart';
import 'sidebar_section.dart';

class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();

    return AnimatedContainer(
      duration: AppTheme.modeTransitionDuration,
      curve: AppTheme.modeTransitionCurve,
      width: navProvider.isSidebarMode ? AppTheme.sidebarWidth : 0,
      child: AnimatedOpacity(
        duration: AppTheme.modeTransitionDuration,
        opacity: navProvider.isSidebarMode ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.sidebarBackground,
            border: Border(
              right: BorderSide(
                color: AppTheme.sidebarBorder,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              const SidebarHeader(),
              const Divider(height: 1, color: AppTheme.sidebarBorder),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildNavItems(navProvider),
                  ),
                ),
              ),
              const Divider(height: 1, color: AppTheme.sidebarBorder),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems(NavigationProvider navProvider) {
    final widgets = <Widget>[];
    final selectedItemId = navProvider.selectedItemId;

    for (final item in navProvider.items) {
      if (item.hasChildren) {
        widgets.add(SidebarSection(
          key: ValueKey(item.id),
          section: item,
        ));
      } else {
        widgets.add(SidebarItem(
          key: ValueKey('${item.id}_$selectedItemId'),
          item: item,
          isSelected: selectedItemId == item.id,
          onTap: () => navProvider.selectItem(item.id),
        ));
      }
    }

    return widgets;
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                'JD',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'john@example.com',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
