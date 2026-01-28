import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/nav_item.dart';
import '../../providers/navigation_provider.dart' as nav;
import '../../theme/app_theme.dart';
import 'morphing_nav_item.dart';

/// MorphingNavigation is the main orchestrator widget that handles the
/// continuous morphing animation between sidebar and tab bar navigation.
///
/// Key features:
/// - Single AnimationController where t=0 is sidebar, t=1 is tabbar
/// - Uses LayoutBuilder to compute positions based on screen size
/// - Renders a Stack with positioned children that interpolate positions
class MorphingNavigation extends StatefulWidget {
  const MorphingNavigation({super.key});

  @override
  State<MorphingNavigation> createState() => _MorphingNavigationState();
}

class _MorphingNavigationState extends State<MorphingNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  nav.NavigationMode? _previousMode;


  // Sidebar layout constants
  static const double _sidebarWidth = AppTheme.sidebarWidth;
  static const double _headerHeight = 80.0; // padding(20) * 2 + content(40)
  static const double _itemHeight = 46.0;
  static const double _itemSpacing = 4.0;
  static const double _horizontalMargin = 12.0;
  static const double _footerHeight = 80.0;

  // TabBar layout constants
  static const double _tabBarHeight = AppTheme.tabBarHeight;
  static const double _tabBarTopMargin = 16.0;
  static const double _tabBarBottomMargin = 24.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.modeTransitionDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize controller value on first build
    if (_previousMode == null) {
      final navProvider = context.read<nav.NavigationProvider>();
      _previousMode = navProvider.mode;
      // Set initial value without animation
      if (navProvider.isTabBarMode) {
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Calculate the width of the tab bar based on number of items
  double _calculateTabBarWidth(List<NavItem> items, bool compact) {
    // Count top-level items only (sections + regular items)
    final itemCount = items.length;
    final itemWidth = compact ? 56.0 : 72.0;
    final toggleWidth = compact ? 48.0 : 56.0;
    final dividerCount = itemCount; // dividers between items + before toggle
    final dividerWidth = 1.0;
    final horizontalPadding = compact ? 8.0 : 12.0;

    return (itemCount * itemWidth) +
        toggleWidth +
        (dividerCount * dividerWidth) +
        (horizontalPadding * 2);
  }

  /// Get the sidebar container rect
  Rect _getSidebarContainerRect(Size screenSize) {
    return Rect.fromLTWH(0, 0, _sidebarWidth, screenSize.height);
  }

  /// Get the tab bar container rect
  Rect _getTabBarContainerRect(Size screenSize, List<NavItem> items, bool compact, bool isBottom) {
    final tabBarWidth = _calculateTabBarWidth(items, compact);
    final left = (screenSize.width - tabBarWidth) / 2;
    final top = isBottom
        ? screenSize.height - _tabBarHeight - _tabBarBottomMargin
        : _tabBarTopMargin;

    return Rect.fromLTWH(left, top, tabBarWidth, _tabBarHeight);
  }

  /// Get sidebar item rect for a given visual index
  /// The index represents the visual position in the sidebar list
  Rect _getSidebarItemRect(int visualIndex, Size screenSize, {bool isChild = false}) {
    final top = _headerHeight + 12 + visualIndex * (_itemHeight + _itemSpacing);
    final left = isChild ? 32.0 : _horizontalMargin;
    final width = _sidebarWidth - left - _horizontalMargin;

    return Rect.fromLTWH(left, top, width, _itemHeight);
  }

  /// Get tab bar item rect for a given index
  Rect _getTabBarItemRect(
    int index,
    Size screenSize,
    List<NavItem> items,
    bool compact,
    bool isBottom,
  ) {
    final containerRect = _getTabBarContainerRect(screenSize, items, compact, isBottom);
    final itemWidth = compact ? 56.0 : 72.0;
    final horizontalPadding = compact ? 8.0 : 12.0;
    final verticalPadding = 8.0;

    // Calculate horizontal position within container
    // Account for dividers (1px each)
    final left = containerRect.left + horizontalPadding + index * (itemWidth + 1);
    final top = containerRect.top + verticalPadding;
    final height = containerRect.height - verticalPadding * 2;

    return Rect.fromLTWH(left, top, itemWidth, height);
  }

  /// Build the morphing container (background that transforms from sidebar to tab bar)
  Widget _buildMorphingContainer(
    Size screenSize,
    double t,
    List<NavItem> items,
    bool compact,
    bool isBottom,
  ) {
    final sidebarRect = _getSidebarContainerRect(screenSize);
    final tabBarRect = _getTabBarContainerRect(screenSize, items, compact, isBottom);

    final rect = Rect.lerp(sidebarRect, tabBarRect, t)!;
    final borderRadius = lerpDouble(16, 32, t)!;
    final blur = lerpDouble(0, AppTheme.glassBlur, t)!;

    // Background color transitions from solid white to glassmorphism
    final backgroundColor = Color.lerp(
      Colors.white,
      AppTheme.glassBackground,
      t,
    )!;

    // Border color transitions
    final borderColor = Color.lerp(
      AppTheme.sidebarBorder,
      AppTheme.glassBorder,
      t,
    )!;

    // Shadow opacity increases with t
    final shadowOpacity = lerpDouble(0, 0.1, t)!;

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: t > 0.1
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: shadowOpacity),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          // Sidebar mode: right border only
          border: t < 0.5
              ? Border(
                  right: BorderSide(
                    color: Color.lerp(
                      AppTheme.sidebarBorder,
                      Colors.transparent,
                      t * 2,
                    )!,
                    width: 1,
                  ),
                )
              : Border.all(color: borderColor, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  /// Build the header (logo + title) that fades out during transition
  Widget _buildHeader(double t, Size screenSize, nav.NavigationProvider navProvider) {
    // Fade out in first 30% of transition
    final opacity = (1.0 - t * 3.33).clamp(0.0, 1.0);
    if (opacity <= 0) return const SizedBox.shrink();

    final width = lerpDouble(_sidebarWidth, 0, t)!;

    return Positioned(
      top: 0,
      left: 0,
      width: width,
      height: _headerHeight,
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Title - use Column with reduced spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'Navigation Demo',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Toggle button in header
              _HeaderToggleButton(onTap: navProvider.toggleMode),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the divider below header
  Widget _buildHeaderDivider(double t, Size screenSize) {
    final opacity = (1.0 - t * 3.33).clamp(0.0, 1.0);
    if (opacity <= 0) return const SizedBox.shrink();

    return Positioned(
      top: _headerHeight,
      left: 16,
      width: _sidebarWidth - 32,
      child: Opacity(
        opacity: opacity,
        child: Container(
          height: 1,
          color: AppTheme.sidebarBorder,
        ),
      ),
    );
  }

  /// Build the footer (user info) that fades out during transition
  Widget _buildFooter(double t, Size screenSize) {
    // Fade out in first 30% of transition
    final opacity = (1.0 - t * 3.33).clamp(0.0, 1.0);
    if (opacity <= 0) return const SizedBox.shrink();

    final width = lerpDouble(_sidebarWidth, 0, t)!;

    return Positioned(
      bottom: 0,
      left: 0,
      width: width,
      height: _footerHeight,
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppTheme.sidebarBorder,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
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
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
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
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the toggle button
  Widget _buildToggleButton(
    double t,
    Size screenSize,
    List<NavItem> items,
    bool compact,
    bool isBottom,
    nav.NavigationProvider navProvider,
  ) {
    // In sidebar mode (t=0): hidden (header has its own toggle)
    // In tabbar mode (t=1): show at end of items
    // During transition: appears and moves to tabbar position

    // Only show this toggle when t > 0.1 (after header starts fading)
    if (t <= 0.1) return const SizedBox.shrink();

    // Sidebar start position matches header toggle position
    // Header has padding: all(20), and toggle is 32x32
    final sidebarRect = Rect.fromLTWH(
      _sidebarWidth - 20 - 32, // header right padding - button width
      20, // header top padding
      32,
      32,
    );

    final tabBarRect = _getTabBarContainerRect(screenSize, items, compact, isBottom);
    final toggleWidth = compact ? 48.0 : 56.0;
    final itemWidth = compact ? 56.0 : 72.0;
    final horizontalPadding = compact ? 8.0 : 12.0;
    final verticalPadding = 8.0;

    final tabBarToggleRect = Rect.fromLTWH(
      tabBarRect.left + horizontalPadding + items.length * (itemWidth + 1),
      tabBarRect.top + verticalPadding,
      toggleWidth,
      tabBarRect.height - verticalPadding * 2,
    );

    // Remap t from [0.1, 1.0] to [0.0, 1.0] for smooth interpolation
    final remappedT = ((t - 0.1) / 0.9).clamp(0.0, 1.0);
    final rect = Rect.lerp(sidebarRect, tabBarToggleRect, remappedT)!;

    // Icon transitions - sidebar icon fades out, then tabbar icon fades in
    final sidebarIconOpacity = (1.0 - remappedT * 2).clamp(0.0, 1.0);
    final tabBarIconOpacity = ((remappedT - 0.5) * 2).clamp(0.0, 1.0);

    // Overall opacity fades in as header fades out
    final overallOpacity = ((t - 0.1) * 5).clamp(0.0, 1.0); // fully visible by t=0.3

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Opacity(
        opacity: overallOpacity,
        child: _ToggleButton(
          sidebarIcon: Icons.keyboard_double_arrow_left_rounded,
          tabBarIcon: Icons.keyboard_double_arrow_right_rounded,
          sidebarIconOpacity: sidebarIconOpacity,
          tabBarIconOpacity: tabBarIconOpacity,
          onTap: navProvider.toggleMode,
          compact: compact,
          t: remappedT,
        ),
      ),
    );
  }

  /// Build dividers between items in tab bar mode
  List<Widget> _buildTabBarDividers(
    double t,
    Size screenSize,
    List<NavItem> items,
    bool compact,
    bool isBottom,
  ) {
    if (t < 0.5) return [];

    final dividerOpacity = ((t - 0.5) * 2).clamp(0.0, 1.0);
    final containerRect = _getTabBarContainerRect(screenSize, items, compact, isBottom);
    final itemWidth = compact ? 56.0 : 72.0;
    final horizontalPadding = compact ? 8.0 : 12.0;
    final verticalPadding = 12.0;

    final dividers = <Widget>[];

    for (int i = 0; i <= items.length; i++) {
      final left = containerRect.left + horizontalPadding + i * (itemWidth + 1) - 1;

      dividers.add(
        Positioned(
          left: left,
          top: containerRect.top + verticalPadding,
          width: 1,
          height: containerRect.height - verticalPadding * 2,
          child: Opacity(
            opacity: dividerOpacity * 0.15,
            child: Container(
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    return dividers;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<nav.NavigationProvider>(
      builder: (context, navProvider, _) {
        // Animate when mode changes
        if (_previousMode != navProvider.mode) {
          if (navProvider.isTabBarMode) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
          _previousMode = navProvider.mode;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenSize = constraints.biggest;
            final items = navProvider.items;
            final compact = screenSize.width < 600;
            final isBottom = navProvider.tabBarPosition == nav.TabBarPosition.bottom;

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = AppTheme.modeTransitionCurve.transform(_controller.value);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background container
                    _buildMorphingContainer(screenSize, t, items, compact, isBottom),

                    // Header (fades out)
                    _buildHeader(t, screenSize, navProvider),

                    // Header divider (fades out)
                    _buildHeaderDivider(t, screenSize),

                    // Navigation items
                    ..._buildMorphingItems(
                      screenSize,
                      t,
                      items,
                      compact,
                      isBottom,
                      navProvider,
                    ),

                    // Tab bar dividers
                    ..._buildTabBarDividers(t, screenSize, items, compact, isBottom),

                    // Toggle button
                    _buildToggleButton(t, screenSize, items, compact, isBottom, navProvider),

                    // Footer (fades out)
                    _buildFooter(t, screenSize),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// Build all morphing navigation items
  List<Widget> _buildMorphingItems(
    Size screenSize,
    double t,
    List<NavItem> items,
    bool compact,
    bool isBottom,
    nav.NavigationProvider navProvider,
  ) {
    final widgets = <Widget>[];
    int sidebarIndex = 0;

    for (int tabBarIndex = 0; tabBarIndex < items.length; tabBarIndex++) {
      final item = items[tabBarIndex];
      final isSection = item.hasChildren;

      // Calculate sidebar position accounting for expanded sections
      final sidebarRect = _getSidebarItemRect(sidebarIndex, screenSize);
      final tabBarRect = _getTabBarItemRect(tabBarIndex, screenSize, items, compact, isBottom);

      // For sections, determine what to display
      // In sidebar mode (t < 0.5): always show parent item, NOT highlighted
      // In tab bar mode (t >= 0.5): show selected child if any, highlighted
      NavItem displayItem = item;
      bool isSelected = false;

      if (isSection) {
        final hasSelectedChild = navProvider.hasSelectedChild(item.id);

        // Only highlight section header in tab bar mode (when showing child's icon/label)
        // In sidebar mode, the child item itself will be highlighted, not the parent
        isSelected = hasSelectedChild && t >= 0.5;

        // Only show selected child's icon/label in tab bar mode
        if (hasSelectedChild && t >= 0.5) {
          // Find the selected child
          for (final child in item.children!) {
            if (navProvider.isItemSelected(child.id)) {
              displayItem = child;
              break;
            }
          }
        }
      } else {
        isSelected = navProvider.isItemSelected(item.id);
      }

      widgets.add(
        MorphingNavItem(
          key: ValueKey(item.id),
          item: item,
          displayItem: displayItem,
          t: t,
          sidebarRect: sidebarRect,
          tabBarRect: tabBarRect,
          isSelected: isSelected,
          isSection: isSection,
          compact: compact,
          onTap: () {
            if (isSection) {
              if (t < 0.5) {
                // Sidebar mode: toggle section expansion
                navProvider.toggleSection(item.id);
              }
              // Tab bar mode: handled by MorphingNavItem (shows dropdown)
            } else {
              navProvider.selectItem(item.id);
            }
          },
          navProvider: navProvider,
        ),
      );

      sidebarIndex++;

      // Always add children (for animation), pass expanded state
      if (isSection && item.children != null) {
        final isExpanded = navProvider.isSectionExpanded(item.id);
        final totalChildren = item.children!.length;

        // Use separate counter for child positions - always unique
        // This ensures children maintain their positions during collapse animation
        int childSidebarIndex = sidebarIndex;

        for (int childIndex = 0; childIndex < totalChildren; childIndex++) {
          final child = item.children![childIndex];
          final childSidebarRect = _getSidebarItemRect(
            childSidebarIndex,
            screenSize,
            isChild: true,
          );

          // Children collapse into parent's tab bar position
          widgets.add(
            MorphingNavItem(
              key: ValueKey(child.id),
              item: child,
              displayItem: child,
              t: t,
              sidebarRect: childSidebarRect,
              tabBarRect: tabBarRect, // Collapse into parent
              isSelected: navProvider.isItemSelected(child.id),
              isSection: false,
              isChild: true,
              childIndex: childIndex,
              totalChildren: totalChildren,
              isParentExpanded: isExpanded,
              compact: compact,
              onTap: () => navProvider.selectItem(child.id),
              navProvider: navProvider,
            ),
          );

          // Always increment child position counter (for unique positions)
          childSidebarIndex++;

          // Only increment main sidebar index when expanded
          // This controls where items BELOW the section are positioned
          if (isExpanded) {
            sidebarIndex++;
          }
        }
      }
    }

    return widgets;
  }
}

/// Toggle button widget
class _ToggleButton extends StatefulWidget {
  final IconData sidebarIcon;
  final IconData tabBarIcon;
  final double sidebarIconOpacity;
  final double tabBarIconOpacity;
  final VoidCallback onTap;
  final bool compact;
  final double t;

  const _ToggleButton({
    required this.sidebarIcon,
    required this.tabBarIcon,
    required this.sidebarIconOpacity,
    required this.tabBarIconOpacity,
    required this.onTap,
    required this.compact,
    required this.t,
  });

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
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered ? Colors.black.withValues(alpha: 0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(lerpDouble(10, 20, widget.t)!),
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Sidebar icon (collapse)
                if (widget.sidebarIconOpacity > 0)
                  Opacity(
                    opacity: widget.sidebarIconOpacity,
                    child: Icon(
                      widget.sidebarIcon,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                // Tab bar icon (expand)
                if (widget.tabBarIconOpacity > 0)
                  Opacity(
                    opacity: widget.tabBarIconOpacity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.tabBarIcon,
                          size: widget.compact ? 20 : 24,
                          color: AppTheme.textSecondary,
                        ),
                        if (widget.t > 0.7) ...[
                          const SizedBox(height: 4),
                          Opacity(
                            opacity: ((widget.t - 0.7) * 3.33).clamp(0.0, 1.0),
                            child: Text(
                              'Expand',
                              style: TextStyle(
                                fontSize: widget.compact ? 10 : 11,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header toggle button (for sidebar mode)
class _HeaderToggleButton extends StatefulWidget {
  final VoidCallback onTap;

  const _HeaderToggleButton({required this.onTap});

  @override
  State<_HeaderToggleButton> createState() => _HeaderToggleButtonState();
}

class _HeaderToggleButtonState extends State<_HeaderToggleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.hoverDuration,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _isHovered
                ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.view_sidebar_rounded,
            size: 20,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
