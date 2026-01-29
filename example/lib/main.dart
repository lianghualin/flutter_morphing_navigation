import 'package:flutter/material.dart';
import 'package:morphing_navigation/morphing_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morphing Navigation Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MorphingNavigationScaffold.withPages(
        items: NavItem.defaultItems,
        initialSelectedId: 'home',
        pageTransitionType: PageTransitionType.fade,
        pageTransitionDuration: const Duration(milliseconds: 200),
        showPageHeader: true,
        status: SystemStatus.placeholder(),
        pages: {
          // Main pages
          'home': const HomePage(),
          'favorites': const FavoritesPage(),
          'settings': const SettingsPage(),
          // Library section pages
          'photos': const PhotosPage(),
          'videos': const VideosPage(),
          'albums': const AlbumsPage(),
          // Browse section pages
          'categories': const CategoriesPage(),
          'trending': const TrendingPage(),
          'featured': const FeaturedPage(),
        },
      ),
    );
  }
}

/// Base page template with consistent styling (content only, header provided by scaffold)
class _BasePage extends StatelessWidget {
  final Widget content;

  const _BasePage({
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: content,
      ),
    );
  }
}

/// Home page with dashboard-style content
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return _BasePage(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsGrid(screenWidth),
          const SizedBox(height: 24),
          _buildContentPanels(screenWidth),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(double screenWidth) {
    final crossAxisCount = screenWidth > 1200
        ? 4
        : screenWidth > 800
            ? 2
            : 1;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildStatCard('Total Users', '24,521', '+12%', Icons.people_rounded,
            AppTheme.primaryBlue),
        _buildStatCard('Revenue', '\$45,678', '+8%', Icons.attach_money_rounded,
            AppTheme.primaryGreen),
        _buildStatCard('Active Sessions', '1,234', '+23%', Icons.bolt_rounded,
            AppTheme.primaryOrange),
        _buildStatCard('Conversion', '3.24%', '-2%', Icons.trending_up_rounded,
            AppTheme.primaryPurple),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, String change, IconData icon, Color color) {
    final isPositive = change.startsWith('+');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                      : AppTheme.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isPositive ? AppTheme.primaryGreen : AppTheme.primaryRed,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentPanels(double screenWidth) {
    final isWide = screenWidth > 900;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildActivityPanel()),
          const SizedBox(width: 16),
          Expanded(child: _buildQuickActionsPanel()),
        ],
      );
    }

    return Column(
      children: [
        _buildActivityPanel(),
        const SizedBox(height: 16),
        _buildQuickActionsPanel(),
      ],
    );
  }

  Widget _buildActivityPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            5,
            (index) => _buildActivityItem(
              'User action ${index + 1}',
              '${index + 1} hour${index == 0 ? '' : 's'} ago',
              Icons.person_rounded,
              [
                AppTheme.primaryBlue,
                AppTheme.primaryGreen,
                AppTheme.primaryOrange,
                AppTheme.primaryPurple,
                AppTheme.primaryPink,
              ][index],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsPanel() {
    final actions = [
      ('New Project', Icons.add_rounded, AppTheme.primaryBlue),
      ('Upload File', Icons.upload_rounded, AppTheme.primaryGreen),
      ('Share Link', Icons.share_rounded, AppTheme.primaryOrange),
      ('Settings', Icons.settings_rounded, AppTheme.primaryPurple),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...actions.map((action) => _buildQuickActionItem(
                action.$1,
                action.$2,
                action.$3,
              )),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.sidebarBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Favorites page
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _BasePage(
      content: _buildFavoritesList(),
    );
  }

  Widget _buildFavoritesList() {
    final favorites = [
      ('Vacation Photos', Icons.photo_rounded, '24 items'),
      ('Work Documents', Icons.folder_rounded, '12 items'),
      ('Music Playlist', Icons.music_note_rounded, '48 songs'),
      ('Important Notes', Icons.note_rounded, '8 notes'),
    ];

    return Column(
      children: favorites
          .map((item) => _buildFavoriteItem(item.$1, item.$2, item.$3))
          .toList(),
    );
  }

  Widget _buildFavoriteItem(String title, IconData icon, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF2D55).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFFF2D55), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}

/// Settings page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _BasePage(
      content: _buildSettingsList(),
    );
  }

  Widget _buildSettingsList() {
    final settings = [
      ('Account', Icons.person_rounded, 'Manage your account'),
      ('Notifications', Icons.notifications_rounded, 'Configure alerts'),
      ('Privacy', Icons.lock_rounded, 'Privacy settings'),
      ('Appearance', Icons.palette_rounded, 'Theme and display'),
      ('Storage', Icons.storage_rounded, 'Manage storage'),
      ('About', Icons.info_rounded, 'App information'),
    ];

    return Column(
      children: settings
          .map((item) => _buildSettingItem(item.$1, item.$2, item.$3))
          .toList(),
    );
  }

  Widget _buildSettingItem(String title, IconData icon, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E8E93).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF8E8E93), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Photos page (Library section)
class PhotosPage extends StatelessWidget {
  const PhotosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _BasePage(
      content: _buildPhotoGrid(),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.primaries[index % Colors.primaries.length]
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.image_rounded, color: Colors.white54, size: 32),
        );
      },
    );
  }
}

/// Videos page (Library section)
class VideosPage extends StatelessWidget {
  const VideosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _BasePage(
      content: _buildVideoList(),
    );
  }

  Widget _buildVideoList() {
    final videos = [
      ('Summer Vacation', '12:34', 'July 2024'),
      ('Birthday Party', '8:21', 'June 2024'),
      ('Concert Highlights', '45:12', 'May 2024'),
    ];

    return Column(
      children: videos.map((v) => _buildVideoItem(v.$1, v.$2, v.$3)).toList(),
    );
  }

  Widget _buildVideoItem(String title, String duration, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9500).withValues(alpha: 0.2),
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            child: const Icon(Icons.play_circle_rounded,
                color: Color(0xFFFF9500), size: 40),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('$duration · $date',
                      style:
                          TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Albums page (Library section)
class AlbumsPage extends StatelessWidget {
  const AlbumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _BasePage(
      content: _buildAlbumsGrid(),
    );
  }

  Widget _buildAlbumsGrid() {
    final albums = [
      'Vacation 2024',
      'Family',
      'Work',
      'Screenshots',
      'Downloads',
      'Memories'
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_album_rounded,
                  size: 48, color: const Color(0xFFFF2D55).withValues(alpha: 0.7)),
              const SizedBox(height: 8),
              Text(albums[index],
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        );
      },
    );
  }
}

/// Categories page (Browse section)
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _BasePage(
      content: _buildCategoriesGrid(),
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      ('Nature', Icons.landscape_rounded, Colors.green),
      ('Travel', Icons.flight_rounded, Colors.blue),
      ('Food', Icons.restaurant_rounded, Colors.orange),
      ('Sports', Icons.sports_basketball_rounded, Colors.red),
      ('Music', Icons.music_note_rounded, Colors.purple),
      ('Art', Icons.palette_rounded, Colors.pink),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Container(
          decoration: BoxDecoration(
            color: cat.$3.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cat.$3.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(cat.$2, size: 48, color: cat.$3),
              const SizedBox(height: 8),
              Text(cat.$1,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: cat.$3, fontSize: 16)),
            ],
          ),
        );
      },
    );
  }
}

/// Trending page (Browse section)
class TrendingPage extends StatelessWidget {
  const TrendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _BasePage(
      content: _buildTrendingList(),
    );
  }

  Widget _buildTrendingList() {
    final trending = [
      ('#1', 'Amazing sunset photos', '2.5M views'),
      ('#2', 'City architecture', '1.8M views'),
      ('#3', 'Wildlife photography', '1.2M views'),
      ('#4', 'Street art collection', '980K views'),
      ('#5', 'Vintage cars', '750K views'),
    ];

    return Column(
      children: trending.map((t) => _buildTrendingItem(t.$1, t.$2, t.$3)).toList(),
    );
  }

  Widget _buildTrendingItem(String rank, String title, String views) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF34C759).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(rank,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF34C759))),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                Text(views, style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.trending_up_rounded, color: Color(0xFF34C759)),
        ],
      ),
    );
  }
}

/// Featured page (Browse section)
class FeaturedPage extends StatelessWidget {
  const FeaturedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _BasePage(
      content: _buildFeaturedContent(),
    );
  }

  Widget _buildFeaturedContent() {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFCC00), Color(0xFFFF9500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, size: 64, color: Colors.white),
              SizedBox(height: 8),
              Text('Featured Collection',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              Text('Curated picks just for you',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Editor\'s Choice',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.primaries[(index * 3) % Colors.primaries.length]
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white54, size: 32),
              );
            },
          ),
        ),
      ],
    );
  }
}
