import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morphing_navigation/morphing_navigation.dart';

void main() {
  group('NavItem', () {
    test('creates item correctly', () {
      const item = NavItem(
        id: 'test',
        label: 'Test Item',
        icon: Icons.home,
      );

      expect(item.id, 'test');
      expect(item.label, 'Test Item');
      expect(item.hasChildren, false);
    });

    test('with children works correctly', () {
      const item = NavItem(
        id: 'parent',
        label: 'Parent',
        icon: Icons.folder,
        children: [
          NavItem(id: 'child1', label: 'Child 1', icon: Icons.file_copy),
          NavItem(id: 'child2', label: 'Child 2', icon: Icons.file_copy),
        ],
      );

      expect(item.hasChildren, true);
      expect(item.children!.length, 2);
    });

    test('defaultItems provides navigation items', () {
      final items = NavItem.defaultItems;
      expect(items.isNotEmpty, true);
      expect(items.first.id, 'home');
    });
  });

  group('NavigationProvider', () {
    test('initial state is sidebar mode', () {
      final provider = NavigationProvider();
      expect(provider.isSidebarMode, true);
      expect(provider.isTabBarMode, false);
      expect(provider.selectedItemId, 'home');
    });

    test('toggleMode switches between modes', () {
      final provider = NavigationProvider();

      provider.toggleMode();
      expect(provider.isTabBarMode, true);
      expect(provider.isSidebarMode, false);

      provider.toggleMode();
      expect(provider.isSidebarMode, true);
      expect(provider.isTabBarMode, false);
    });

    test('selectItem updates selected item', () {
      final provider = NavigationProvider();

      provider.selectItem('settings');
      expect(provider.selectedItemId, 'settings');

      provider.selectItem('home');
      expect(provider.selectedItemId, 'home');
    });

    test('section expansion works', () {
      final provider = NavigationProvider();

      // Library section should be expanded by default
      expect(provider.isSectionExpanded('library'), true);

      // Toggle section
      provider.toggleSection('library');
      expect(provider.isSectionExpanded('library'), false);

      // Expand explicitly
      provider.expandSection('library');
      expect(provider.isSectionExpanded('library'), true);

      // Collapse explicitly
      provider.collapseSection('library');
      expect(provider.isSectionExpanded('library'), false);
    });

    test('hasSelectedChild works correctly', () {
      final provider = NavigationProvider();

      // Select a child item under 'library'
      provider.selectItem('photos');
      expect(provider.hasSelectedChild('library'), true);

      // Select a non-child item
      provider.selectItem('home');
      expect(provider.hasSelectedChild('library'), false);
    });

    test('findParentSection returns correct parent', () {
      final provider = NavigationProvider();

      expect(provider.findParentSection('photos'), 'library');
      expect(provider.findParentSection('home'), null);
    });
  });

  group('AppTheme', () {
    test('provides required dimensions', () {
      expect(AppTheme.sidebarWidth, 260.0);
      expect(AppTheme.tabBarHeight, 64.0);
      expect(AppTheme.breakpointLarge, 1024.0);
    });

    test('provides animation durations', () {
      expect(AppTheme.modeTransitionDuration, isA<Duration>());
      expect(AppTheme.accordionDuration, isA<Duration>());
    });
  });
}
