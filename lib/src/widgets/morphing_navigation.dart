import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/nav_item.dart';
import '../models/system_status.dart';
import '../controller/navigation_provider.dart' as nav;
import '../theme/navigation_theme.dart';
import 'morphing_nav_item.dart';
import 'navigation_header.dart';
import 'status_panel.dart';
import 'package:flutter_icon/flutter_icon.dart';

/// MorphingNavigation is the main orchestrator widget that handles the
/// continuous morphing animation between sidebar and tab bar navigation.
///
/// Key features:
/// - Single AnimationController where t=0 is sidebar, t=1 is tabbar
/// - Uses LayoutBuilder to compute positions based on screen size
/// - Renders a Stack with positioned children that interpolate positions
class MorphingNavigation extends StatefulWidget {
  const MorphingNavigation({super.key});

  /// iPad-style two-phase rect interpolation.
  ///
  /// Instead of a plain Rect.lerp (diagonal morph), this collapses the
  /// sidebar vertically first, then slides horizontally to the tab bar
  /// position — matching iPadOS behavior.
  static Rect morphRect(Rect sidebar, Rect tabBar, double t) {
    // Vertical collapse: fast, done by ~45%
    final vt = Curves.easeInOut.transform((t / 0.45).clamp(0.0, 1.0));
    final top = lerpDouble(sidebar.top, tabBar.top, vt)!;
    final height = lerpDouble(sidebar.height, tabBar.height, vt)!;

    // Horizontal slide: starts at ~30%, finishes at 100%
    final ht = Curves.easeInOut.transform(((t - 0.30) / 0.70).clamp(0.0, 1.0));
    final left = lerpDouble(sidebar.left, tabBar.left, ht)!;
    final width = lerpDouble(sidebar.width, tabBar.width, ht)!;

    return Rect.fromLTWH(left, top, width, height);
  }

  @override
  State<MorphingNavigation> createState() => _MorphingNavigationState();
}

class _MorphingNavigationState extends State<MorphingNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  nav.NavigationMode? _previousMode;

  // Theme reference — updated each build cycle via InheritedWidget
  MorphingNavigationTheme _navTheme = const MorphingNavigationTheme();

  // Header/footer visibility — updated each build from provider
  bool _showHeader = true;
  bool _showFooter = true;
  MorphingNavHeader? _headerConfig;
  MorphingNavFooter? _footerConfig;

  // Sidebar layout constants (read from theme)
  double get _sidebarWidth => _navTheme.sidebarWidth;
  double get _headerHeight => _navTheme.headerHeight;
  double get _itemHeight => _navTheme.itemHeight;
  double get _itemSpacing => _navTheme.itemSpacing;
  static const double _horizontalMargin = 12.0;
  double get _footerHeight => _navTheme.footerHeight;
  static const double _statusPanelHeight = 150.0;

  // Height reserved for the toggle button row when header is hidden
  static const double _toggleRowHeight = 44.0;

  // Effective heights — when header is hidden, reserve space for the toggle row
  double get _effectiveHeaderHeight => _showHeader ? _headerHeight : _toggleRowHeight;
  double get _effectiveFooterHeight => _showFooter ? _footerHeight : 0;

  // Scroll state for sidebar items
  double _scrollOffset = 0.0;

  // TabBar layout constants (read from theme)
  double get _tabBarHeight => _navTheme.tabBarHeight;
  static const double _tabBarTopMargin = 16.0;
  static const double _tabBarBottomMargin = 24.0;

  // Tab bar pagination state
  int _pageStartIndex = 0;
  static const double _arrowButtonWidth = 36.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read theme from inherited widget
    _navTheme = MorphingNavigationThemeProvider.of(context);
    _controller.duration = _navTheme.modeTransitionDuration;

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

  /// Measure the tab bar width needed for a single item's text label.
  double _measureTabBarItemWidth(NavItem item, bool compact) {
    final fontSize = compact ? 12.0 : 13.0;
    final tp = TextPainter(
      text: TextSpan(
        text: item.label,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final textWidth = tp.width;
    tp.dispose();
    // horizontal padding inside each item + room for section dropdown arrow / badge
    final extra = (item.hasChildren ? 18.0 : 0.0) + (item.badge != null ? 24.0 : 0.0);
    final minWidth = compact ? 48.0 : 56.0;
    return (textWidth + 24 + extra).clamp(minWidth, double.infinity); // 24 = inner horizontal padding (12*2)
  }

  /// Calculate the visible item range for tab bar pagination.
  ///
  /// Returns (startIndex, endIndex, showLeftArrow, showRightArrow).
  /// The toggle button and status indicator are always outside pagination.
  ({int start, int end, bool showLeft, bool showRight}) _getVisibleItemRange(
    List<NavItem> items,
    bool compact,
    double screenWidth, {
    bool hasStatus = false,
  }) {
    final toggleWidth = compact ? 48.0 : 56.0;
    final horizontalPadding = compact ? 8.0 : 12.0;
    final statusWidth = hasStatus ? (compact ? 240.0 : 260.0) : 0.0;
    final maxTabBarWidth = screenWidth - 32; // 16px margin on each side

    // Fixed overhead: toggle + status + padding + divider after toggle
    final fixedWidth = toggleWidth + statusWidth + (horizontalPadding * 2) + 1;

    // Check if all items fit
    double allItemsWidth = 0;
    for (int i = 0; i < items.length; i++) {
      allItemsWidth += _measureTabBarItemWidth(items[i], compact) + 1; // +1 divider
    }

    if (fixedWidth + allItemsWidth <= maxTabBarWidth) {
      // All items fit — no pagination needed
      return (start: 0, end: items.length, showLeft: false, showRight: false);
    }

    // Pagination needed — clamp page start
    final startIndex = _pageStartIndex.clamp(0, items.length - 1);
    final showLeft = startIndex > 0;

    // Available width for items (subtract arrows as needed)
    double available = maxTabBarWidth - fixedWidth;
    if (showLeft) available -= _arrowButtonWidth + 1;
    // Tentatively reserve right arrow space
    final availableWithRight = available - _arrowButtonWidth - 1;

    // Fill items from startIndex until they exceed available width
    int endIndex = startIndex;
    double usedWidth = 0;
    for (int i = startIndex; i < items.length; i++) {
      final w = _measureTabBarItemWidth(items[i], compact) + 1;
      if (usedWidth + w > availableWithRight && i > startIndex) break;
      usedWidth += w;
      endIndex = i + 1;
    }

    final showRight = endIndex < items.length;

    // If no right arrow needed, reclaim that space and try to fit more
    if (!showRight) {
      endIndex = startIndex;
      usedWidth = 0;
      for (int i = startIndex; i < items.length; i++) {
        final w = _measureTabBarItemWidth(items[i], compact) + 1;
        if (usedWidth + w > available && i > startIndex) break;
        usedWidth += w;
        endIndex = i + 1;
      }
    }

    return (start: startIndex, end: endIndex, showLeft: showLeft, showRight: endIndex < items.length);
  }

  /// Calculate the width of the tab bar based on visible items only.
  double _calculateTabBarWidth(
    List<NavItem> items,
    bool compact,
    double screenWidth, {
    bool hasStatus = false,
  }) {
    final range = _getVisibleItemRange(items, compact, screenWidth, hasStatus: hasStatus);
    final toggleWidth = compact ? 48.0 : 56.0;
    final horizontalPadding = compact ? 8.0 : 12.0;
    final statusWidth = hasStatus ? (compact ? 240.0 : 260.0) : 0.0;

    // Sum visible item widths
    double visibleItemsWidth = 0;
    for (int i = range.start; i < range.end; i++) {
      visibleItemsWidth += _measureTabBarItemWidth(items[i], compact);
    }
    final visibleCount = range.end - range.start;

    // Arrow buttons
    final leftArrowWidth = range.showLeft ? _arrowButtonWidth + 1 : 0.0;
    final rightArrowWidth = range.showRight ? _arrowButtonWidth + 1 : 0.0;

    return toggleWidth +
        visibleItemsWidth +
        leftArrowWidth +
        rightArrowWidth +
        statusWidth +
        ((visibleCount + 1) * 1.0) + // dividers: after toggle + between/after items
        (horizontalPadding * 2);
  }

  /// Get the sidebar container rect
  Rect _getSidebarContainerRect(Size screenSize) {
    return Rect.fromLTWH(0, 0, _sidebarWidth, screenSize.height);
  }

  /// Get the tab bar container rect
  Rect _getTabBarContainerRect(Size screenSize, List<NavItem> items, bool compact, bool isBottom, {bool hasStatus = false}) {
    final tabBarWidth = _calculateTabBarWidth(items, compact, screenSize.width, hasStatus: hasStatus);
    final left = (screenSize.width - tabBarWidth) / 2;
    final top = isBottom
        ? screenSize.height - _tabBarHeight - _tabBarBottomMargin
        : _tabBarTopMargin;

    return Rect.fromLTWH(left, top, tabBarWidth, _tabBarHeight);
  }

  /// Get sidebar item rect for a given visual index
  /// The index represents the visual position in the sidebar list
  Rect _getSidebarItemRect(int visualIndex, Size screenSize, {bool isChild = false}) {
    final top = _effectiveHeaderHeight + 12 + visualIndex * (_itemHeight + _itemSpacing);
    final left = isChild ? 32.0 : _horizontalMargin;
    final width = _sidebarWidth - left - _horizontalMargin;

    return Rect.fromLTWH(left, top, width, _itemHeight);
  }

  /// Get tab bar item rect for a given index.
  ///
  /// For items outside the visible pagination range, returns a collapsed rect
  /// at the edge of the visible area (so morph animations have a sensible target).
  Rect _getTabBarItemRect(
    int index,
    Size screenSize,
    List<NavItem> items,
    bool compact,
    bool isBottom, {
    bool hasStatus = false,
  }) {
    final containerRect = _getTabBarContainerRect(screenSize, items, compact, isBottom, hasStatus: hasStatus);
    final horizontalPadding = compact ? 8.0 : 12.0;
    final verticalPadding = 8.0;
    final toggleWidth = compact ? 48.0 : 56.0;
    final top = containerRect.top + verticalPadding;
    final height = containerRect.height - verticalPadding * 2;

    final range = _getVisibleItemRange(items, compact, screenSize.width, hasStatus: hasStatus);

    final itemWidth = _measureTabBarItemWidth(items[index], compact);

    // Items outside visible range: position at the edge with real width
    // so AnimatedPositioned can animate them sliding in/out.
    if (index < range.start) {
      // Left of visible area — stacked at left edge (behind left arrow)
      final leftEdge = containerRect.left + horizontalPadding + toggleWidth + 1;
      return Rect.fromLTWH(leftEdge - itemWidth, top, itemWidth, height);
    }
    if (index >= range.end) {
      // Right of visible area — stacked at right edge (behind right arrow)
      return Rect.fromLTWH(containerRect.right - horizontalPadding, top, itemWidth, height);
    }

    // Item is visible — position after toggle + left arrow + preceding visible items
    double left = containerRect.left + horizontalPadding + toggleWidth + 1;
    if (range.showLeft) left += _arrowButtonWidth + 1;

    for (int i = range.start; i < index; i++) {
      left += _measureTabBarItemWidth(items[i], compact) + 1;
    }

    return Rect.fromLTWH(left, top, itemWidth, height);
  }

  /// Count total visible items including expanded section children
  int _countVisualItems(List<NavItem> items, nav.NavigationProvider navProvider) {
    int count = 0;
    for (final item in items) {
      count++;
      if (item.hasChildren && item.children != null && navProvider.isSectionExpanded(item.id)) {
        count += item.children!.length;
      }
    }
    return count;
  }

  /// Calculate max scroll offset based on total items height vs available height
  double _calculateMaxScrollOffset(Size screenSize, List<NavItem> items, nav.NavigationProvider navProvider, {bool hasStatus = false}) {
    final visualItemCount = _countVisualItems(items, navProvider);
    final totalContentHeight = 12 + visualItemCount * (_itemHeight + _itemSpacing) + 12;
    final statusHeight = hasStatus ? _statusPanelHeight : 0.0;
    final availableHeight = screenSize.height - _effectiveHeaderHeight - _effectiveFooterHeight - statusHeight;
    return (totalContentHeight - availableHeight).clamp(0.0, double.infinity);
  }

  /// Build the morphing container (background that transforms from sidebar to tab bar)
  Widget _buildMorphingContainer(
    Size screenSize,
    double t,
    List<NavItem> items,
    bool compact,
    bool isBottom, {
    bool hasStatus = false,
  }) {
    final sidebarRect = _getSidebarContainerRect(screenSize);
    final tabBarRect = _getTabBarContainerRect(screenSize, items, compact, isBottom, hasStatus: hasStatus);

    final rect = MorphingNavigation.morphRect(sidebarRect, tabBarRect, t);
    final borderRadius = lerpDouble(16, 32, t)!;
    final blur = lerpDouble(0, _navTheme.glassBlurRadius, t)!;

    // Background color transitions from sidebar to glassmorphism
    final backgroundColor = Color.lerp(
      _navTheme.sidebarBackgroundColor,
      _navTheme.glassBackgroundColor,
      t,
    )!;

    // Border color transitions
    final borderColor = Color.lerp(
      _navTheme.borderColor,
      _navTheme.glassBorderColor,
      t,
    )!;

    // Get theme for shadows
    final tabBarShadow = _navTheme.effectiveTabBarShadow;

    // Interpolate shadow opacity based on t
    final shadowMultiplier = t.clamp(0.0, 1.0);
    final interpolatedShadow = tabBarShadow.map((shadow) {
      return BoxShadow(
        color: shadow.color.withValues(alpha: shadow.color.a * shadowMultiplier),
        blurRadius: shadow.blurRadius * shadowMultiplier,
        spreadRadius: shadow.spreadRadius * shadowMultiplier,
        offset: Offset(
          shadow.offset.dx * shadowMultiplier,
          shadow.offset.dy * shadowMultiplier,
        ),
      );
    }).toList();

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: t > 0.05 ? interpolatedShadow : null,
          // Sidebar mode: right border only
          border: t < 0.5
              ? Border(
                  right: BorderSide(
                    color: Color.lerp(
                      _navTheme.borderColor,
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
    if (!_showHeader) return const SizedBox.shrink();

    // Fade out in first 30% of transition
    final opacity = (1.0 - t * 3.33).clamp(0.0, 1.0);
    if (opacity <= 0) return const SizedBox.shrink();

    final width = lerpDouble(_sidebarWidth, 0, t)!;
    final config = _headerConfig;

    // Custom builder takes priority
    if (config?.builder != null) {
      return Positioned(
        top: 0,
        left: 0,
        width: width,
        height: _headerHeight,
        child: Opacity(
          opacity: opacity,
          child: config!.builder!(context, navProvider.toggleMode),
        ),
      );
    }

    // Default logo
    final logo = config?.logo ??
        Container(
          width: 40,
          height: 40,
          decoration: config?.logoDecoration ??
              BoxDecoration(
                gradient: _navTheme.effectivePrimaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
          child: const Icon(
            Icons.dashboard_rounded,
            color: Colors.white,
            size: 24,
          ),
        );

    final title = config != null ? config.title : 'Dashboard';
    final String? subtitle = config != null ? config.subtitle : 'Navigation Demo';
    final showToggle = config?.showToggleButton ?? true;

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
              SizedBox(width: 40, height: 40, child: logo),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _navTheme.textPrimaryColor,
                        height: 1.2,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: _navTheme.textSecondaryColor,
                          height: 1.2,
                        ),
                      ),
                  ],
                ),
              ),
              if (config?.trailing != null) config!.trailing!,
              // Reserve space for the unified morph toggle button that
              // overlays this area (rendered separately so it can morph).
              if (showToggle) const SizedBox(width: 56),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the divider below header
  Widget _buildHeaderDivider(double t, Size screenSize) {
    if (!_showHeader) return const SizedBox.shrink();

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
          color: _navTheme.borderColor,
        ),
      ),
    );
  }

  /// Build the footer (user info) that fades out during transition
  Widget _buildFooter(double t, Size screenSize) {
    if (!_showFooter) return const SizedBox.shrink();

    // Fade out in first 30% of transition
    final opacity = (1.0 - t * 3.33).clamp(0.0, 1.0);
    if (opacity <= 0) return const SizedBox.shrink();

    final width = lerpDouble(_sidebarWidth, 0, t)!;
    final config = _footerConfig;

    // Custom builder takes priority
    if (config?.builder != null) {
      return Positioned(
        bottom: 0,
        left: 0,
        width: width,
        height: _footerHeight,
        child: Opacity(
          opacity: opacity,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: _navTheme.borderColor, width: 1),
              ),
            ),
            child: config!.builder!(context),
          ),
        ),
      );
    }

    // Determine avatar widget
    final avatarText = config?.avatarText ?? 'JD';
    final avatarWidget = config?.avatar ??
        Center(
          child: Text(
            avatarText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );

    final String? title = config != null ? config.title : 'John Doe';
    final String? subtitle = config != null ? config.subtitle : 'john@example.com';

    final footerContent = Row(
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: config?.avatarDecoration ??
              BoxDecoration(
                gradient: _navTheme.effectivePrimaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
          child: avatarWidget,
        ),
        const SizedBox(width: 12),
        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _navTheme.textPrimaryColor,
                  ),
                ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: _navTheme.textSecondaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (config?.trailing != null) config!.trailing!,
      ],
    );

    return Positioned(
      bottom: 0,
      left: 0,
      width: width,
      height: _footerHeight,
      child: Opacity(
        opacity: opacity,
        child: GestureDetector(
          onTap: config?.onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: _navTheme.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: footerContent,
          ),
        ),
      ),
    );
  }

  /// Build the sidebar status panel (shows in sidebar mode, fades during transition)
  Widget _buildSidebarStatusPanel(double t, Size screenSize, SystemStatus? status) {
    if (status == null) return const SizedBox.shrink();

    // Fade out in first 30% of transition
    final opacity = (1.0 - t * 3.33).clamp(0.0, 1.0);
    if (opacity <= 0) return const SizedBox.shrink();

    final width = lerpDouble(_sidebarWidth, 0, t)!;

    return Positioned(
      bottom: _effectiveFooterHeight,
      left: 0,
      width: width,
      child: SidebarStatusPanel(
        status: status,
        opacity: opacity,
      ),
    );
  }

  /// Build the tab bar status indicator (shows in tab bar mode, fades in during transition)
  Widget _buildTabBarStatusIndicator(
    double t,
    Size screenSize,
    List<NavItem> items,
    bool compact,
    bool isBottom,
    SystemStatus? status,
  ) {
    if (status == null) return const SizedBox.shrink();

    // Fade in during last 30% of transition
    final opacity = ((t - 0.7) * 3.33).clamp(0.0, 1.0);
    if (opacity <= 0) return const SizedBox.shrink();

    final tabBarRect = _getTabBarContainerRect(screenSize, items, compact, isBottom, hasStatus: true);
    final toggleWidth = compact ? 48.0 : 56.0;
    final horizontalPadding = compact ? 8.0 : 12.0;
    final range = _getVisibleItemRange(items, compact, screenSize.width, hasStatus: true);

    // Position after visible items + arrows
    double left = tabBarRect.left + horizontalPadding + toggleWidth + 1;
    if (range.showLeft) left += _arrowButtonWidth + 1;
    for (int i = range.start; i < range.end; i++) {
      left += _measureTabBarItemWidth(items[i], compact) + 1;
    }
    if (range.showRight) left += _arrowButtonWidth + 1;

    return Positioned(
      left: left,
      top: tabBarRect.top,
      height: tabBarRect.height,
      child: TabBarStatusIndicator(
        status: status,
        opacity: opacity,
      ),
    );
  }

  /// Build pagination arrow buttons for tab bar overflow.
  List<Widget> _buildPaginationArrows(
    double t,
    Size screenSize,
    List<NavItem> items,
    bool compact,
    bool isBottom, {
    bool hasStatus = false,
  }) {
    // Only show in tab bar mode
    final opacity = ((t - 0.7) * 3.33).clamp(0.0, 1.0);
    if (opacity <= 0) return const [];

    final range = _getVisibleItemRange(items, compact, screenSize.width, hasStatus: hasStatus);
    if (!range.showLeft && !range.showRight) return const [];

    final containerRect = _getTabBarContainerRect(screenSize, items, compact, isBottom, hasStatus: hasStatus);
    final horizontalPadding = compact ? 8.0 : 12.0;
    final verticalPadding = 8.0;
    final toggleWidth = compact ? 48.0 : 56.0;
    final top = containerRect.top + verticalPadding;
    final height = containerRect.height - verticalPadding * 2;

    final widgets = <Widget>[];

    if (range.showLeft) {
      final leftArrowLeft = containerRect.left + horizontalPadding + toggleWidth + 1;
      widgets.add(
        Positioned(
          left: leftArrowLeft,
          top: top,
          width: _arrowButtonWidth,
          height: height,
          child: Opacity(
            opacity: opacity,
            child: _PaginationArrow(
              icon: Icons.chevron_left_rounded,
              onTap: () {
                setState(() {
                  // Go back by the number of currently visible items
                  final visibleCount = range.end - range.start;
                  _pageStartIndex = (_pageStartIndex - visibleCount).clamp(0, items.length - 1);
                });
              },
            ),
          ),
        ),
      );
    }

    if (range.showRight) {
      // Right arrow is positioned after the last visible item
      double rightArrowLeft = containerRect.left + horizontalPadding + toggleWidth + 1;
      if (range.showLeft) rightArrowLeft += _arrowButtonWidth + 1;
      for (int i = range.start; i < range.end; i++) {
        rightArrowLeft += _measureTabBarItemWidth(items[i], compact) + 1;
      }
      widgets.add(
        Positioned(
          left: rightArrowLeft,
          top: top,
          width: _arrowButtonWidth,
          height: height,
          child: Opacity(
            opacity: opacity,
            child: _PaginationArrow(
              icon: Icons.chevron_right_rounded,
              onTap: () {
                setState(() {
                  _pageStartIndex = range.end.clamp(0, items.length - 1);
                });
              },
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  /// Build the toggle button — same button in both sidebar and tab bar modes.
  /// At t=0 it sits in the sidebar header area; at t=1 it's the leftmost
  /// tab bar item.  The MorphIconPainter smoothly morphs between the two
  /// icon states in sync.
  Widget _buildToggleButton(
    double t,
    Size screenSize,
    List<NavItem> items,
    bool compact,
    bool isBottom,
    nav.NavigationProvider navProvider, {
    bool hasStatus = false,
  }) {
    // Tab bar destination rect
    final tabBarRect = _getTabBarContainerRect(screenSize, items, compact, isBottom, hasStatus: hasStatus);
    final toggleWidth = compact ? 48.0 : 56.0;
    final horizontalPadding = compact ? 8.0 : 12.0;
    final verticalPadding = 8.0;

    final tabBarToggleRect = Rect.fromLTWH(
      tabBarRect.left + horizontalPadding,
      tabBarRect.top + verticalPadding,
      toggleWidth,
      tabBarRect.height - verticalPadding * 2,
    );

    // Sidebar start position — same size as the tab bar toggle so the
    // button looks identical in both modes; placed at the trailing end of
    // the header row (or the dedicated toggle row when header is hidden).
    final sidebarToggleTop = _showHeader
        ? (_headerHeight - tabBarToggleRect.height) / 2
        : (_toggleRowHeight - tabBarToggleRect.height) / 2;
    final sidebarRect = Rect.fromLTWH(
      _sidebarWidth - 20 - toggleWidth,
      sidebarToggleTop,
      toggleWidth,
      tabBarToggleRect.height,
    );

    final rect = MorphingNavigation.morphRect(sidebarRect, tabBarToggleRect, t);

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: _ToggleButton(
        onTap: navProvider.toggleMode,
        compact: compact,
        t: t,
      ),
    );
  }

  /// Build dividers between items in tab bar mode (currently disabled)
  List<Widget> _buildTabBarDividers(
    double t,
    Size screenSize,
    List<NavItem> items,
    bool compact,
    bool isBottom,
  ) {
    // Dividers removed for cleaner look
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<nav.NavigationProvider>(
      builder: (context, navProvider, _) {
        // Update theme reference
        _navTheme = MorphingNavigationThemeProvider.of(context);

        // Update header/footer config from provider
        _showHeader = navProvider.showHeader;
        _showFooter = navProvider.showFooter;
        _headerConfig = navProvider.header;
        _footerConfig = navProvider.footer;

        // Animate when mode changes
        if (_previousMode != navProvider.mode) {
          if (navProvider.isTabBarMode) {
            _controller.forward();
          } else {
            _controller.reverse();
            _pageStartIndex = 0; // Reset pagination when returning to sidebar
          }
          _previousMode = navProvider.mode;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenSize = constraints.biggest;
            final items = navProvider.items;
            final compact = screenSize.width < 600;
            final isBottom = navProvider.tabBarPosition == nav.TabBarPosition.bottom;
            final status = navProvider.status;
            final hasStatus = status != null;

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _navTheme.modeTransitionCurve.transform(_controller.value);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background container
                    _buildMorphingContainer(screenSize, t, items, compact, isBottom, hasStatus: hasStatus),

                    // Header (fades out)
                    _buildHeader(t, screenSize, navProvider),

                    // Header divider (fades out)
                    _buildHeaderDivider(t, screenSize),

                    // Navigation items (scrollable in sidebar mode)
                    _buildItemsLayer(
                      screenSize,
                      t,
                      items,
                      compact,
                      isBottom,
                      navProvider,
                      hasStatus: hasStatus,
                    ),

                    // Tab bar dividers
                    ..._buildTabBarDividers(t, screenSize, items, compact, isBottom),

                    // Toggle button
                    _buildToggleButton(t, screenSize, items, compact, isBottom, navProvider, hasStatus: hasStatus),

                    // Sidebar status panel (fades out)
                    _buildSidebarStatusPanel(t, screenSize, status),

                    // Tab bar pagination arrows
                    ..._buildPaginationArrows(t, screenSize, items, compact, isBottom, hasStatus: hasStatus),

                    // Tab bar status indicator (fades in)
                    _buildTabBarStatusIndicator(t, screenSize, items, compact, isBottom, status),

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

  /// Build the items layer with clipping and scroll support for sidebar mode.
  ///
  /// Uses ClipRect to constrain items to the sidebar area in sidebar mode,
  /// and Transform.translate to apply scroll offset without triggering
  /// AnimatedPositioned animations.
  Widget _buildItemsLayer(
    Size screenSize,
    double t,
    List<NavItem> items,
    bool compact,
    bool isBottom,
    nav.NavigationProvider navProvider, {
    bool hasStatus = false,
  }) {
    // Calculate scroll bounds and clamp offset
    final maxScroll = _calculateMaxScrollOffset(screenSize, items, navProvider, hasStatus: hasStatus);
    if (_scrollOffset > maxScroll) _scrollOffset = maxScroll;

    final itemWidgets = _buildMorphingItems(
      screenSize, t, items, compact, isBottom, navProvider, hasStatus: hasStatus,
    );

    // Calculate clip bounds for sidebar mode
    final statusHeight = hasStatus ? _statusPanelHeight : 0.0;
    final clipTop = _effectiveHeaderHeight;
    final clipBottom = screenSize.height - _effectiveFooterHeight - statusHeight;

    final sidebarClipRect = Rect.fromLTRB(0, clipTop, _sidebarWidth, clipBottom);
    final fullRect = Offset.zero & screenSize;

    return Positioned.fill(
      child: ClipRect(
        clipper: _ItemsClipper(
          t: t,
          sidebarClipRect: sidebarClipRect,
          fullRect: fullRect,
        ),
        child: Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent && t < 0.5 && maxScroll > 0) {
              setState(() {
                _scrollOffset = (_scrollOffset + event.scrollDelta.dy).clamp(0.0, maxScroll);
              });
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background hit target for scroll handling in empty sidebar space.
              // Positioned below items in z-order so items get tap priority.
              // Key is required to prevent Flutter from mismatching elements
              // when this conditional child is inserted/removed.
              if (t < 0.5 && maxScroll > 0)
                Positioned(
                  key: const ValueKey('sidebar_scroll_target'),
                  top: clipTop,
                  left: 0,
                  width: _sidebarWidth,
                  height: clipBottom - clipTop,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        _scrollOffset = (_scrollOffset - details.delta.dy).clamp(0.0, maxScroll);
                      });
                    },
                  ),
                ),
              // Items with scroll transform applied
              Positioned.fill(
                key: const ValueKey('items_transform_layer'),
                child: Transform.translate(
                  offset: Offset(0, -_scrollOffset * (1 - t)),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: itemWidgets,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build all morphing navigation items
  List<Widget> _buildMorphingItems(
    Size screenSize,
    double t,
    List<NavItem> items,
    bool compact,
    bool isBottom,
    nav.NavigationProvider navProvider, {
    bool hasStatus = false,
  }) {
    final widgets = <Widget>[];
    int sidebarIndex = 0;

    // Determine which items are visible in tab bar pagination
    final visibleRange = _getVisibleItemRange(items, compact, screenSize.width, hasStatus: hasStatus);

    for (int tabBarIndex = 0; tabBarIndex < items.length; tabBarIndex++) {
      final item = items[tabBarIndex];
      final isSection = item.hasChildren;
      final isInVisibleRange = tabBarIndex >= visibleRange.start && tabBarIndex < visibleRange.end;

      // Calculate sidebar position accounting for expanded sections
      final sidebarRect = _getSidebarItemRect(sidebarIndex, screenSize);
      final tabBarRect = _getTabBarItemRect(tabBarIndex, screenSize, items, compact, isBottom, hasStatus: hasStatus);

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
          visibleInTabBar: isInVisibleRange,
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
  final VoidCallback onTap;
  final bool compact;
  final double t;

  const _ToggleButton({
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
    final theme = MorphingNavigationThemeProvider.of(context);
    final iconSize = widget.compact ? 20.0 : 24.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered ? Colors.black.withValues(alpha: 0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CustomPaint(
              size: Size.square(iconSize),
              painter: MorphIconPainter(
                progress: 1.0 - widget.t,
                color: theme.textSecondaryColor,
                strokeWidth: (iconSize / 16).clamp(1.0, 3.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pagination arrow button for tab bar overflow (< and >)
class _PaginationArrow extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PaginationArrow({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_PaginationArrow> createState() => _PaginationArrowState();
}

class _PaginationArrowState extends State<_PaginationArrow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = MorphingNavigationThemeProvider.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered ? Colors.black.withValues(alpha: 0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: 20,
              color: theme.textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom clipper that constrains items to the sidebar area in sidebar mode
/// and expands to full screen during morphing transition.
class _ItemsClipper extends CustomClipper<Rect> {
  final double t;
  final Rect sidebarClipRect;
  final Rect fullRect;

  _ItemsClipper({
    required this.t,
    required this.sidebarClipRect,
    required this.fullRect,
  });

  @override
  Rect getClip(Size size) {
    if (t <= 0.01) return sidebarClipRect;
    if (t >= 0.99) return fullRect;
    return Rect.lerp(sidebarClipRect, fullRect, t)!;
  }

  @override
  bool shouldReclip(covariant _ItemsClipper oldClipper) {
    return oldClipper.t != t ||
        oldClipper.sidebarClipRect != sidebarClipRect ||
        oldClipper.fullRect != fullRect;
  }
}

/// Header toggle button (for sidebar mode)
