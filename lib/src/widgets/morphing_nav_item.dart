import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/nav_item.dart';
import '../controller/navigation_provider.dart' as nav;
import '../theme/app_theme.dart';

/// MorphingNavItem represents a single navigation item that morphs between
/// sidebar and tab bar layouts.
///
/// Key features:
/// - Position interpolated between sidebar and tab bar positions
/// - Layout crossfades between Row (sidebar) and Column (tab bar)
/// - Labels fade appropriately during transition
/// - Handles both regular items and sections with children
class MorphingNavItem extends StatefulWidget {
  final NavItem item;
  final NavItem displayItem;
  final double t;
  final Rect sidebarRect;
  final Rect tabBarRect;
  final bool isSelected;
  final bool isSection;
  final bool isChild;
  final int childIndex; // Index of child for staggered animation
  final int totalChildren; // Total number of children for reverse stagger
  final bool isParentExpanded; // Whether parent section is expanded
  final bool compact;
  final VoidCallback onTap;
  final nav.NavigationProvider navProvider;

  const MorphingNavItem({
    super.key,
    required this.item,
    required this.displayItem,
    required this.t,
    required this.sidebarRect,
    required this.tabBarRect,
    required this.isSelected,
    required this.isSection,
    this.isChild = false,
    this.childIndex = 0,
    this.totalChildren = 0,
    this.isParentExpanded = true,
    required this.compact,
    required this.onTap,
    required this.navProvider,
  });

  @override
  State<MorphingNavItem> createState() => _MorphingNavItemState();
}

class _MorphingNavItemState extends State<MorphingNavItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  final GlobalKey _buttonKey = GlobalKey();

  // Animation for child items expanding/collapsing
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: AppTheme.accordionDuration,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: AppTheme.accordionCurve,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(_expandAnimation);

    // Start expanded if this is a child item (animate in with staggered delay)
    if (widget.isChild) {
      if (widget.isParentExpanded) {
        // Expanding: first child animates first
        Future.delayed(Duration(milliseconds: 50 * widget.childIndex), () {
          if (mounted) {
            _expandController.forward();
          }
        });
      } else {
        // Already collapsed state
        _expandController.value = 0.0;
      }
    } else {
      _expandController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MorphingNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle expand/collapse state changes for child items
    if (widget.isChild && oldWidget.isParentExpanded != widget.isParentExpanded) {
      if (widget.isParentExpanded) {
        // Expanding: first child animates first (index 0, 1, 2...)
        Future.delayed(Duration(milliseconds: 50 * widget.childIndex), () {
          if (mounted) {
            _expandController.forward();
          }
        });
      } else {
        // Collapsing: last child animates first (reverse order)
        final reverseIndex = widget.totalChildren - 1 - widget.childIndex;
        Future.delayed(Duration(milliseconds: 50 * reverseIndex), () {
          if (mounted) {
            _expandController.reverse();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Interpolate position
    final rect = Rect.lerp(widget.sidebarRect, widget.tabBarRect, widget.t)!;

    // Child items fade out during transition (they collapse into parent)
    if (widget.isChild) {
      final transitionOpacity = (1.0 - widget.t * 2).clamp(0.0, 1.0);
      if (transitionOpacity <= 0) return const SizedBox.shrink();

      return AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          // Hide completely when animation is done collapsing
          if (_expandAnimation.value <= 0.01 && !widget.isParentExpanded) {
            return const SizedBox.shrink();
          }

          // Use Positioned (not AnimatedPositioned) - the morph position comes from Rect.lerp
          // The expand/collapse animation is handled by SlideTransition and FadeTransition
          return Positioned(
            left: rect.left,
            top: rect.top,
            width: rect.width,
            height: rect.height,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _expandAnimation,
                child: Opacity(
                  opacity: transitionOpacity,
                  child: _buildSidebarContent(),
                ),
              ),
            ),
          );
        },
      );
    }

    // Label opacity transitions:
    // - Sidebar labels visible at t=0, fade out by t=0.3
    // - Tab bar labels invisible until t=0.7, fade in by t=1.0
    final sidebarLabelOpacity = (1.0 - widget.t * 3.33).clamp(0.0, 1.0);
    final tabBarLabelOpacity = ((widget.t - 0.7) * 3.33).clamp(0.0, 1.0);

    // Icon color transitions
    final iconColor = widget.isSelected
        ? Colors.white
        : (widget.displayItem.iconColor ?? AppTheme.textSecondary);

    // Text color transitions
    final textColor = widget.isSelected ? Colors.white : AppTheme.textPrimary;
    final tabBarTextColor = widget.isSelected ? Colors.white : AppTheme.textSecondary;

    // Positioning strategy:
    // - During morphing (0 < t < 1): Use Positioned - position comes from Rect.lerp
    // - In sidebar mode (t == 0): Use AnimatedPositioned - for section expand/collapse animation
    // - In tabbar mode (t == 1): Use Positioned - no position changes expected
    final bool isMorphing = widget.t > 0.01 && widget.t < 0.99;

    final positionedChild = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        key: _buttonKey,
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.isSection && widget.t >= 0.5) {
            _showDropdown();
          } else {
            widget.onTap();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.isSelected ? AppTheme.activeItemGradient : null,
            color: widget.isSelected
                ? null
                : (_isHovered
                    ? (widget.t < 0.5
                        ? AppTheme.sidebarItemHover
                        : Colors.black.withValues(alpha: 0.05))
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(
              lerpDouble(10, 20, widget.t)!,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Sidebar layout (Row: icon + label)
              if (sidebarLabelOpacity > 0)
                Opacity(
                  opacity: sidebarLabelOpacity,
                  child: _buildSidebarLayout(iconColor, textColor),
                ),
              // Tab bar layout (Column: icon over label)
              if (tabBarLabelOpacity > 0 || widget.t > 0.3)
                Opacity(
                  opacity: widget.t > 0.7
                      ? tabBarLabelOpacity
                      : (widget.t > 0.3 ? ((widget.t - 0.3) * 2.5).clamp(0.0, 1.0) : 0.0),
                  child: _buildTabBarLayout(iconColor, tabBarTextColor, tabBarLabelOpacity > 0),
                ),
            ],
          ),
        ),
      ),
    );

    // During morphing: use Positioned (direct from Rect.lerp, synced with container)
    // In sidebar mode: use AnimatedPositioned (for smooth section expand/collapse)
    if (isMorphing) {
      return Positioned(
        left: rect.left,
        top: rect.top,
        width: rect.width,
        height: rect.height,
        child: positionedChild,
      );
    } else {
      return AnimatedPositioned(
        duration: AppTheme.accordionDuration,
        curve: AppTheme.accordionCurve,
        left: rect.left,
        top: rect.top,
        width: rect.width,
        height: rect.height,
        child: positionedChild,
      );
    }
  }

  /// Build sidebar-style content (for child items that don't morph)
  Widget _buildSidebarContent() {
    final iconColor = widget.isSelected
        ? Colors.white
        : (widget.item.iconColor ?? AppTheme.textSecondary);
    final textColor = widget.isSelected ? Colors.white : AppTheme.textPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.isSelected ? AppTheme.activeItemGradient : null,
            color: widget.isSelected
                ? null
                : (_isHovered ? AppTheme.sidebarItemHover : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                size: 18,
                color: iconColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (widget.item.badge != null)
                _buildBadge(widget.item.badge!, small: false),
            ],
          ),
        ),
      ),
    );
  }

  /// Build sidebar layout (Row with icon + label)
  Widget _buildSidebarLayout(Color iconColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(
            widget.displayItem.icon,
            size: 22,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.displayItem.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.item.badge != null)
            _buildBadge(widget.item.badge!, small: false),
          if (widget.isSection)
            Consumer<nav.NavigationProvider>(
              builder: (context, provider, _) {
                final expanded = provider.isSectionExpanded(widget.item.id);
                return AnimatedRotation(
                  turns: expanded ? 0.25 : 0,
                  duration: AppTheme.accordionDuration,
                  curve: AppTheme.accordionCurve,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: widget.isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Build tab bar layout (Column with icon over label)
  Widget _buildTabBarLayout(Color iconColor, Color textColor, bool showLabel) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 6 : 8,
        vertical: widget.compact ? 2 : 4,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.displayItem.icon,
                  size: widget.compact ? 20 : 24,
                  color: iconColor,
                ),
                if (widget.isSection) ...[
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 16,
                    color: widget.isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ],
              ],
            ),
            if (showLabel) ...[
              const SizedBox(height: 2),
              Text(
                widget.displayItem.label,
                style: TextStyle(
                  fontSize: widget.compact ? 10 : 11,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
            if (widget.item.badge != null && showLabel) ...[
              const SizedBox(height: 2),
              _buildBadge(widget.item.badge!, small: true),
            ],
          ],
        ),
      ),
    );
  }

  /// Build badge widget
  Widget _buildBadge(String badge, {required bool small}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? Colors.white.withValues(alpha: 0.2)
            : AppTheme.primaryRed,
        borderRadius: BorderRadius.circular(small ? 8 : 10),
      ),
      child: Text(
        badge,
        style: TextStyle(
          fontSize: small ? 9 : 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Show dropdown for section items in tab bar mode
  void _showDropdown() {
    if (!widget.isSection || widget.item.children == null) return;

    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final isBottom = widget.navProvider.tabBarPosition == nav.TabBarPosition.bottom;

    Navigator.of(context).push(
      _AnimatedDropdownRoute(
        buttonOffset: offset,
        buttonSize: size,
        isBottom: isBottom,
        children: widget.item.children!,
        navProvider: widget.navProvider,
      ),
    );
  }
}

/// Animated dropdown route with scale and fade transitions
class _AnimatedDropdownRoute extends PopupRoute<String> {
  final Offset buttonOffset;
  final Size buttonSize;
  final bool isBottom;
  final List<NavItem> children;
  final nav.NavigationProvider navProvider;

  _AnimatedDropdownRoute({
    required this.buttonOffset,
    required this.buttonSize,
    required this.isBottom,
    required this.children,
    required this.navProvider,
  });

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss dropdown';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 150);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _AnimatedDropdown(
      animation: animation,
      buttonOffset: buttonOffset,
      buttonSize: buttonSize,
      isBottom: isBottom,
      children: children,
      navProvider: navProvider,
      onDismiss: () => Navigator.of(context).pop(),
    );
  }
}

/// Animated dropdown widget
class _AnimatedDropdown extends StatelessWidget {
  final Animation<double> animation;
  final Offset buttonOffset;
  final Size buttonSize;
  final bool isBottom;
  final List<NavItem> children;
  final nav.NavigationProvider navProvider;
  final VoidCallback onDismiss;

  const _AnimatedDropdown({
    required this.animation,
    required this.buttonOffset,
    required this.buttonSize,
    required this.isBottom,
    required this.children,
    required this.navProvider,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final dropdownHeight = children.length * 56.0 + 16;
    final top = isBottom
        ? buttonOffset.dy - dropdownHeight
        : buttonOffset.dy + buttonSize.height + 8;

    // Scale animation: 0.8 -> 1.0
    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    // Fade animation
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    // Slide animation: slight vertical movement
    final slideAnimation = Tween<Offset>(
      begin: Offset(0, isBottom ? 0.1 : -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    return Stack(
      children: [
        // Invisible barrier to detect taps outside
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
          ),
        ),
        Positioned(
          left: buttonOffset.dx,
          top: top,
          child: SlideTransition(
            position: slideAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              alignment: isBottom ? Alignment.bottomCenter : Alignment.topCenter,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: Consumer<nav.NavigationProvider>(
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
                            children: List.generate(children.length, (index) {
                              final child = children[index];
                              final isSelected = provider.isItemSelected(child.id);
                              return _AnimatedDropdownItem(
                                item: child,
                                isSelected: isSelected,
                                index: index,
                                totalItems: children.length,
                                parentAnimation: animation,
                                onTap: () {
                                  onDismiss();
                                  provider.selectItem(child.id);
                                },
                              );
                            }),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated dropdown item with staggered entrance animation
class _AnimatedDropdownItem extends StatefulWidget {
  final NavItem item;
  final bool isSelected;
  final int index;
  final int totalItems;
  final Animation<double> parentAnimation;
  final VoidCallback onTap;

  const _AnimatedDropdownItem({
    required this.item,
    required this.isSelected,
    required this.index,
    required this.totalItems,
    required this.parentAnimation,
    required this.onTap,
  });

  @override
  State<_AnimatedDropdownItem> createState() => _AnimatedDropdownItemState();
}

class _AnimatedDropdownItemState extends State<_AnimatedDropdownItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Staggered animation: each item starts slightly later
    // Calculate interval for this item
    final itemDelay = 0.1 * widget.index;
    final itemEnd = 0.4 + itemDelay;
    final clampedEnd = itemEnd.clamp(0.0, 1.0);
    final clampedStart = itemDelay.clamp(0.0, clampedEnd - 0.1);

    final itemAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.parentAnimation,
      curve: Interval(clampedStart, clampedEnd, curve: Curves.easeOutCubic),
    ));

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.parentAnimation,
      curve: Interval(clampedStart, clampedEnd, curve: Curves.easeOutCubic),
    ));

    return AnimatedBuilder(
      animation: itemAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: itemAnimation.value,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      child: MouseRegion(
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
      ),
    );
  }
}
