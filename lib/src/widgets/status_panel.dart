import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/system_status.dart';
import '../theme/navigation_theme.dart';

/// Status panel for sidebar mode showing linear progress bars.
///
/// Displays CPU, memory, and disk usage as linear bars,
/// along with time, warning count, and user name.
class SidebarStatusPanel extends StatelessWidget {
  final SystemStatus status;
  final double opacity;

  const SidebarStatusPanel({
    super.key,
    required this.status,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0) return const SizedBox.shrink();

    final theme = MorphingNavigationThemeProvider.of(context);

    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.sidebarBackgroundColor,
          border: Border(
            top: BorderSide(
              color: theme.borderColor,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bars section
            _buildProgressBar('CPU', status.cpuUsage, theme.primaryColor, theme),
            const SizedBox(height: 12),
            _buildProgressBar('MEM', status.memoryUsage, theme.successColor, theme),
            const SizedBox(height: 12),
            _buildProgressBar('DISK', status.diskUsage, theme.warningColor, theme),
            const SizedBox(height: 16),
            // Bottom info row
            _buildInfoRow(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color, MorphingNavigationTheme theme) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.textSecondaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: theme.borderColor,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '${(value * 100).round()}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.textPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(MorphingNavigationTheme theme) {
    return Row(
      children: [
        // Time
        Icon(
          Icons.access_time_rounded,
          size: 14,
          color: theme.textSecondaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          status.formattedTime,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.textPrimaryColor,
          ),
        ),
        const SizedBox(width: 16),
        // Warnings
        GestureDetector(
          onTap: status.onWarningTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status.warningCount > 0
                  ? theme.warningColor.withValues(alpha: 0.1)
                  : theme.borderColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: status.warningCount > 0
                      ? theme.warningColor
                      : theme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${status.warningCount}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: status.warningCount > 0
                        ? theme.warningColor
                        : theme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        // User name removed - already shown in footer
      ],
    );
  }
}

/// Compact status indicator for tab bar mode with circular progress indicators.
///
/// Displays time, warning count, and small circular gauges for CPU/MEM/DISK.
class TabBarStatusIndicator extends StatelessWidget {
  final SystemStatus status;
  final double opacity;

  const TabBarStatusIndicator({
    super.key,
    required this.status,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0) return const SizedBox.shrink();

    final theme = MorphingNavigationThemeProvider.of(context);

    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Divider
            Container(
              width: 1,
              height: 32,
              color: theme.borderColor,
            ),
            const SizedBox(width: 12),
            // Time
            Text(
              status.formattedTime,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textPrimaryColor,
              ),
            ),
            const SizedBox(width: 12),
            // Warnings
            GestureDetector(
              onTap: status.onWarningTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: status.warningCount > 0
                      ? theme.warningColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 12,
                      color: status.warningCount > 0
                          ? theme.warningColor
                          : theme.textSecondaryColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${status.warningCount}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: status.warningCount > 0
                            ? theme.warningColor
                            : theme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Circular progress indicators with labels and tooltips
            _LabeledCircularIndicator(
              value: status.cpuUsage,
              color: theme.primaryColor,
              backgroundColor: theme.borderColor,
              tooltipBackgroundColor: theme.textPrimaryColor,
              label: 'C',
              tooltip: 'CPU: ${status.cpuPercentage}',
            ),
            const SizedBox(width: 6),
            _LabeledCircularIndicator(
              value: status.memoryUsage,
              color: theme.successColor,
              backgroundColor: theme.borderColor,
              tooltipBackgroundColor: theme.textPrimaryColor,
              label: 'M',
              tooltip: 'Memory: ${status.memoryPercentage}',
            ),
            const SizedBox(width: 6),
            _LabeledCircularIndicator(
              value: status.diskUsage,
              color: theme.warningColor,
              backgroundColor: theme.borderColor,
              tooltipBackgroundColor: theme.textPrimaryColor,
              label: 'D',
              tooltip: 'Disk: ${status.diskPercentage}',
            ),
            const SizedBox(width: 8),
            // User avatar
            _UserAvatar(
              userName: status.userName,
              gradient: theme.effectivePrimaryGradient,
              tooltipBackgroundColor: theme.textPrimaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// Labeled circular progress indicator with tooltip for tab bar
class _LabeledCircularIndicator extends StatelessWidget {
  final double value;
  final Color color;
  final Color backgroundColor;
  final Color tooltipBackgroundColor;
  final String label;
  final String tooltip;
  final double size;

  const _LabeledCircularIndicator({
    required this.value,
    required this.color,
    required this.backgroundColor,
    required this.tooltipBackgroundColor,
    required this.label,
    required this.tooltip,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      decoration: BoxDecoration(
        color: tooltipBackgroundColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progress ring
            CustomPaint(
              size: Size(size, size),
              painter: _CircularProgressPainter(
                value: value.clamp(0.0, 1.0),
                color: color,
                backgroundColor: backgroundColor,
                strokeWidth: 3,
              ),
            ),
            // Label in center
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// User avatar for tab bar status
class _UserAvatar extends StatelessWidget {
  final String userName;
  final Gradient gradient;
  final Color tooltipBackgroundColor;
  final double size;

  const _UserAvatar({
    required this.userName,
    required this.gradient,
    required this.tooltipBackgroundColor,
    this.size = 26,
  });

  String get _initials {
    if (userName.isEmpty) return '?';
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) {
      // First letter of first and last name
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    // Just first letter
    return userName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: userName,
      preferBelow: false,
      decoration: BoxDecoration(
        color: tooltipBackgroundColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Center(
          child: Text(
            _initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.value,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
