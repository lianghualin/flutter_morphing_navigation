import 'package:flutter/material.dart';

/// Configuration for the navigation header in sidebar mode.
///
/// The header appears at the top of the sidebar and typically contains
/// a logo, title, and optional actions.
///
/// Example usage:
/// ```dart
/// MorphingNavHeader(
///   logo: Icon(Icons.dashboard, color: Colors.blue),
///   title: 'My App',
///   subtitle: 'v1.0.0',
///   trailing: IconButton(
///     icon: Icon(Icons.settings),
///     onPressed: () {},
///   ),
/// )
/// ```
class MorphingNavHeader {
  /// The logo widget to display (typically an Icon or Image)
  final Widget? logo;

  /// The logo background decoration (e.g., gradient container)
  final BoxDecoration? logoDecoration;

  /// The main title text
  final String title;

  /// Optional subtitle text
  final String? subtitle;

  /// Optional trailing widget (shown after title, before toggle button)
  final Widget? trailing;

  /// Custom builder for complete control over header layout
  /// If provided, logo, title, subtitle, and trailing are ignored
  final Widget Function(BuildContext context, VoidCallback onToggle)? builder;

  /// Whether to show the mode toggle button in the header
  final bool showToggleButton;

  const MorphingNavHeader({
    this.logo,
    this.logoDecoration,
    this.title = 'Navigation',
    this.subtitle,
    this.trailing,
    this.builder,
    this.showToggleButton = true,
  });

  /// Creates a header with just a title
  const MorphingNavHeader.simple(String title)
      : this(
          title: title,
          logo: null,
          subtitle: null,
        );

  /// Creates a header with logo and title
  const MorphingNavHeader.withLogo({
    required Widget logo,
    required String title,
    String? subtitle,
    BoxDecoration? logoDecoration,
  }) : this(
          logo: logo,
          logoDecoration: logoDecoration,
          title: title,
          subtitle: subtitle,
        );

  /// Creates a custom header using a builder function
  const MorphingNavHeader.custom(
    Widget Function(BuildContext context, VoidCallback onToggle) builder,
  ) : this(builder: builder, title: '');
}

/// Configuration for the navigation footer in sidebar mode.
///
/// The footer appears at the bottom of the sidebar and typically contains
/// user information or additional actions.
///
/// Example usage:
/// ```dart
/// MorphingNavFooter(
///   avatar: CircleAvatar(
///     backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
///   ),
///   title: 'John Doe',
///   subtitle: 'john@example.com',
///   trailing: IconButton(
///     icon: Icon(Icons.logout),
///     onPressed: () {},
///   ),
/// )
/// ```
class MorphingNavFooter {
  /// The avatar widget to display
  final Widget? avatar;

  /// Avatar placeholder text (used if avatar is null)
  final String? avatarText;

  /// Avatar background decoration
  final BoxDecoration? avatarDecoration;

  /// The main title text (e.g., user name)
  final String? title;

  /// Optional subtitle text (e.g., email)
  final String? subtitle;

  /// Optional trailing widget (e.g., logout button)
  final Widget? trailing;

  /// Custom builder for complete control over footer layout
  /// If provided, other properties are ignored
  final Widget Function(BuildContext context)? builder;

  /// Callback when the footer is tapped
  final VoidCallback? onTap;

  const MorphingNavFooter({
    this.avatar,
    this.avatarText,
    this.avatarDecoration,
    this.title,
    this.subtitle,
    this.trailing,
    this.builder,
    this.onTap,
  });

  /// Creates a footer with user information
  ///
  /// If [avatarText] is not provided, the first character of [name] will be used.
  factory MorphingNavFooter.user({
    required String name,
    String? email,
    Widget? avatar,
    String? avatarText,
    VoidCallback? onTap,
  }) {
    return MorphingNavFooter(
      avatar: avatar,
      avatarText: avatarText ?? (name.isNotEmpty ? name[0].toUpperCase() : '?'),
      title: name,
      subtitle: email,
      onTap: onTap,
    );
  }

  /// Creates a custom footer using a builder function
  const MorphingNavFooter.custom(
    Widget Function(BuildContext context) builder,
  ) : this(builder: builder);

  /// Creates an empty footer (no footer shown)
  static const MorphingNavFooter none = MorphingNavFooter();

  /// Whether this footer has any content to display
  bool get hasContent =>
      avatar != null ||
      avatarText != null ||
      title != null ||
      subtitle != null ||
      trailing != null ||
      builder != null;
}
