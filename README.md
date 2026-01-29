# Morphing Navigation

A Flutter package that provides an iPadOS-style adaptive navigation widget that smoothly morphs between sidebar and tab bar layouts with beautiful animations.

## Features

- **Smooth morphing animation** between sidebar and tab bar layouts
- **Responsive design** - automatically switches modes based on screen width
- **Automatic page switching** - use `pages` map for built-in page management
- **Page transitions** - fade, slide horizontal, slide vertical animations
- **Customizable theme** - colors, dimensions, animations, and more
- **Configurable header and footer** in sidebar mode
- **Section support** with expandable/collapsible items
- **Badge support** for notification indicators
- **Glassmorphism effect** in tab bar mode
- **Icon-only tab bar** - clean icons with tooltip on hover
- **Automatic page header** - optional header showing current page icon and title
- **System status panel** - display CPU, memory, disk usage and more
- **Keyboard shortcuts** - press 'T' to toggle between modes

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  morphing_navigation: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Usage

```dart
import 'package:morphing_navigation/morphing_navigation.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MorphingNavigationScaffold(
        items: [
          NavItem(id: 'home', label: 'Home', icon: Icons.home),
          NavItem(id: 'search', label: 'Search', icon: Icons.search),
          NavItem(id: 'settings', label: 'Settings', icon: Icons.settings),
        ],
        onItemSelected: (itemId) {
          print('Selected: \$itemId');
        },
        child: YourContentWidget(),
      ),
    );
  }
}
```

### With Sections (Expandable Items)

```dart
MorphingNavigationScaffold(
  items: [
    NavItem(id: 'home', label: 'Home', icon: Icons.home),
    NavItem(
      id: 'library',
      label: 'Library',
      icon: Icons.photo_library,
      children: [
        NavItem(id: 'photos', label: 'Photos', icon: Icons.photo),
        NavItem(id: 'videos', label: 'Videos', icon: Icons.videocam),
        NavItem(id: 'albums', label: 'Albums', icon: Icons.photo_album),
      ],
    ),
    NavItem(id: 'settings', label: 'Settings', icon: Icons.settings),
  ],
  child: YourContentWidget(),
)
```

### Automatic Page Switching

Use `MorphingNavigationScaffold.withPages()` for automatic page management. The scaffold will automatically display the page matching the selected navigation item.

```dart
MorphingNavigationScaffold.withPages(
  items: [
    NavItem(id: 'home', label: 'Home', icon: Icons.home),
    NavItem(id: 'search', label: 'Search', icon: Icons.search),
    NavItem(id: 'settings', label: 'Settings', icon: Icons.settings),
  ],
  initialSelectedId: 'home',
  pageTransitionType: PageTransitionType.fade,
  showPageHeader: true,  // Automatically shows page icon and title
  pages: {
    'home': HomePage(),
    'search': SearchPage(),
    'settings': SettingsPage(),
  },
)
```

#### Page Header

When `showPageHeader: true` is set, the scaffold automatically displays a header at the top of each page showing the current navigation item's icon and label. This is especially useful in tab bar mode where the navigation only shows icons - users can always see which page they're on.

#### Page Transition Types

| Type | Description |
|------|-------------|
| `PageTransitionType.none` | Instant switch, no animation |
| `PageTransitionType.fade` | Fade in/out transition (default) |
| `PageTransitionType.slideHorizontal` | Slide left/right |
| `PageTransitionType.slideVertical` | Slide up/down |

### Custom Theme

```dart
MorphingNavigationScaffold(
  items: myItems,
  theme: MorphingNavigationTheme(
    primaryColor: Colors.purple,
    secondaryColor: Colors.pink,
    sidebarWidth: 280.0,
    tabBarHeight: 72.0,
    modeTransitionDuration: Duration(milliseconds: 500),
  ),
  child: YourContentWidget(),
)
```

### System Status Panel

Display system status information in the navigation sidebar.

```dart
MorphingNavigationScaffold(
  items: myItems,
  status: SystemStatus(
    cpuUsage: 45.0,
    memoryUsage: 62.0,
    diskUsage: 78.0,
    currentTime: DateTime.now(),
    userName: 'John Doe',
    warningCount: 3,
  ),
  child: YourContentWidget(),
)
```

## API Reference

### MorphingNavigationScaffold

The main widget that provides the morphing navigation functionality.

| Property | Type | Description |
|----------|------|-------------|
| `items` | `List<NavItem>` | Required. The navigation items to display |
| `child` | `Widget` | The main content widget (use `child` or `pages`, not both) |
| `pages` | `Map<String, Widget>` | Page widgets keyed by item ID (use with `.withPages()`) |
| `pageTransitionType` | `PageTransitionType` | Animation type for page switches (default: fade) |
| `pageTransitionDuration` | `Duration` | Duration of page transition (default: 300ms) |
| `showPageHeader` | `bool` | Show automatic page header with icon and title (default: false) |
| `theme` | `MorphingNavigationTheme?` | Optional theme configuration |
| `header` | `MorphingNavHeader?` | Optional header configuration |
| `footer` | `MorphingNavFooter?` | Optional footer configuration |
| `initialSelectedId` | `String?` | Initially selected item ID |
| `onItemSelected` | `Function(String)?` | Callback when an item is selected |
| `onModeChanged` | `Function(MorphingNavigationMode)?` | Callback when mode changes |
| `status` | `SystemStatus?` | System status to display in navigation |

### NavItem

Represents a navigation item.

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier for the item |
| `label` | `String` | Display label |
| `icon` | `IconData` | Icon to display |
| `iconColor` | `Color?` | Optional custom icon color |
| `children` | `List<NavItem>?` | Optional child items (creates a section) |
| `badge` | `String?` | Optional badge text |

### SystemStatus

System status information displayed in the navigation panel.

| Property | Type | Description |
|----------|------|-------------|
| `cpuUsage` | `double` | CPU usage percentage (0-100) |
| `memoryUsage` | `double` | Memory usage percentage (0-100) |
| `diskUsage` | `double` | Disk usage percentage (0-100) |
| `currentTime` | `DateTime` | Current time to display |
| `userName` | `String?` | Optional user name |
| `warningCount` | `int` | Number of warnings to show |

## Responsive Behavior

The navigation automatically switches between modes based on screen width:

| Screen Width | Default Mode |
|--------------|--------------|
| >= 1024px | Sidebar (with labels) |
| < 1024px | Tab Bar top (icons only, tooltip on hover) |
| < 768px | Tab Bar bottom (icons only, tooltip on hover) |

In tab bar mode, navigation items display as icons only for a cleaner look. Hover over an icon to see the page name in a tooltip.

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| T | Toggle between sidebar and tab bar modes |

## License

MIT License - see LICENSE for details.
