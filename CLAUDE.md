# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is `morphing_navigation`, a Flutter package that provides an iPadOS-style adaptive navigation widget. It morphs between a sidebar layout (for larger screens) and a tab bar layout (for smaller screens) with smooth animations.

## Build and Development Commands

```bash
# Get dependencies (run from project root)
flutter pub get

# Run the example app
cd example && flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze code
flutter analyze
```

## Architecture

### Package Structure

The package follows a standard pub.dev package structure with `lib/` containing the library code and `example/` containing a demo app.

### Key Components

**Entry Point** (`lib/morphing_navigation.dart`):
- Barrel file that exports all public APIs

**Controllers** (`lib/src/controller/`):
- `MorphingNavigationController`: Main controller managing navigation state (mode, selection, sections, responsive behavior). Extends `ChangeNotifier`.
- `NavigationProvider`: Legacy provider for backward compatibility with internal widgets.
- `_LegacyProviderAdapter`: Bridges the new controller with widgets expecting the old provider.

**Widgets** (`lib/src/widgets/`):
- `MorphingNavigationScaffold`: Main entry point widget. Wraps content with morphing navigation, handles keyboard shortcuts ('T' to toggle), and manages animations.
- `MorphingNavigation`: Internal widget rendering the actual navigation UI (sidebar or tab bar).
- `MorphingNavItem`: Individual navigation item widget.
- `NavigationHeader`: Configurable header for sidebar mode.
- `StatusPanel`: System status display (CPU, memory, disk, etc.).
- `AdaptiveNavigation`: Handles responsive switching.

**Models** (`lib/src/models/`):
- `NavItem`: Navigation item with id, label, icon, optional children (for sections), and badge support.
- `SystemStatus`: Status data model for the status panel.

**Theme** (`lib/src/theme/`):
- `MorphingNavigationTheme`: Comprehensive configuration class with colors, dimensions, breakpoints, animations, and shadows. Has `light` and `dark` presets.
- `MorphingNavigationThemeProvider`: InheritedWidget for theme propagation.
- `AppTheme`: Legacy theme constants.

### State Management

Uses `provider` package. `MorphingNavigationScaffold` creates a `MorphingNavigationController` and provides it via `ChangeNotifierProvider`. Internal widgets use `ListenableBuilder` and `Provider.of` to react to state changes.

### Responsive Behavior

Controlled by breakpoints in `MorphingNavigationTheme`:
- `breakpointLarge` (default 1024): Above this = sidebar, below = tab bar
- `breakpointMedium` (default 768): Above this = top tab bar, below = bottom tab bar

User can manually toggle mode with 'T' key, which sets `_isUserOverride` to prevent auto-switching.

### Animation System

Mode transitions use an `AnimationController` with `modeTransitionDuration` and `modeTransitionCurve` from theme. Content padding animates from `sidebarWidth` to 0 during transitions.

## Testing

Tests are in `test/widget_test.dart` covering:
- `NavItem` creation and children
- `NavigationProvider` state management
- `AppTheme` constants

Run with `flutter test`.
