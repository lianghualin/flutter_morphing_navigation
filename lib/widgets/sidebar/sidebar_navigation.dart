import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_theme.dart';
import 'sidebar_header.dart';
import 'sidebar_item.dart';
import 'sidebar_section.dart';

class SidebarNavigation extends StatefulWidget {
  const SidebarNavigation({super.key});

  @override
  State<SidebarNavigation> createState() => _SidebarNavigationState();
}

class _SidebarNavigationState extends State<SidebarNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;

  // Track the previous mode to detect changes
  bool? _previousIsSidebarMode;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.modeTransitionDuration,
      vsync: this,
    );

    // Width animation: runs throughout the full duration
    _widthAnimation = Tween<double>(
      begin: 0.0,
      end: AppTheme.sidebarWidth,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppTheme.modeTransitionCurve,
    ));

    // Opacity animation with different intervals for open/close
    // This will be updated dynamically based on direction
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut), // Default: fade in late
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateAnimations(bool isSidebarMode) {
    if (_previousIsSidebarMode == isSidebarMode) return;

    if (isSidebarMode) {
      // Opening sidebar: fade in late (after width expands enough)
      // Interval(0.7, 1.0) means: opacity stays 0 from 0.0→0.7, then fades in from 0.7→1.0
      // At controller=0.7, width is ~234px which is enough space
      _opacityAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ));
      _controller.forward();
    } else {
      // Closing sidebar: fade out early (before width shrinks too much)
      // Interval(0.7, 1.0) during REVERSE means: opacity fades from 1.0→0.0
      // as controller goes 1.0→0.7 (first 30% of animation), then stays 0
      _opacityAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ));
      _controller.reverse();
    }

    _previousIsSidebarMode = isSidebarMode;
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();

    // Initialize on first build
    if (_previousIsSidebarMode == null) {
      _previousIsSidebarMode = navProvider.isSidebarMode;
      if (navProvider.isSidebarMode) {
        _controller.value = 1.0;
      }
    } else {
      _updateAnimations(navProvider.isSidebarMode);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: SizedBox(
              width: AppTheme.sidebarWidth,
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
          ),
        );
      },
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
