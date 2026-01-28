import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controller/navigation_controller.dart';
import '../controller/navigation_provider.dart';
import '../models/nav_item.dart';
import '../theme/navigation_theme.dart';
import 'navigation_header.dart';
import 'morphing_navigation.dart' as internal;

/// A scaffold widget that provides morphing navigation functionality.
///
/// This is the main entry point for using the morphing navigation package.
/// It provides a complete navigation solution that morphs between sidebar
/// and tab bar layouts.
///
/// ## Basic Usage
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

  /// The main content widget
  final Widget child;

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

  /// Creates a morphing navigation scaffold.
  const MorphingNavigationScaffold({
    super.key,
    required this.items,
    required this.child,
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
  });

  @override
  State<MorphingNavigationScaffold> createState() => _MorphingNavigationScaffoldState();
}

class _MorphingNavigationScaffoldState extends State<MorphingNavigationScaffold>
    with SingleTickerProviderStateMixin {
  late MorphingNavigationController _controller;
  final FocusNode _focusNode = FocusNode();
  late AnimationController _paddingController;
  late Animation<double> _paddingAnimation;
  MorphingNavigationMode? _previousMode;

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
    );

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
  }

  @override
  void didUpdateWidget(MorphingNavigationScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update theme if changed
    if (widget.theme != oldWidget.theme) {
      _controller.setTheme(_theme);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _paddingController.dispose();
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
      value: _createLegacyProvider(),
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
                _paddingController.forward();
              } else {
                _paddingController.reverse();
              }
              _previousMode = _controller.mode;
            }

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
                        child: widget.child,
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

  /// Creates a legacy NavigationProvider for backward compatibility
  /// with the internal widgets that still use it
  NavigationProvider _createLegacyProvider() {
    // Create a wrapper that syncs with our controller
    return _LegacyProviderAdapter(_controller);
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
}
