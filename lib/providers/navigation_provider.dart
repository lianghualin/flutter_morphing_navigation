import 'package:flutter/material.dart';
import '../models/nav_item.dart';
import '../theme/app_theme.dart';

enum NavigationMode {
  sidebar,
  tabBar,
}

enum TabBarPosition {
  top,
  bottom,
}

class NavigationProvider extends ChangeNotifier {
  NavigationMode _mode = NavigationMode.sidebar;
  String _selectedItemId = 'home';
  final Set<String> _expandedSections = {'library'};
  bool _isUserOverride = false;
  double _screenWidth = 1200;

  // Navigation items
  final List<NavItem> items = NavItem.defaultItems;

  // Getters
  NavigationMode get mode => _mode;
  bool get isTabBarMode => _mode == NavigationMode.tabBar;
  bool get isSidebarMode => _mode == NavigationMode.sidebar;
  String get selectedItemId => _selectedItemId;
  Set<String> get expandedSections => _expandedSections;
  double get screenWidth => _screenWidth;

  // Computed properties
  TabBarPosition get tabBarPosition {
    if (_screenWidth < AppTheme.breakpointMedium) {
      return TabBarPosition.bottom;
    }
    return TabBarPosition.top;
  }

  bool get shouldAutoSwitchToTabBar {
    return _screenWidth < AppTheme.breakpointLarge;
  }

  double get contentPadding {
    if (isSidebarMode) {
      return AppTheme.sidebarWidth;
    }
    return 0;
  }

  // Toggle between modes
  void toggleMode() {
    _isUserOverride = true;
    _mode = _mode == NavigationMode.sidebar
        ? NavigationMode.tabBar
        : NavigationMode.sidebar;
    notifyListeners();
  }

  // Set specific mode
  void setMode(NavigationMode newMode) {
    if (_mode != newMode) {
      _mode = newMode;
      notifyListeners();
    }
  }

  // Update screen width and handle responsive mode changes
  void updateScreenWidth(double width) {
    _screenWidth = width;

    // Only auto-switch if user hasn't manually overridden
    if (!_isUserOverride) {
      if (width < AppTheme.breakpointLarge && _mode == NavigationMode.sidebar) {
        _mode = NavigationMode.tabBar;
        notifyListeners();
      } else if (width >= AppTheme.breakpointLarge &&
          _mode == NavigationMode.tabBar) {
        _mode = NavigationMode.sidebar;
        notifyListeners();
      }
    }
  }

  // Reset user override (for testing or special cases)
  void resetUserOverride() {
    _isUserOverride = false;
    updateScreenWidth(_screenWidth);
  }

  // Toggle section expansion (for accordion in sidebar)
  void toggleSection(String sectionId) {
    if (_expandedSections.contains(sectionId)) {
      _expandedSections.remove(sectionId);
    } else {
      _expandedSections.add(sectionId);
    }
    notifyListeners();
  }

  // Check if section is expanded
  bool isSectionExpanded(String sectionId) {
    return _expandedSections.contains(sectionId);
  }

  // Expand a section
  void expandSection(String sectionId) {
    if (!_expandedSections.contains(sectionId)) {
      _expandedSections.add(sectionId);
      notifyListeners();
    }
  }

  // Collapse a section
  void collapseSection(String sectionId) {
    if (_expandedSections.contains(sectionId)) {
      _expandedSections.remove(sectionId);
      notifyListeners();
    }
  }

  // Select a navigation item
  void selectItem(String itemId) {
    if (_selectedItemId != itemId) {
      _selectedItemId = itemId;
      notifyListeners();
    }
  }

  // Check if an item is selected
  bool isItemSelected(String itemId) {
    return _selectedItemId == itemId;
  }

  // Find parent section of an item (for highlighting parent when child is selected)
  String? findParentSection(String itemId) {
    for (final item in items) {
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

  // Check if any child of a section is selected
  bool hasSelectedChild(String sectionId) {
    final section = items.firstWhere(
      (item) => item.id == sectionId,
      orElse: () => const NavItem(id: '', label: '', icon: Icons.error),
    );

    if (!section.hasChildren) return false;

    return section.children!.any((child) => child.id == _selectedItemId);
  }
}
