import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart' as nav;
import '../theme/app_theme.dart';
import 'morphing/morphing_navigation.dart';

class AdaptiveNavigation extends StatefulWidget {
  final Widget child;

  const AdaptiveNavigation({
    super.key,
    required this.child,
  });

  @override
  State<AdaptiveNavigation> createState() => _AdaptiveNavigationState();
}

class _AdaptiveNavigationState extends State<AdaptiveNavigation>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late AnimationController _paddingController;
  late Animation<double> _paddingAnimation;
  nav.NavigationMode? _previousMode;

  @override
  void initState() {
    super.initState();
    _paddingController = AnimationController(
      vsync: this,
      duration: AppTheme.modeTransitionDuration,
    );
    _paddingAnimation = Tween<double>(
      begin: AppTheme.sidebarWidth,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _paddingController,
      curve: AppTheme.modeTransitionCurve,
    ));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _paddingController.dispose();
    super.dispose();
  }

  void _handleKeyPress(KeyEvent event) {
    // Toggle mode on 'T' key press
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.keyT)) {
      context.read<nav.NavigationProvider>().toggleMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update screen width for responsive behavior
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final width = MediaQuery.of(context).size.width;
      context.read<nav.NavigationProvider>().updateScreenWidth(width);
    });

    return Consumer<nav.NavigationProvider>(
      builder: (context, navProvider, _) {
        // Initialize on first build
        if (_previousMode == null) {
          _previousMode = navProvider.mode;
          // Set initial value without animation
          if (navProvider.isTabBarMode) {
            _paddingController.value = 1.0;
          }
        } else if (_previousMode != navProvider.mode) {
          // Animate padding when mode changes
          if (navProvider.isTabBarMode) {
            _paddingController.forward();
          } else {
            _paddingController.reverse();
          }
          _previousMode = navProvider.mode;
        }

        return KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyPress,
          child: Stack(
            children: [
              // Main content with animated left padding
              AnimatedBuilder(
                animation: _paddingAnimation,
                builder: (context, child) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: _paddingAnimation.value,
                    ),
                    child: widget.child,
                  );
                },
              ),
              // Single morphing navigation widget - use Positioned.fill to ensure proper hit testing
              const Positioned.fill(
                child: MorphingNavigation(),
              ),
            ],
          ),
        );
      },
    );
  }
}
