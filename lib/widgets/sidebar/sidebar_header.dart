import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_theme.dart';

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Title
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Navigation Demo',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Toggle button
          _ToggleModeButton(),
        ],
      ),
    );
  }
}

class _ToggleModeButton extends StatefulWidget {
  @override
  State<_ToggleModeButton> createState() => _ToggleModeButtonState();
}

class _ToggleModeButtonState extends State<_ToggleModeButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          context.read<NavigationProvider>().toggleMode();
        },
        child: AnimatedContainer(
          duration: AppTheme.hoverDuration,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _isHovered
                ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.view_sidebar_rounded,
            size: 20,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
