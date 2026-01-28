import 'package:flutter/material.dart';
import '../models/nav_item.dart';
import '../models/system_status.dart';
import '../theme/navigation_theme.dart';

/// The mode of the navigation display
enum MorphingNavigationMode {
  sidebar,
  tabBar,
}

/// Position of the tab bar when in tabBar mode
enum TabBarPosition {
  top,
  bottom,
}

/// Callback type for item selection
typedef OnItemSelected = void Function(String itemId);

/// Callback type for mode changes
typedef OnModeChanged = void Function(MorphingNavigationMode mode);

/// Controller for the morphing navigation widget.
///
/// This controller manages the navigation state including:
/// - Current navigation mode (sidebar or tabBar)
/// - Selected item
/// - Expanded sections
/// - Responsive behavior
///
/// Example usage:
/// ```dart
/// final controller = MorphingNavigationController(
///   items: [
///     NavItem(id: 'home', label: 'Home', icon: Icons.home),
///     NavItem(id: 'settings', label: 'Settings', icon: Icons.settings),
///   ],
///   initialSelectedId: 'home',
///   onItemSelected: (id) => print('Selected: $id'),
/// );
/// ```
class MorphingNavigationController extends ChangeNotifier {
  /// Creates a navigation controller.
  ///
  /// [items] is required and defines the navigation structure.
  /// [initialSelectedId] sets the initially selected item (defaults to first item).
  /// [initialExpandedSections] sets which sections are expanded initially.
  /// [initialMode] sets the initial navigation mode.
  MorphingNavigationController({
    required List<NavItem> items,
    String? initialSelectedId,
    Set<String>? initialExpandedSections,
    MorphingNavigationMode initialMode = MorphingNavigationMode.sidebar,
    this.onItemSelected,
    this.onModeChanged,
    MorphingNavigationTheme? theme,
  })  : _items = items,
        _selectedItemId = initialSelectedId ?? (items.isNotEmpty ? items.first.id : ''),
        _expandedSections = initialExpandedSections ?? {},
        _mode = initialMode,
        _theme = theme ?? const MorphingNavigationTheme();

  final List<NavItem> _items;
  MorphingNavigationMode _mode;
  String _selectedItemId;
  final Set<String> _expandedSections;
  bool _isUserOverride = false;
  double _screenWidth = 1200;
  MorphingNavigationTheme _theme;
  SystemStatus? _status;

  /// Callback invoked when an item is selected
  final OnItemSelected? onItemSelected;

  /// Callback invoked when the navigation mode changes
  final OnModeChanged? onModeChanged;

  // Getters
  List<NavItem> get items => _items;
  MorphingNavigationMode get mode => _mode;
  bool get isTabBarMode => _mode == MorphingNavigationMode.tabBar;
  bool get isSidebarMode => _mode == MorphingNavigationMode.sidebar;
  String get selectedItemId => _selectedItemId;
  Set<String> get expandedSections => Set.unmodifiable(_expandedSections);
  double get screenWidth => _screenWidth;
  MorphingNavigationTheme get theme => _theme;
  SystemStatus? get status => _status;

  /// The position of the tab bar based on screen width
  TabBarPosition get tabBarPosition {
    if (_screenWidth < _theme.breakpointMedium) {
      return TabBarPosition.bottom;
    }
    return TabBarPosition.top;
  }

  /// Whether the navigation should automatically switch to tab bar mode
  bool get shouldAutoSwitchToTabBar {
    return _screenWidth < _theme.breakpointLarge;
  }

  /// The content padding based on current mode
  double get contentPadding {
    if (isSidebarMode) {
      return _theme.sidebarWidth;
    }
    return 0;
  }

  /// Updates the theme
  void setTheme(MorphingNavigationTheme theme) {
    if (_theme != theme) {
      _theme = theme;
      notifyListeners();
    }
  }

  /// Toggle between sidebar and tab bar modes
  void toggleMode() {
    _isUserOverride = true;
    _mode = _mode == MorphingNavigationMode.sidebar
        ? MorphingNavigationMode.tabBar
        : MorphingNavigationMode.sidebar;
    onModeChanged?.call(_mode);
    notifyListeners();
  }

  /// Set a specific navigation mode
  void setMode(MorphingNavigationMode newMode) {
    if (_mode != newMode) {
      _mode = newMode;
      onModeChanged?.call(_mode);
      notifyListeners();
    }
  }

  /// Update screen width and handle responsive mode changes
  void updateScreenWidth(double width) {
    _screenWidth = width;

    // Only auto-switch if user hasn't manually overridden
    if (!_isUserOverride) {
      if (width < _theme.breakpointLarge && _mode == MorphingNavigationMode.sidebar) {
        _mode = MorphingNavigationMode.tabBar;
        onModeChanged?.call(_mode);
        notifyListeners();
      } else if (width >= _theme.breakpointLarge &&
          _mode == MorphingNavigationMode.tabBar) {
        _mode = MorphingNavigationMode.sidebar;
        onModeChanged?.call(_mode);
        notifyListeners();
      }
    }
  }

  /// Reset user override to enable automatic mode switching
  void resetUserOverride() {
    _isUserOverride = false;
    updateScreenWidth(_screenWidth);
  }

  /// Toggle section expansion (for accordion in sidebar)
  void toggleSection(String sectionId) {
    if (_expandedSections.contains(sectionId)) {
      _expandedSections.remove(sectionId);
    } else {
      _expandedSections.add(sectionId);
    }
    notifyListeners();
  }

  /// Check if a section is expanded
  bool isSectionExpanded(String sectionId) {
    return _expandedSections.contains(sectionId);
  }

  /// Expand a section
  void expandSection(String sectionId) {
    if (!_expandedSections.contains(sectionId)) {
      _expandedSections.add(sectionId);
      notifyListeners();
    }
  }

  /// Collapse a section
  void collapseSection(String sectionId) {
    if (_expandedSections.contains(sectionId)) {
      _expandedSections.remove(sectionId);
      notifyListeners();
    }
  }

  /// Select a navigation item
  void selectItem(String itemId) {
    if (_selectedItemId != itemId) {
      _selectedItemId = itemId;
      onItemSelected?.call(itemId);
      notifyListeners();
    }
  }

  /// Check if an item is selected
  bool isItemSelected(String itemId) {
    return _selectedItemId == itemId;
  }

  /// Find the parent section of an item
  String? findParentSection(String itemId) {
    for (final item in _items) {
      if (item.hasChildren) {
        for (final child in item.children!) {
          if (child.id == itemId) {
            return item.id;
          }
        }
      }
    }
    return null;
  }

  /// Check if any child of a section is selected
  bool hasSelectedChild(String sectionId) {
    final section = _items.firstWhere(
      (item) => item.id == sectionId,
      orElse: () => const NavItem(id: '', label: '', icon: Icons.error),
    );

    if (!section.hasChildren) return false;

    return section.children!.any((child) => child.id == _selectedItemId);
  }

  /// Get a NavItem by its ID
  NavItem? getItemById(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
      if (item.hasChildren) {
        for (final child in item.children!) {
          if (child.id == id) return child;
        }
      }
    }
    return null;
  }

  /// Get the currently selected NavItem
  NavItem? get selectedItem => getItemById(_selectedItemId);

  /// Set the system status to display
  void setStatus(SystemStatus? status) {
    if (_status != status) {
      _status = status;
      notifyListeners();
    }
  }

  /// Update status without notifying listeners (for frequent updates)
  void updateStatusSilent(SystemStatus? status) {
    _status = status;
  }
}
