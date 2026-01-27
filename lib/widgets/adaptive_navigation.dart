import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import 'sidebar/sidebar_navigation.dart';
import 'tabbar/tabbar_navigation.dart';

class AdaptiveNavigation extends StatefulWidget {
  final Widget child;

  const AdaptiveNavigation({
    super.key,
    required this.child,
  });

  @override
  State<AdaptiveNavigation> createState() => _AdaptiveNavigationState();
}

class _AdaptiveNavigationState extends State<AdaptiveNavigation> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyPress(KeyEvent event) {
    // Toggle mode on 'T' key press
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.keyT)) {
      context.read<NavigationProvider>().toggleMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update screen width for responsive behavior
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final width = MediaQuery.of(context).size.width;
      context.read<NavigationProvider>().updateScreenWidth(width);
    });

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyPress,
      child: Stack(
        children: [
          // Main content with animated padding
          Row(
            children: [
              // Sidebar (animates width)
              const SidebarNavigation(),
              // Main content area
              Expanded(
                child: widget.child,
              ),
            ],
          ),
          // Tab bar (floating overlay)
          const TabBarNavigation(),
        ],
      ),
    );
  }
}
