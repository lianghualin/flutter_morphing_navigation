import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color primaryPurple = Color(0xFF5856D6);
  static const Color primaryGreen = Color(0xFF34C759);
  static const Color primaryOrange = Color(0xFFFF9500);
  static const Color primaryRed = Color(0xFFFF3B30);
  static const Color primaryPink = Color(0xFFFF2D55);
  static const Color primaryTeal = Color(0xFF5AC8FA);

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color backgroundDark = Color(0xFF1C1C1E);

  // Sidebar colors
  static const Color sidebarBackground = Colors.white;
  static const Color sidebarBorder = Color(0xFFE5E5EA);
  static const Color sidebarItemHover = Color(0xFFF5F5F7);

  // Text colors
  static const Color textPrimary = Color(0xFF1D1D1F);
  static const Color textSecondary = Color(0xFF86868B);
  static const Color textLight = Colors.white;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryPurple],
  );

  static const LinearGradient activeItemGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryBlue, Color(0xFF5856D6)],
  );

  // Glassmorphism
  static const Color glassBackground = Color(0xDDFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const double glassBlur = 20.0;

  // Animation durations
  static const Duration modeTransitionDuration = Duration(milliseconds: 400);
  static const Duration accordionDuration = Duration(milliseconds: 300);
  static const Duration dropdownDuration = Duration(milliseconds: 200);
  static const Duration hoverDuration = Duration(milliseconds: 200);

  // Animation curves
  static const Curve modeTransitionCurve = Curves.easeInOutCubic;
  static const Curve accordionCurve = Curves.easeInOut;
  static const Curve dropdownCurve = Curves.easeOut;

  // Dimensions
  static const double sidebarWidth = 260.0;
  static const double sidebarCollapsedWidth = 0.0;
  static const double tabBarHeight = 64.0;
  static const double tabBarItemWidth = 72.0;
  static const double tabBarBorderRadius = 32.0;

  // Breakpoints
  static const double breakpointLarge = 1024.0;
  static const double breakpointMedium = 768.0;

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> dropdownShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];

  // Theme data
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: backgroundLight,
        fontFamily: '.SF Pro Text',
      );
}
