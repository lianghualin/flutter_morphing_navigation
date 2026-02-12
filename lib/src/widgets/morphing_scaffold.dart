import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controller/navigation_controller.dart';
import '../controller/navigation_provider.dart';
import '../models/nav_item.dart';
import '../models/system_status.dart';
import '../theme/navigation_theme.dart';
import 'navigation_header.dart';
import 'morphing_navigation.dart' as internal;

/// Page transition types for switching between pages
enum PageTransitionType {
  /// No animation, instant switch
  none,

  /// Fade in/out transition
  fade,

  /// Slide horizontally (left/right)
  slideHorizontal,

  /// Slide vertically (up/down)
  slideVertical,

  /// Scale up from center
  scale,

  /// Scale down (old shrinks away, new appears)
  scaleDown,

  /// Fade combined with horizontal slide
  fadeSlideHorizontal,

  /// Fade combined with vertical slide
  fadeSlideVertical,

  /// Fade combined with scale
  fadeScale,

  /// 3D rotation flip on Y-axis
  rotation,

  /// Cube-like 3D rotation between pages
  cubeRotation,

  /// Material Design fade-through (old fades out + scales down, new fades in + scales up)
  fadeThrough,

  /// Material Design shared axis X (both pages slide + fade together horizontally)
  sharedAxisHorizontal,

  /// Material Design shared axis Y (both pages slide + fade together vertically)
  sharedAxisVertical,
}

/// A scaffold widget that provides morphing navigation functionality.
///
/// This is the main entry point for using the morphing navigation package.
/// It provides a complete navigation solution that morphs between sidebar
/// and tab bar layouts.
///
/// ## Basic Usage with Child
///
/// ```dart
/// MorphingNavigationScaffold(
///   items: [
///     NavItem(id: 'home', label: 'Home', icon: Icons.home),
///     NavItem(id: 'settings', label: 'Settings', icon: Icons.settings),
///   ],
///   onItemSelected: (id) {
///     // Handle navigation
///   },
///   child: YourContentWidget(),
/// )
/// ```
///
/// ## Using Pages Map (Automatic Page Switching)
///
/// ```dart
/// MorphingNavigationScaffold(
///   items: [
///     NavItem(id: 'home', label: 'Home', icon: Icons.home),
///     NavItem(id: 'settings', label: 'Settings', icon: Icons.settings),
///   ],
///   pages: {
///     'home': HomePage(),
///     'settings': SettingsPage(),
///   },
///   pageTransitionType: PageTransitionType.fade,
/// )
/// ```
///
/// ## With Custom Header and Footer
///
/// ```dart
/// MorphingNavigationScaffold(
///   items: myItems,
///   header: MorphingNavHeader(
///     logo: Icon(Icons.dashboard),
///     title: 'My App',
///     subtitle: 'v1.0.0',
///   ),
///   footer: MorphingNavFooter.user(
///     name: 'John Doe',
///     email: 'john@example.com',
///   ),
///   child: YourContentWidget(),
/// )
/// ```
///
/// ## With Custom Theme
///
/// ```dart
/// MorphingNavigationScaffold(
///   items: myItems,
///   theme: MorphingNavigationTheme(
///     primaryColor: Colors.purple,
///     sidebarWidth: 280.0,
///   ),
///   child: YourContentWidget(),
/// )
/// ```
class MorphingNavigationScaffold extends StatefulWidget {
  /// The navigation items to display
  final List<NavItem> items;

  /// The main content widget (use either [child] or [pages], not both)
  final Widget? child;

  /// Map of page IDs to page widgets for automatic page switching.
  /// When provided, the scaffold will automatically display the page
  /// matching the selected navigation item ID.
  /// Use either [child] or [pages], not both.
  final Map<String, Widget>? pages;

  /// The type of transition animation when switching pages.
  /// Only applies when [pages] is used.
  final PageTransitionType pageTransitionType;

  /// Duration of the page transition animation.
  /// Only applies when [pages] is used and [pageTransitionType] is not [PageTransitionType.none].
  final Duration pageTransitionDuration;

  /// Optional theme configuration
  final MorphingNavigationTheme? theme;

  /// Optional header configuration
  final MorphingNavHeader? header;

  /// Optional footer configuration
  final MorphingNavFooter? footer;

  /// Initially selected item ID
  final String? initialSelectedId;

  /// Initially expanded section IDs
  final Set<String>? initialExpandedSections;

  /// Initial navigation mode
  final MorphingNavigationMode initialMode;

  /// Callback when an item is selected
  final void Function(String itemId)? onItemSelected;

  /// Callback when the navigation mode changes
  final void Function(MorphingNavigationMode mode)? onModeChanged;

  /// Whether to enable keyboard shortcuts (press 'T' to toggle mode)
  final bool enableKeyboardShortcuts;

  /// Whether to show the header
  final bool showHeader;

  /// Whether to show the footer
  final bool showFooter;

  /// System status to display in the navigation
  /// Shows CPU, memory, disk usage, time, warnings, and user name
  final SystemStatus? status;

  /// Whether to show a page header with icon and title in the content area.
  /// This is especially useful in tab bar mode where navigation shows only icons.
  /// The header automatically displays the current page's icon and label.
  /// Only applies when [pages] is used.
  final bool showPageHeader;

  /// Creates a morphing navigation scaffold with a single child widget.
  const MorphingNavigationScaffold({
    super.key,
    required this.items,
    required Widget this.child,
    this.theme,
    this.header,
    this.footer,
    this.initialSelectedId,
    this.initialExpandedSections,
    this.initialMode = MorphingNavigationMode.sidebar,
    this.onItemSelected,
    this.onModeChanged,
    this.enableKeyboardShortcuts = true,
    this.showHeader = true,
    this.showFooter = true,
    this.status,
  })  : pages = null,
        pageTransitionType = PageTransitionType.none,
        pageTransitionDuration = const Duration(milliseconds: 300),
        showPageHeader = false;

  /// Creates a morphing navigation scaffold with automatic page switching.
  ///
  /// The [pages] map should contain entries where keys match the navigation
  /// item IDs and values are the corresponding page widgets.
  const MorphingNavigationScaffold.withPages({
    super.key,
    required this.items,
    required Map<String, Widget> this.pages,
    this.pageTransitionType = PageTransitionType.fade,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.showPageHeader = false,
    this.theme,
    this.header,
    this.footer,
    this.initialSelectedId,
    this.initialExpandedSections,
    this.initialMode = MorphingNavigationMode.sidebar,
    this.onItemSelected,
    this.onModeChanged,
    this.enableKeyboardShortcuts = true,
    this.showHeader = true,
    this.showFooter = true,
    this.status,
  })  : child = null,
        assert(pages.length > 0, 'pages map must not be empty');

  @override
  State<MorphingNavigationScaffold> createState() => _MorphingNavigationScaffoldState();
}

class _MorphingNavigationScaffoldState extends State<MorphingNavigationScaffold>
    with TickerProviderStateMixin {
  late MorphingNavigationController _controller;
  late _LegacyProviderAdapter _legacyProvider;
  final FocusNode _focusNode = FocusNode();
  late AnimationController _paddingController;
  late Animation<double> _paddingAnimation;
  late AnimationController _scrimController;
  MorphingNavigationMode? _previousMode;
  bool _wasOverlay = false;

  MorphingNavigationTheme get _theme => widget.theme ?? const MorphingNavigationTheme();

  @override
  void initState() {
    super.initState();
    _controller = MorphingNavigationController(
      items: widget.items,
      initialSelectedId: widget.initialSelectedId,
      initialExpandedSections: widget.initialExpandedSections,
      initialMode: widget.initialMode,
      onItemSelected: widget.onItemSelected,
      onModeChanged: widget.onModeChanged,
      theme: _theme,
      showHeader: widget.showHeader,
      showFooter: widget.showFooter,
      header: widget.header,
      footer: widget.footer,
    );

    // Create the legacy provider adapter once in initState
    _legacyProvider = _LegacyProviderAdapter(_controller);

    // Set initial status if provided
    if (widget.status != null) {
      _controller.setStatus(widget.status);
    }

    _paddingController = AnimationController(
      vsync: this,
      duration: _theme.modeTransitionDuration,
    );
    _paddingAnimation = Tween<double>(
      begin: _theme.sidebarWidth,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _paddingController,
      curve: _theme.modeTransitionCurve,
    ));

    // Set initial padding state
    if (_controller.isTabBarMode) {
      _paddingController.value = 1.0;
    }

    _scrimController = AnimationController(
      vsync: this,
      duration: _theme.modeTransitionDuration,
    );

  }

  @override
  void didUpdateWidget(MorphingNavigationScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update theme if changed
    if (widget.theme != oldWidget.theme) {
      _controller.setTheme(_theme);
    }

    // Update status if changed
    if (widget.status != oldWidget.status) {
      _controller.setStatus(widget.status);
    }

    // Update header/footer visibility
    if (widget.showHeader != oldWidget.showHeader) {
      _controller.setShowHeader(widget.showHeader);
    }
    if (widget.showFooter != oldWidget.showFooter) {
      _controller.setShowFooter(widget.showFooter);
    }
    if (widget.header != oldWidget.header) {
      _controller.setHeader(widget.header);
    }
    if (widget.footer != oldWidget.footer) {
      _controller.setFooter(widget.footer);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _paddingController.dispose();
    _scrimController.dispose();
    _legacyProvider.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleKeyPress(KeyEvent event) {
    if (!widget.enableKeyboardShortcuts) return;

    // Toggle mode on 'T' key press
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.keyT)) {
      _controller.toggleMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update screen width for responsive behavior
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final width = MediaQuery.of(context).size.width;
      _controller.updateScreenWidth(width);
    });

    return ChangeNotifierProvider<NavigationProvider>.value(
      value: _legacyProvider,
      child: MorphingNavigationThemeProvider(
        theme: _theme,
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            // Handle mode changes
            if (_previousMode == null) {
              _previousMode = _controller.mode;
            } else if (_previousMode != _controller.mode) {
              if (_controller.isTabBarMode) {
                if (_wasOverlay) {
                  // Was overlay → no padding to animate, just hide scrim
                  _paddingController.value = 1.0;
                  _scrimController.reverse();
                } else {
                  // Was push sidebar → animate padding back
                  _paddingController.forward();
                }
              } else {
                if (_controller.isOverlay) {
                  // Overlay sidebar → keep content full-width, show scrim
                  _paddingController.value = 1.0;
                  _scrimController.forward();
                } else {
                  // Push sidebar → animate padding
                  _paddingController.reverse();
                }
              }
              _wasOverlay = _controller.isOverlay;
              _previousMode = _controller.mode;
            }

            // Determine the content widget (child or page container)
            final contentWidget = widget.pages != null
                ? _PageContainer(
                    pages: widget.pages!,
                    items: widget.items,
                    selectedItemId: _controller.selectedItemId,
                    transitionType: widget.pageTransitionType,
                    transitionDuration: widget.pageTransitionDuration,
                    showPageHeader: widget.showPageHeader,
                  )
                : widget.child!;

            return KeyboardListener(
              focusNode: _focusNode,
              autofocus: true,
              onKeyEvent: _handleKeyPress,
              child: Stack(
                children: [
                  // Main content with animated left padding
                  AnimatedBuilder(
                    animation: _paddingAnimation,
                    builder: (context, child) {
                      return Padding(
                        padding: EdgeInsets.only(
                          left: _paddingAnimation.value,
                        ),
                        child: contentWidget,
                      );
                    },
                  ),
                  // Scrim for overlay sidebar
                  AnimatedBuilder(
                    animation: _scrimController,
                    builder: (context, _) {
                      if (_scrimController.value <= 0) {
                        return const SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: () => _controller.dismissOverlay(),
                        child: Container(
                          color: Colors.black.withValues(
                            alpha: 0.4 * _scrimController.value,
                          ),
                        ),
                      );
                    },
                  ),
                  // Morphing navigation
                  const Positioned.fill(
                    child: internal.MorphingNavigation(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Adapter that makes MorphingNavigationController work with widgets
/// that expect NavigationProvider
class _LegacyProviderAdapter extends NavigationProvider {
  final MorphingNavigationController _controller;

  _LegacyProviderAdapter(this._controller) {
    // Listen to controller changes and notify
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  List<NavItem> get items => _controller.items;

  @override
  MorphingNavigationMode get mode => _controller.mode;

  @override
  bool get isTabBarMode => _controller.isTabBarMode;

  @override
  bool get isSidebarMode => _controller.isSidebarMode;

  @override
  bool get isOverlay => _controller.isOverlay;

  @override
  String get selectedItemId => _controller.selectedItemId;

  @override
  Set<String> get expandedSections => _controller.expandedSections;

  @override
  double get screenWidth => _controller.screenWidth;

  @override
  TabBarPosition get tabBarPosition => _controller.tabBarPosition;

  @override
  bool get shouldAutoSwitchToTabBar => _controller.shouldAutoSwitchToTabBar;

  @override
  double get contentPadding => _controller.contentPadding;

  @override
  void toggleMode() => _controller.toggleMode();

  @override
  void setMode(MorphingNavigationMode newMode) => _controller.setMode(newMode);

  @override
  void updateScreenWidth(double width) => _controller.updateScreenWidth(width);

  @override
  void resetUserOverride() => _controller.resetUserOverride();

  @override
  void dismissOverlay() => _controller.dismissOverlay();

  @override
  void toggleSection(String sectionId) => _controller.toggleSection(sectionId);

  @override
  bool isSectionExpanded(String sectionId) => _controller.isSectionExpanded(sectionId);

  @override
  void expandSection(String sectionId) => _controller.expandSection(sectionId);

  @override
  void collapseSection(String sectionId) => _controller.collapseSection(sectionId);

  @override
  void selectItem(String itemId) => _controller.selectItem(itemId);

  @override
  bool isItemSelected(String itemId) => _controller.isItemSelected(itemId);

  @override
  String? findParentSection(String itemId) => _controller.findParentSection(itemId);

  @override
  bool hasSelectedChild(String sectionId) => _controller.hasSelectedChild(sectionId);

  @override
  SystemStatus? get status => _controller.status;

  @override
  void setStatus(SystemStatus? status) => _controller.setStatus(status);

  @override
  bool get showHeader => _controller.showHeader;

  @override
  bool get showFooter => _controller.showFooter;

  @override
  MorphingNavHeader? get header => _controller.header;

  @override
  MorphingNavFooter? get footer => _controller.footer;
}

/// Internal widget that handles automatic page switching based on navigation selection
class _PageContainer extends StatelessWidget {
  final Map<String, Widget> pages;
  final List<NavItem> items;
  final String selectedItemId;
  final PageTransitionType transitionType;
  final Duration transitionDuration;
  final bool showPageHeader;

  const _PageContainer({
    required this.pages,
    required this.items,
    required this.selectedItemId,
    required this.transitionType,
    required this.transitionDuration,
    required this.showPageHeader,
  });

  /// Find the NavItem matching the selected ID (including children)
  NavItem? _findNavItem(String itemId) {
    for (final item in items) {
      if (item.id == itemId) return item;
      if (item.hasChildren) {
        for (final child in item.children!) {
          if (child.id == itemId) return child;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Get the page for the selected item, or fall back to first page
    final page = pages[selectedItemId] ?? pages.values.first;

    // Determine page wrapping based on mode
    Widget pageContent;
    if (showPageHeader) {
      final navProvider = Provider.of<NavigationProvider>(context);
      final isTopTabBar = navProvider.isTabBarMode &&
          navProvider.tabBarPosition == TabBarPosition.top;

      if (isTopTabBar) {
        // Top tab bar mode: hide page header, inject tab bar safe area
        // so pages that respect MediaQuery.padding.top will add scroll padding.
        // Content can then scroll behind the glass tab bar.
        final theme = MorphingNavigationThemeProvider.of(context);
        final tabBarAreaHeight = 16.0 + theme.tabBarHeight + 20.0;
        final existingData = MediaQuery.of(context);
        pageContent = MediaQuery(
          data: existingData.copyWith(
            padding: existingData.padding.copyWith(
              top: existingData.padding.top + tabBarAreaHeight,
            ),
          ),
          child: page,
        );
      } else {
        // Sidebar or bottom tab bar: show page header as normal
        pageContent = _buildPageWithHeader(context, page);
      }
    } else {
      pageContent = page;
    }

    // If no transition, just return the page directly
    if (transitionType == PageTransitionType.none) {
      return KeyedSubtree(
        key: ValueKey(selectedItemId),
        child: pageContent,
      );
    }

    // Use AnimatedSwitcher for transitions
    return AnimatedSwitcher(
      duration: transitionDuration,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return _buildTransition(child, animation);
      },
      child: KeyedSubtree(
        key: ValueKey(selectedItemId),
        child: pageContent,
      ),
    );
  }

  Widget _buildPageWithHeader(BuildContext context, Widget page) {
    final navItem = _findNavItem(selectedItemId);
    if (navItem == null) return page;

    final color = navItem.iconColor ?? Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header — sized to match tab bar area (16+44+16=76 + _Page's 8px ≈ tab bar mode)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(navItem.icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Text(
                  navItem.label,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Page content
          Expanded(child: page),
        ],
      ),
    );
  }

  Widget _buildTransition(Widget child, Animation<double> animation) {
    switch (transitionType) {
      case PageTransitionType.none:
        return child;

      case PageTransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );

      case PageTransitionType.slideHorizontal:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case PageTransitionType.slideVertical:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
          child: child,
        );

      case PageTransitionType.scaleDown:
        return ScaleTransition(
          scale: Tween<double>(begin: 1.2, end: 1.0).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );

      case PageTransitionType.fadeSlideHorizontal:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );

      case PageTransitionType.fadeSlideVertical:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );

      case PageTransitionType.fadeScale:
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
            child: child,
          ),
        );

      case PageTransitionType.rotation:
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final angle = (1 - animation.value) * math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: child,
            );
          },
        );

      case PageTransitionType.cubeRotation:
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final angle = (1 - animation.value) * math.pi / 2;
            return Transform(
              alignment: Alignment.centerLeft,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(angle),
              child: child,
            );
          },
        );

      case PageTransitionType.fadeThrough:
        // Material fade-through: new page fades in + scales up
        final fadeIn = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
        );
        final scaleIn = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );
        return FadeTransition(
          opacity: fadeIn,
          child: ScaleTransition(
            scale: scaleIn,
            child: child,
          ),
        );

      case PageTransitionType.sharedAxisHorizontal:
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: const Interval(0.3, 1.0),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );

      case PageTransitionType.sharedAxisVertical:
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: const Interval(0.3, 1.0),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.15),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
    }
  }
}
