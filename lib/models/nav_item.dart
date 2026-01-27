import 'package:flutter/material.dart';

class NavItem {
  final String id;
  final String label;
  final IconData icon;
  final Color? iconColor;
  final List<NavItem>? children;
  final String? badge;

  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
    this.iconColor,
    this.children,
    this.badge,
  });

  bool get hasChildren => children != null && children!.isNotEmpty;

  // Predefined navigation items matching the HTML demo
  static List<NavItem> get defaultItems => [
        const NavItem(
          id: 'home',
          label: 'Home',
          icon: Icons.home_rounded,
          iconColor: Color(0xFF007AFF),
        ),
        NavItem(
          id: 'library',
          label: 'Library',
          icon: Icons.photo_library_rounded,
          iconColor: const Color(0xFF5856D6),
          children: [
            const NavItem(
              id: 'photos',
              label: 'Photos',
              icon: Icons.photo_rounded,
              iconColor: Color(0xFF34C759),
            ),
            const NavItem(
              id: 'videos',
              label: 'Videos',
              icon: Icons.videocam_rounded,
              iconColor: Color(0xFFFF9500),
            ),
            const NavItem(
              id: 'albums',
              label: 'Albums',
              icon: Icons.photo_album_rounded,
              iconColor: Color(0xFFFF2D55),
            ),
          ],
        ),
        NavItem(
          id: 'browse',
          label: 'Browse',
          icon: Icons.explore_rounded,
          iconColor: const Color(0xFF5AC8FA),
          children: [
            const NavItem(
              id: 'categories',
              label: 'Categories',
              icon: Icons.category_rounded,
              iconColor: Color(0xFFFF3B30),
            ),
            const NavItem(
              id: 'trending',
              label: 'Trending',
              icon: Icons.trending_up_rounded,
              iconColor: Color(0xFF34C759),
            ),
            const NavItem(
              id: 'featured',
              label: 'Featured',
              icon: Icons.star_rounded,
              iconColor: Color(0xFFFFCC00),
            ),
          ],
        ),
        const NavItem(
          id: 'favorites',
          label: 'Favorites',
          icon: Icons.favorite_rounded,
          iconColor: Color(0xFFFF2D55),
          badge: '12',
        ),
        const NavItem(
          id: 'settings',
          label: 'Settings',
          icon: Icons.settings_rounded,
          iconColor: Color(0xFF8E8E93),
        ),
      ];
}
