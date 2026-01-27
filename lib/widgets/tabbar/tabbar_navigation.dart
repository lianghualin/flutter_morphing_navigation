import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_theme.dart';
import '../common/glassmorphism_container.dart';
import 'tabbar_item.dart';
import 'tabbar_section.dart';

class TabBarNavigation extends StatelessWidget {
  const TabBarNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final isBottom = navProvider.tabBarPosition == TabBarPosition.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    return Positioned(
      top: isBottom ? null : 16,
      bottom: isBottom ? 24 : null,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: AppTheme.modeTransitionDuration,
        opacity: navProvider.isTabBarMode ? 1.0 : 0.0,
        child: AnimatedSlide(
          duration: AppTheme.modeTransitionDuration,
          curve: AppTheme.modeTransitionCurve,
          offset: navProvider.isTabBarMode
              ? Offset.zero
              : Offset(0, isBottom ? 1 : -1),
          child: Center(
            child: GlassmorphismContainer(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 8 : 12,
                vertical: isCompact ? 6 : 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildNavItems(navProvider, isCompact),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems(NavigationProvider navProvider, bool isCompact) {
    final widgets = <Widget>[];

    for (int i = 0; i < navProvider.items.length; i++) {
      final item = navProvider.items[i];

      if (item.hasChildren) {
        widgets.add(TabBarSection(section: item, compact: isCompact));
      } else {
        widgets.add(TabBarItem(item: item, compact: isCompact));
      }

      // Add divider between items (except for the last item)
      if (i < navProvider.items.length - 1) {
        widgets.add(
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: AppTheme.sidebarBorder.withValues(alpha: 0.5),
          ),
        );
      }
    }

    // Add toggle button at the end
    widgets.add(
      Container(
        width: 1,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: AppTheme.sidebarBorder.withValues(alpha: 0.5),
      ),
    );
    widgets.add(_ToggleButton(isCompact: isCompact));

    return widgets;
  }
}

class _ToggleButton extends StatefulWidget {
  final bool isCompact;

  const _ToggleButton({required this.isCompact});

  @override
  State<_ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<_ToggleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          context.read<NavigationProvider>().toggleMode();
        },
        child: AnimatedContainer(
          duration: AppTheme.hoverDuration,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCompact ? 12 : 16,
            vertical: widget.isCompact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color:
                _isHovered ? Colors.black.withValues(alpha: 0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.view_sidebar_rounded,
                size: widget.isCompact ? 20 : 24,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                'Expand',
                style: TextStyle(
                  fontSize: widget.isCompact ? 10 : 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
