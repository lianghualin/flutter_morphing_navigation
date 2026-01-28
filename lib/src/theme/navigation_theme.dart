import 'package:flutter/material.dart';

/// Configuration class for customizing the morphing navigation appearance.
///
/// This class provides all the visual customization options for the
/// morphing navigation widget, including colors, dimensions, animations,
/// and responsive breakpoints.
///
/// Example usage:
/// ```dart
/// MorphingNavigationTheme(
///   primaryColor: Colors.blue,
///   sidebarWidth: 280.0,
///   modeTransitionDuration: Duration(milliseconds: 500),
/// )
/// ```
class MorphingNavigationTheme {
  // Primary colors
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  // Status colors
  final Color successColor;
  final Color warningColor;
  final Color errorColor;

  // Background colors
  final Color backgroundColor;
  final Color sidebarBackgroundColor;
  final Color tabBarBackgroundColor;

  // Border colors
  final Color borderColor;
  final Color dividerColor;

  // Text colors
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color textOnPrimaryColor;

  // Item colors
  final Color itemHoverColor;
  final Color itemSelectedColor;

  // Glassmorphism settings
  final Color glassBackgroundColor;
  final Color glassBorderColor;
  final double glassBlurRadius;

  // Gradients
  final Gradient? primaryGradient;
  final Gradient? selectedItemGradient;

  // Dimensions
  final double sidebarWidth;
  final double tabBarHeight;
  final double tabBarItemWidth;
  final double tabBarBorderRadius;
  final double itemHeight;
  final double itemSpacing;
  final double itemBorderRadius;
  final double headerHeight;
  final double footerHeight;

  // Responsive breakpoints
  final double breakpointLarge;
  final double breakpointMedium;
  final double compactBreakpoint;

  // Animation settings
  final Duration modeTransitionDuration;
  final Duration accordionDuration;
  final Duration dropdownDuration;
  final Duration hoverDuration;
  final Curve modeTransitionCurve;
  final Curve accordionCurve;
  final Curve dropdownCurve;

  // Shadows
  final List<BoxShadow>? cardShadow;
  final List<BoxShadow>? dropdownShadow;
  final List<BoxShadow>? tabBarShadow;

  const MorphingNavigationTheme({
    // Primary colors
    this.primaryColor = const Color(0xFF007AFF),
    this.secondaryColor = const Color(0xFF5856D6),
    this.accentColor = const Color(0xFF5AC8FA),

    // Status colors
    this.successColor = const Color(0xFF34C759),
    this.warningColor = const Color(0xFFFF9500),
    this.errorColor = const Color(0xFFFF3B30),

    // Background colors
    this.backgroundColor = const Color(0xFFF5F5F7),
    this.sidebarBackgroundColor = Colors.white,
    this.tabBarBackgroundColor = const Color(0xDDFFFFFF),

    // Border colors
    this.borderColor = const Color(0xFFE5E5EA),
    this.dividerColor = const Color(0xFFE5E5EA),

    // Text colors
    this.textPrimaryColor = const Color(0xFF1D1D1F),
    this.textSecondaryColor = const Color(0xFF86868B),
    this.textOnPrimaryColor = Colors.white,

    // Item colors
    this.itemHoverColor = const Color(0xFFE8E8ED),
    this.itemSelectedColor = const Color(0xFF007AFF),

    // Glassmorphism settings
    this.glassBackgroundColor = const Color(0xDDFFFFFF),
    this.glassBorderColor = const Color(0x33FFFFFF),
    this.glassBlurRadius = 20.0,

    // Gradients
    this.primaryGradient,
    this.selectedItemGradient,

    // Dimensions
    this.sidebarWidth = 260.0,
    this.tabBarHeight = 64.0,
    this.tabBarItemWidth = 72.0,
    this.tabBarBorderRadius = 32.0,
    this.itemHeight = 46.0,
    this.itemSpacing = 4.0,
    this.itemBorderRadius = 10.0,
    this.headerHeight = 80.0,
    this.footerHeight = 80.0,

    // Responsive breakpoints
    this.breakpointLarge = 1024.0,
    this.breakpointMedium = 768.0,
    this.compactBreakpoint = 600.0,

    // Animation settings
    this.modeTransitionDuration = const Duration(milliseconds: 400),
    this.accordionDuration = const Duration(milliseconds: 300),
    this.dropdownDuration = const Duration(milliseconds: 200),
    this.hoverDuration = const Duration(milliseconds: 200),
    this.modeTransitionCurve = Curves.easeInOutCubic,
    this.accordionCurve = Curves.easeInOut,
    this.dropdownCurve = Curves.easeOut,

    // Shadows
    this.cardShadow,
    this.dropdownShadow,
    this.tabBarShadow,
  });

  /// Default primary gradient (blue to purple)
  Gradient get effectivePrimaryGradient =>
      primaryGradient ??
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor, secondaryColor],
      );

  /// Default selected item gradient
  Gradient get effectiveSelectedItemGradient =>
      selectedItemGradient ??
      LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [primaryColor, secondaryColor],
      );

  /// Default card shadow
  List<BoxShadow> get effectiveCardShadow =>
      cardShadow ??
      [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  /// Default dropdown shadow
  List<BoxShadow> get effectiveDropdownShadow =>
      dropdownShadow ??
      [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ];

  /// Default tab bar shadow (more prominent for floating effect)
  List<BoxShadow> get effectiveTabBarShadow =>
      tabBarShadow ??
      [
        // Primary shadow - larger, softer
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 40,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
        // Secondary shadow - closer, sharper
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        ),
      ];

  /// Creates a copy of this theme with the given fields replaced.
  MorphingNavigationTheme copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
    Color? backgroundColor,
    Color? sidebarBackgroundColor,
    Color? tabBarBackgroundColor,
    Color? borderColor,
    Color? dividerColor,
    Color? textPrimaryColor,
    Color? textSecondaryColor,
    Color? textOnPrimaryColor,
    Color? itemHoverColor,
    Color? itemSelectedColor,
    Color? glassBackgroundColor,
    Color? glassBorderColor,
    double? glassBlurRadius,
    Gradient? primaryGradient,
    Gradient? selectedItemGradient,
    double? sidebarWidth,
    double? tabBarHeight,
    double? tabBarItemWidth,
    double? tabBarBorderRadius,
    double? itemHeight,
    double? itemSpacing,
    double? itemBorderRadius,
    double? headerHeight,
    double? footerHeight,
    double? breakpointLarge,
    double? breakpointMedium,
    double? compactBreakpoint,
    Duration? modeTransitionDuration,
    Duration? accordionDuration,
    Duration? dropdownDuration,
    Duration? hoverDuration,
    Curve? modeTransitionCurve,
    Curve? accordionCurve,
    Curve? dropdownCurve,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? dropdownShadow,
    List<BoxShadow>? tabBarShadow,
  }) {
    return MorphingNavigationTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      sidebarBackgroundColor: sidebarBackgroundColor ?? this.sidebarBackgroundColor,
      tabBarBackgroundColor: tabBarBackgroundColor ?? this.tabBarBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
      dividerColor: dividerColor ?? this.dividerColor,
      textPrimaryColor: textPrimaryColor ?? this.textPrimaryColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
      textOnPrimaryColor: textOnPrimaryColor ?? this.textOnPrimaryColor,
      itemHoverColor: itemHoverColor ?? this.itemHoverColor,
      itemSelectedColor: itemSelectedColor ?? this.itemSelectedColor,
      glassBackgroundColor: glassBackgroundColor ?? this.glassBackgroundColor,
      glassBorderColor: glassBorderColor ?? this.glassBorderColor,
      glassBlurRadius: glassBlurRadius ?? this.glassBlurRadius,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      selectedItemGradient: selectedItemGradient ?? this.selectedItemGradient,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      tabBarHeight: tabBarHeight ?? this.tabBarHeight,
      tabBarItemWidth: tabBarItemWidth ?? this.tabBarItemWidth,
      tabBarBorderRadius: tabBarBorderRadius ?? this.tabBarBorderRadius,
      itemHeight: itemHeight ?? this.itemHeight,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      itemBorderRadius: itemBorderRadius ?? this.itemBorderRadius,
      headerHeight: headerHeight ?? this.headerHeight,
      footerHeight: footerHeight ?? this.footerHeight,
      breakpointLarge: breakpointLarge ?? this.breakpointLarge,
      breakpointMedium: breakpointMedium ?? this.breakpointMedium,
      compactBreakpoint: compactBreakpoint ?? this.compactBreakpoint,
      modeTransitionDuration: modeTransitionDuration ?? this.modeTransitionDuration,
      accordionDuration: accordionDuration ?? this.accordionDuration,
      dropdownDuration: dropdownDuration ?? this.dropdownDuration,
      hoverDuration: hoverDuration ?? this.hoverDuration,
      modeTransitionCurve: modeTransitionCurve ?? this.modeTransitionCurve,
      accordionCurve: accordionCurve ?? this.accordionCurve,
      dropdownCurve: dropdownCurve ?? this.dropdownCurve,
      cardShadow: cardShadow ?? this.cardShadow,
      dropdownShadow: dropdownShadow ?? this.dropdownShadow,
      tabBarShadow: tabBarShadow ?? this.tabBarShadow,
    );
  }

  /// Light theme preset
  static const MorphingNavigationTheme light = MorphingNavigationTheme();

  /// Dark theme preset
  static const MorphingNavigationTheme dark = MorphingNavigationTheme(
    primaryColor: Color(0xFF0A84FF),
    secondaryColor: Color(0xFF5E5CE6),
    accentColor: Color(0xFF64D2FF),
    successColor: Color(0xFF30D158),
    warningColor: Color(0xFFFFD60A),
    errorColor: Color(0xFFFF453A),
    backgroundColor: Color(0xFF1C1C1E),
    sidebarBackgroundColor: Color(0xFF2C2C2E),
    tabBarBackgroundColor: Color(0xDD2C2C2E),
    borderColor: Color(0xFF3A3A3C),
    dividerColor: Color(0xFF3A3A3C),
    textPrimaryColor: Color(0xFFFFFFFF),
    textSecondaryColor: Color(0xFF98989D),
    textOnPrimaryColor: Colors.white,
    itemHoverColor: Color(0xFF3A3A3C),
    itemSelectedColor: Color(0xFF0A84FF),
    glassBackgroundColor: Color(0xDD2C2C2E),
    glassBorderColor: Color(0x33FFFFFF),
  );
}

/// InheritedWidget to provide theme down the widget tree
class MorphingNavigationThemeProvider extends InheritedWidget {
  final MorphingNavigationTheme theme;

  const MorphingNavigationThemeProvider({
    super.key,
    required this.theme,
    required super.child,
  });

  static MorphingNavigationTheme of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<MorphingNavigationThemeProvider>();
    return provider?.theme ?? const MorphingNavigationTheme();
  }

  static MorphingNavigationTheme? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<MorphingNavigationThemeProvider>();
    return provider?.theme;
  }

  @override
  bool updateShouldNotify(MorphingNavigationThemeProvider oldWidget) {
    return theme != oldWidget.theme;
  }
}
