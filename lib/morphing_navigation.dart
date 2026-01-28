/// A morphing navigation widget that smoothly transforms between
/// sidebar and tab bar layouts.
///
/// This library provides an iPadOS-style adaptive navigation that
/// morphs between a full sidebar (for larger screens) and a compact
/// tab bar (for smaller screens or when toggled).
library;

// Models
export 'src/models/nav_item.dart';

// Controller
export 'src/controller/navigation_provider.dart';
export 'src/controller/navigation_controller.dart';

// Theme
export 'src/theme/app_theme.dart';
export 'src/theme/navigation_theme.dart';

// Widgets
export 'src/widgets/adaptive_navigation.dart';
export 'src/widgets/morphing_navigation.dart';
export 'src/widgets/morphing_nav_item.dart';
export 'src/widgets/navigation_header.dart';
export 'src/widgets/morphing_scaffold.dart';
