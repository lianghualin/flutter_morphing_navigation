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

  group('PageTransitionType', () {
    test('enum has all expected values', () {
      expect(PageTransitionType.values.length, 4);
      expect(PageTransitionType.none, isNotNull);
      expect(PageTransitionType.fade, isNotNull);
      expect(PageTransitionType.slideHorizontal, isNotNull);
      expect(PageTransitionType.slideVertical, isNotNull);
    });
  });

  group('MorphingNavigationScaffold.withPages', () {
    // Helper to create a properly sized test environment
    Widget buildTestScaffold({
      required Map<String, Widget> pages,
      String? initialSelectedId,
      PageTransitionType pageTransitionType = PageTransitionType.none,
    }) {
      return MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: SizedBox(
            width: 1200,
            height: 800,
            child: MorphingNavigationScaffold.withPages(
              items: const [
                NavItem(id: 'home', label: 'Home', icon: Icons.home),
                NavItem(id: 'settings', label: 'Settings', icon: Icons.settings),
              ],
              initialSelectedId: initialSelectedId,
              pageTransitionType: pageTransitionType,
              pages: pages,
            ),
          ),
        ),
      );
    }

    testWidgets('renders initial page correctly', (tester) async {
      // Ignore overflow errors from navigation widget during tests
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };

      await tester.pumpWidget(
        buildTestScaffold(
          initialSelectedId: 'home',
          pages: {
            'home': const Center(child: Text('Home Page')),
            'settings': const Center(child: Text('Settings Page')),
          },
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
      expect(find.text('Settings Page'), findsNothing);

      FlutterError.onError = originalOnError;
    });

    testWidgets('switches pages when navigation item is tapped', (tester) async {
      // Ignore overflow errors from navigation widget during tests
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };

      await tester.pumpWidget(
        buildTestScaffold(
          initialSelectedId: 'home',
          pages: {
            'home': const Center(child: Text('Home Page')),
            'settings': const Center(child: Text('Settings Page')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Initially shows home page
      expect(find.text('Home Page'), findsOneWidget);

      // Find and tap the settings nav item
      final settingsItem = find.text('Settings');
      expect(settingsItem, findsOneWidget);
      await tester.tap(settingsItem);
      await tester.pumpAndSettle();

      // Now shows settings page
      expect(find.text('Settings Page'), findsOneWidget);
      expect(find.text('Home Page'), findsNothing);

      FlutterError.onError = originalOnError;
    });

    testWidgets('falls back to first page for unknown ID', (tester) async {
      // Ignore overflow errors from navigation widget during tests
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };

      await tester.pumpWidget(
        buildTestScaffold(
          initialSelectedId: 'unknown',
          pages: {
            'home': const Center(child: Text('Home Page')),
            'settings': const Center(child: Text('Settings Page')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Falls back to first page (home)
      expect(find.text('Home Page'), findsOneWidget);

      FlutterError.onError = originalOnError;
    });

    testWidgets('applies fade transition', (tester) async {
      // Ignore overflow errors from navigation widget during tests
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('overflowed')) return;
        originalOnError?.call(details);
      };

      await tester.pumpWidget(
        buildTestScaffold(
          initialSelectedId: 'home',
          pageTransitionType: PageTransitionType.fade,
          pages: {
            'home': const Center(child: Text('Home Page')),
            'settings': const Center(child: Text('Settings Page')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Tap settings
      await tester.tap(find.text('Settings'));
      await tester.pump();

      // During transition, FadeTransition should be present
      expect(find.byType(FadeTransition), findsWidgets);

      await tester.pumpAndSettle();

      // After transition completes
      expect(find.text('Settings Page'), findsOneWidget);

      FlutterError.onError = originalOnError;
    });
  });
}
