import 'package:flutter/foundation.dart';

/// Represents system status information to be displayed in the navigation.
///
/// This model holds data about system resources (CPU, memory, disk),
/// current time, warning notifications, and user information.
///
/// Example usage:
/// ```dart
/// final status = SystemStatus(
///   cpuUsage: 0.45,
///   memoryUsage: 0.67,
///   diskUsage: 0.23,
///   time: DateTime.now(),
///   warningCount: 2,
///   userName: 'John Doe',
///   onWarningTap: () => print('Warnings tapped'),
/// );
/// ```
class SystemStatus {
  /// CPU usage as a percentage (0.0 to 1.0)
  final double cpuUsage;

  /// Memory usage as a percentage (0.0 to 1.0)
  final double memoryUsage;

  /// Disk usage as a percentage (0.0 to 1.0)
  final double diskUsage;

  /// Current time to display
  final DateTime time;

  /// Number of warnings/notifications
  final int warningCount;

  /// User name to display
  final String userName;

  /// Callback when the warning badge is tapped
  final VoidCallback? onWarningTap;

  /// Creates a system status instance.
  const SystemStatus({
    this.cpuUsage = 0.0,
    this.memoryUsage = 0.0,
    this.diskUsage = 0.0,
    required this.time,
    this.warningCount = 0,
    this.userName = 'User',
    this.onWarningTap,
  });

  /// Creates a placeholder status with demo data.
  ///
  /// Useful for testing and previewing the UI.
  factory SystemStatus.placeholder({
    VoidCallback? onWarningTap,
  }) {
    return SystemStatus(
      cpuUsage: 0.45,
      memoryUsage: 0.67,
      diskUsage: 0.23,
      time: DateTime.now(),
      warningCount: 2,
      userName: 'John',
      onWarningTap: onWarningTap ?? () {
        debugPrint('Warning tapped! Count: 2');
      },
    );
  }

  /// Creates a copy of this status with the given fields replaced.
  SystemStatus copyWith({
    double? cpuUsage,
    double? memoryUsage,
    double? diskUsage,
    DateTime? time,
    int? warningCount,
    String? userName,
    VoidCallback? onWarningTap,
  }) {
    return SystemStatus(
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      diskUsage: diskUsage ?? this.diskUsage,
      time: time ?? this.time,
      warningCount: warningCount ?? this.warningCount,
      userName: userName ?? this.userName,
      onWarningTap: onWarningTap ?? this.onWarningTap,
    );
  }

  /// Formatted time string (HH:mm)
  String get formattedTime {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// CPU usage as percentage string
  String get cpuPercentage => '${(cpuUsage * 100).round()}%';

  /// Memory usage as percentage string
  String get memoryPercentage => '${(memoryUsage * 100).round()}%';

  /// Disk usage as percentage string
  String get diskPercentage => '${(diskUsage * 100).round()}%';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SystemStatus &&
        other.cpuUsage == cpuUsage &&
        other.memoryUsage == memoryUsage &&
        other.diskUsage == diskUsage &&
        other.time == time &&
        other.warningCount == warningCount &&
        other.userName == userName;
  }

  @override
  int get hashCode {
    return Object.hash(
      cpuUsage,
      memoryUsage,
      diskUsage,
      time,
      warningCount,
      userName,
    );
  }
}
