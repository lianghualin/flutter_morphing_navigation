# Morphing Navigation

A Flutter package that provides an iPadOS-style adaptive navigation widget that smoothly morphs between sidebar and tab bar layouts with beautiful animations.

## Features

- **Smooth morphing animation** between sidebar and tab bar layouts
- **Responsive design** - automatically switches modes based on screen width
- **Customizable theme** - colors, dimensions, animations, and more
- **Configurable header and footer** in sidebar mode
- **Section support** with expandable/collapsible items
- **Badge support** for notification indicators
- **Glassmorphism effect** in tab bar mode
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

## API Reference

### MorphingNavigationScaffold

The main widget that provides the morphing navigation functionality.

| Property | Type | Description |
|----------|------|-------------|
| `items` | `List<NavItem>` | Required. The navigation items to display |
| `child` | `Widget` | Required. The main content widget |
| `theme` | `MorphingNavigationTheme?` | Optional theme configuration |
| `header` | `MorphingNavHeader?` | Optional header configuration |
| `footer` | `MorphingNavFooter?` | Optional footer configuration |
| `initialSelectedId` | `String?` | Initially selected item ID |
| `onItemSelected` | `Function(String)?` | Callback when an item is selected |
| `onModeChanged` | `Function(MorphingNavigationMode)?` | Callback when mode changes |

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

## Responsive Behavior

The navigation automatically switches between modes based on screen width:

| Screen Width | Default Mode |
|--------------|--------------|
| >= 1024px | Sidebar |
| < 1024px | Tab Bar (top) |
| < 768px | Tab Bar (bottom) |

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| T | Toggle between sidebar and tab bar modes |

## License

MIT License - see LICENSE for details.
