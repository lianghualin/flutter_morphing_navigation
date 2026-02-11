import 'package:flutter/material.dart';
import 'package:morphing_navigation/morph_nav.dart';

void main() {
  runApp(const PlaygroundApp());
}

class PlaygroundApp extends StatelessWidget {
  const PlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaygroundRoot();
  }
}

// ─────────────────────────────────────────────────────────
// Theme presets
// ─────────────────────────────────────────────────────────
enum ThemePreset { light, dark, ocean, sunset }

MorphingNavigationTheme _themeFor(ThemePreset p) {
  switch (p) {
    case ThemePreset.light:
      return MorphingNavigationTheme.light;
    case ThemePreset.dark:
      return MorphingNavigationTheme.dark;
    case ThemePreset.ocean:
      return const MorphingNavigationTheme(
        primaryColor: Color(0xFF006D77),
        secondaryColor: Color(0xFF83C5BE),
        accentColor: Color(0xFFEDF6F9),
        backgroundColor: Color(0xFFF0F7F4),
        sidebarBackgroundColor: Color(0xFFFDFCDC),
        itemSelectedColor: Color(0xFF006D77),
      );
    case ThemePreset.sunset:
      return const MorphingNavigationTheme(
        primaryColor: Color(0xFFE76F51),
        secondaryColor: Color(0xFFF4A261),
        accentColor: Color(0xFFE9C46A),
        backgroundColor: Color(0xFFFFF5EB),
        sidebarBackgroundColor: Color(0xFFFFF8F0),
        itemSelectedColor: Color(0xFFE76F51),
      );
  }
}

// ─────────────────────────────────────────────────────────
// Root widget — holds all playground state
// ─────────────────────────────────────────────────────────
class _PlaygroundRoot extends StatefulWidget {
  const _PlaygroundRoot();
  @override
  State<_PlaygroundRoot> createState() => _PlaygroundRootState();
}

class _PlaygroundRootState extends State<_PlaygroundRoot> {
  // Settings
  ThemePreset _preset = ThemePreset.light;
  PageTransitionType _transition = PageTransitionType.fade;
  bool _showPageHeader = true;
  bool _showHeader = true;
  bool _showFooter = true;
  bool _enableKeyboard = true;
  bool _showStatus = true;
  double _cpu = 0.45;
  double _mem = 0.62;
  double _disk = 0.78;
  String _selectedId = 'playground';

  bool get _isDark => _preset == ThemePreset.dark;
  MorphingNavigationTheme get _theme => _themeFor(_preset);

  SystemStatus? get _status => _showStatus
      ? SystemStatus(
          cpuUsage: _cpu,
          memoryUsage: _mem,
          diskUsage: _disk,
          time: DateTime.now(),
          warningCount: 3,
          userName: 'Morphy',
        )
      : null;

  void _set(VoidCallback fn) => setState(fn);

  // Navigation items
  List<NavItem> get _items => [
        const NavItem(
          id: 'playground',
          label: 'Playground',
          icon: Icons.sports_esports_rounded,
          iconColor: Color(0xFF007AFF),
        ),
        NavItem(
          id: 'themes',
          label: 'Themes',
          icon: Icons.palette_rounded,
          iconColor: const Color(0xFF5856D6),
          children: const [
            NavItem(id: 'theme_light', label: 'Light', icon: Icons.light_mode_rounded, iconColor: Color(0xFFFF9500)),
            NavItem(id: 'theme_dark', label: 'Dark', icon: Icons.dark_mode_rounded, iconColor: Color(0xFF5856D6)),
            NavItem(id: 'theme_custom', label: 'Custom', icon: Icons.auto_fix_high_rounded, iconColor: Color(0xFFFF2D55)),
          ],
        ),
        const NavItem(
          id: 'transitions',
          label: 'Transitions',
          icon: Icons.animation_rounded,
          iconColor: Color(0xFFFF9500),
          badge: '14',
        ),
        NavItem(
          id: 'controls',
          label: 'Controls',
          icon: Icons.tune_rounded,
          iconColor: const Color(0xFF34C759),
          children: const [
            NavItem(id: 'ctrl_header', label: 'Header', icon: Icons.vertical_align_top_rounded, iconColor: Color(0xFF34C759)),
            NavItem(id: 'ctrl_footer', label: 'Footer', icon: Icons.vertical_align_bottom_rounded, iconColor: Color(0xFF5AC8FA)),
            NavItem(id: 'ctrl_status', label: 'Status', icon: Icons.monitor_heart_rounded, iconColor: Color(0xFFFF3B30)),
          ],
        ),
        const NavItem(
          id: 'responsive',
          label: 'Responsive',
          icon: Icons.devices_rounded,
          iconColor: Color(0xFF5AC8FA),
        ),
        const NavItem(
          id: 'about',
          label: 'About',
          icon: Icons.info_rounded,
          iconColor: Color(0xFF8E8E93),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morphing Navigation Playground',
      debugShowCheckedModeBanner: false,
      theme: _isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      home: Scaffold(
        body: MorphingNavigationScaffold.withPages(
          key: ValueKey('${_preset.name}|$_showHeader|$_showFooter|$_enableKeyboard'),
          items: _items,
          initialSelectedId: _selectedId,
          theme: _theme,
          pageTransitionType: _transition,
          showPageHeader: _showPageHeader,
          enableKeyboardShortcuts: _enableKeyboard,
          showHeader: _showHeader,
          showFooter: _showFooter,
          status: _status,
          onItemSelected: (id) => _selectedId = id,
          header: MorphingNavHeader(
            logo: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: _theme.effectivePrimaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            title: 'Playground',
            subtitle: 'v1.0',
          ),
          footer: MorphingNavFooter.user(name: 'Morphy', email: 'morphy@playground.dev'),
          pages: {
            'playground': _HomePage(preset: _preset, isDark: _isDark, onTheme: (t) => _set(() => _preset = t)),
            'theme_light': _ThemePage(name: 'Light', theme: MorphingNavigationTheme.light, active: _preset == ThemePreset.light, isDark: false, onApply: () => _set(() => _preset = ThemePreset.light)),
            'theme_dark': _ThemePage(name: 'Dark', theme: MorphingNavigationTheme.dark, active: _preset == ThemePreset.dark, isDark: true, onApply: () => _set(() => _preset = ThemePreset.dark)),
            'theme_custom': _CustomThemePage(preset: _preset, isDark: _isDark, onApply: (t) => _set(() => _preset = t)),
            'transitions': _TransitionsPage(current: _transition, isDark: _isDark, onChange: (t) => _set(() => _transition = t)),
            'ctrl_header': _HeaderPage(showHeader: _showHeader, showPageHeader: _showPageHeader, isDark: _isDark, onHeader: (v) => _set(() => _showHeader = v), onPageHeader: (v) => _set(() => _showPageHeader = v)),
            'ctrl_footer': _FooterPage(showFooter: _showFooter, isDark: _isDark, onChanged: (v) => _set(() => _showFooter = v)),
            'ctrl_status': _StatusPage(show: _showStatus, cpu: _cpu, mem: _mem, disk: _disk, isDark: _isDark, onShow: (v) => _set(() => _showStatus = v), onCpu: (v) => _set(() => _cpu = v), onMem: (v) => _set(() => _mem = v), onDisk: (v) => _set(() => _disk = v)),
            'responsive': _ResponsivePage(isDark: _isDark),
            'about': _AboutPage(keyboard: _enableKeyboard, isDark: _isDark, onKeyboard: (v) => _set(() => _enableKeyboard = v)),
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────
Color _card(bool d) => d ? const Color(0xFF2C2C2E) : Colors.white;
Color _text(bool d) => d ? Colors.white : const Color(0xFF1D1D1F);
Color _sub(bool d) => d ? const Color(0xFF98989D) : const Color(0xFF86868B);
Color _bg(bool d) => d ? const Color(0xFF1C1C1E) : const Color(0xFFF5F5F7);

class _PCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _PCard({required this.child, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}

class _Page extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _Page({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg(isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

Widget _sectionTitle(String text, bool isDark) => Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _text(isDark))),
    );

// ─────────────────────────────────────────────────────────
// Morphy character — CustomPainter
// ─────────────────────────────────────────────────────────
class _MorphyPainter extends CustomPainter {
  final Color color1;
  final Color color2;

  _MorphyPainter({required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color1, color2],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final bodyRect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(w * 0.28));
    canvas.drawRRect(bodyRect, bodyPaint);

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = const Color(0xFF1D1D1F);
    final eyeY = h * 0.38;
    final eyeR = w * 0.08;
    final pupilR = w * 0.04;

    canvas.drawCircle(Offset(w * 0.35, eyeY), eyeR, eyePaint);
    canvas.drawCircle(Offset(w * 0.65, eyeY), eyeR, eyePaint);
    canvas.drawCircle(Offset(w * 0.36, eyeY - 1), pupilR, pupilPaint);
    canvas.drawCircle(Offset(w * 0.66, eyeY - 1), pupilR, pupilPaint);

    // Smile
    final smilePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;

    final smilePath = Path()
      ..moveTo(w * 0.35, h * 0.6)
      ..quadraticBezierTo(w * 0.5, h * 0.75, w * 0.65, h * 0.6);
    canvas.drawPath(smilePath, smilePaint);

    // Cheeks (subtle blush)
    final blushPaint = Paint()..color = Colors.white.withValues(alpha: 0.2);
    canvas.drawCircle(Offset(w * 0.22, h * 0.55), w * 0.06, blushPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.55), w * 0.06, blushPaint);
  }

  @override
  bool shouldRepaint(covariant _MorphyPainter old) => old.color1 != color1 || old.color2 != color2;
}

// ─────────────────────────────────────────────────────────
// Home page
// ─────────────────────────────────────────────────────────
class _HomePage extends StatelessWidget {
  final ThemePreset preset;
  final bool isDark;
  final ValueChanged<ThemePreset> onTheme;
  const _HomePage({required this.preset, required this.isDark, required this.onTheme});

  @override
  Widget build(BuildContext context) {
    final theme = _themeFor(preset);
    final width = MediaQuery.of(context).size.width;
    final cols = width > 1000 ? 3 : width > 700 ? 2 : 1;

    return _Page(isDark: isDark, children: [
      const SizedBox(height: 8),
      // Morphy hero section
      _PCard(
        isDark: isDark,
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(painter: _MorphyPainter(color1: theme.primaryColor, color2: theme.secondaryColor)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome to the Playground!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _text(isDark))),
                  const SizedBox(height: 4),
                  Text(
                    'Explore every feature of Morphing Navigation.\nResize the window or press T to see me morph!',
                    style: TextStyle(fontSize: 14, color: _sub(isDark), height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      // Quick theme switcher
      _sectionTitle('Quick Theme Switch', isDark),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ThemePreset.values.map((t) {
          final th = _themeFor(t);
          final active = t == preset;
          return GestureDetector(
            onTap: () => onTheme(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: active ? LinearGradient(colors: [th.primaryColor, th.secondaryColor]) : null,
                color: active ? null : _card(isDark),
                borderRadius: BorderRadius.circular(12),
                border: active ? null : Border.all(color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA)),
              ),
              child: Text(
                t.name[0].toUpperCase() + t.name.substring(1),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : _text(isDark),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 24),

      // Feature cards grid
      _sectionTitle('Features to Explore', isDark),
      GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
        children: [
          _featureCard(Icons.swap_horiz_rounded, 'Morphing', 'Sidebar ↔ Tab bar', const Color(0xFF007AFF)),
          _featureCard(Icons.folder_open_rounded, 'Sections', 'Collapsible groups', const Color(0xFF5856D6)),
          _featureCard(Icons.notifications_rounded, 'Badges', 'Notification counts', const Color(0xFFFF3B30)),
          _featureCard(Icons.palette_rounded, 'Themes', '4 presets available', const Color(0xFFFF9500)),
          _featureCard(Icons.animation_rounded, 'Transitions', '14 page transition types', const Color(0xFF34C759)),
          _featureCard(Icons.monitor_heart_rounded, 'Status Panel', 'CPU, Memory, Disk', const Color(0xFFFF2D55)),
          _featureCard(Icons.keyboard_rounded, 'Shortcuts', 'Press T to toggle', const Color(0xFF5AC8FA)),
          _featureCard(Icons.devices_rounded, 'Responsive', 'Auto-switch by width', const Color(0xFF8E8E93)),
          _featureCard(Icons.blur_on_rounded, 'Glassmorphism', 'Blur effect in tab bar', const Color(0xFFAF52DE)),
        ],
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _featureCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: _text(isDark))),
                Text(subtitle, style: TextStyle(fontSize: 12, color: _sub(isDark))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Theme preview page (Light / Dark)
// ─────────────────────────────────────────────────────────
class _ThemePage extends StatelessWidget {
  final String name;
  final MorphingNavigationTheme theme;
  final bool active;
  final bool isDark;
  final VoidCallback onApply;
  const _ThemePage({required this.name, required this.theme, required this.active, required this.isDark, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return _Page(isDark: isDark, children: [
      _sectionTitle('$name Theme Colors', isDark),
      _PCard(
        isDark: isDark,
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _swatch('Primary', theme.primaryColor),
            _swatch('Secondary', theme.secondaryColor),
            _swatch('Accent', theme.accentColor),
            _swatch('Success', theme.successColor),
            _swatch('Warning', theme.warningColor),
            _swatch('Error', theme.errorColor),
            _swatch('Background', theme.backgroundColor),
            _swatch('Sidebar BG', theme.sidebarBackgroundColor),
            _swatch('Text Primary', theme.textPrimaryColor),
            _swatch('Text Secondary', theme.textSecondaryColor),
            _swatch('Selected', theme.itemSelectedColor),
            _swatch('Hover', theme.itemHoverColor),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _sectionTitle('Gradient Preview', isDark),
      _PCard(
        isDark: isDark,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: theme.effectivePrimaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text('Primary Gradient', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
        ),
      ),
      const SizedBox(height: 16),
      _sectionTitle('Dimensions', isDark),
      _PCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dim('Sidebar Width', '${theme.sidebarWidth}px'),
            _dim('Tab Bar Height', '${theme.tabBarHeight}px'),
            _dim('Item Height', '${theme.itemHeight}px'),
            _dim('Border Radius', '${theme.itemBorderRadius}px'),
            _dim('Breakpoint Large', '${theme.breakpointLarge}px'),
            _dim('Breakpoint Medium', '${theme.breakpointMedium}px'),
          ],
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: active ? null : onApply,
          icon: Icon(active ? Icons.check_circle_rounded : Icons.palette_rounded),
          label: Text(active ? 'Currently Active' : 'Apply $name Theme'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: active ? null : theme.primaryColor,
            foregroundColor: active ? null : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _swatch(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: _sub(isDark))),
      ],
    );
  }

  Widget _dim(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: _sub(isDark))),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: _text(isDark))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Custom theme page (Ocean / Sunset)
// ─────────────────────────────────────────────────────────
class _CustomThemePage extends StatelessWidget {
  final ThemePreset preset;
  final bool isDark;
  final ValueChanged<ThemePreset> onApply;
  const _CustomThemePage({required this.preset, required this.isDark, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return _Page(isDark: isDark, children: [
      _sectionTitle('Custom Theme Presets', isDark),
      Text('Beyond light and dark, try these custom color schemes:', style: TextStyle(color: _sub(isDark))),
      const SizedBox(height: 16),
      _presetCard(ThemePreset.ocean, 'Ocean', 'Calm teal and warm cream tones', Icons.water_rounded),
      const SizedBox(height: 12),
      _presetCard(ThemePreset.sunset, 'Sunset', 'Warm terracotta and golden hues', Icons.wb_twilight_rounded),
      const SizedBox(height: 24),
      _PCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How Custom Themes Work', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: _text(isDark))),
            const SizedBox(height: 8),
            Text(
              'Create a MorphingNavigationTheme with any combination of colors, '
              'dimensions, animations, and shadows. Pass it to the scaffold\'s '
              'theme parameter. Use copyWith() for small tweaks on existing presets.',
              style: TextStyle(color: _sub(isDark), height: 1.5),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _presetCard(ThemePreset p, String name, String desc, IconData icon) {
    final theme = _themeFor(p);
    final active = preset == p;
    return GestureDetector(
      onTap: () => onApply(p),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card(isDark),
          borderRadius: BorderRadius.circular(16),
          border: active ? Border.all(color: theme.primaryColor, width: 2) : null,
          boxShadow: isDark
              ? null
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: theme.effectivePrimaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: _text(isDark))),
                      if (active) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(6)),
                          child: const Text('Active', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: _sub(isDark), fontSize: 13)),
                ],
              ),
            ),
            // Color preview dots
            ...List.generate(3, (i) {
              final colors = [theme.primaryColor, theme.secondaryColor, theme.accentColor];
              return Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle, border: Border.all(color: Colors.black12)),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Transitions page
// ─────────────────────────────────────────────────────────
class _TransitionsPage extends StatelessWidget {
  final PageTransitionType current;
  final bool isDark;
  final ValueChanged<PageTransitionType> onChange;
  const _TransitionsPage({required this.current, required this.isDark, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return _Page(isDark: isDark, children: [
      _sectionTitle('Page Transition Types', isDark),
      Text('Select a transition type. Navigate between pages to see the effect.', style: TextStyle(color: _sub(isDark))),
      const SizedBox(height: 16),
      ...PageTransitionType.values.map((t) => _transitionTile(t)),
      const SizedBox(height: 20),
      _PCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How It Works', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: _text(isDark))),
            const SizedBox(height: 8),
            Text(
              'The scaffold wraps page content in an AnimatedSwitcher. '
              'When you navigate to a different page, the transition plays between '
              'the old and new page. Available via MorphingNavigationScaffold.withPages().',
              style: TextStyle(color: _sub(isDark), height: 1.5),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _transitionTile(PageTransitionType t) {
    final active = t == current;
    final info = {
      PageTransitionType.none: ('None', 'Instant page switch, no animation', Icons.flash_on_rounded),
      PageTransitionType.fade: ('Fade', 'Crossfade between pages', Icons.gradient_rounded),
      PageTransitionType.slideHorizontal: ('Slide Horizontal', 'Slide left/right transition', Icons.swap_horiz_rounded),
      PageTransitionType.slideVertical: ('Slide Vertical', 'Slide up/down transition', Icons.swap_vert_rounded),
      PageTransitionType.scale: ('Scale', 'Zoom in from center', Icons.zoom_in_rounded),
      PageTransitionType.scaleDown: ('Scale Down', 'Zoom out effect with fade', Icons.zoom_out_rounded),
      PageTransitionType.fadeSlideHorizontal: ('Fade + Slide H', 'Fade combined with horizontal slide', Icons.trending_flat_rounded),
      PageTransitionType.fadeSlideVertical: ('Fade + Slide V', 'Fade combined with vertical slide', Icons.straight_rounded),
      PageTransitionType.fadeScale: ('Fade + Scale', 'Fade combined with scale zoom', Icons.open_in_full_rounded),
      PageTransitionType.rotation: ('Rotation', '3D rotation flip on Y-axis', Icons.flip_rounded),
      PageTransitionType.cubeRotation: ('Cube Rotation', 'Cube-like 3D rotation effect', Icons.view_in_ar_rounded),
      PageTransitionType.fadeThrough: ('Fade Through', 'Material fade out + scale, fade in + scale', Icons.auto_awesome_rounded),
      PageTransitionType.sharedAxisHorizontal: ('Shared Axis H', 'Material shared axis horizontal', Icons.align_horizontal_left_rounded),
      PageTransitionType.sharedAxisVertical: ('Shared Axis V', 'Material shared axis vertical', Icons.align_vertical_top_rounded),
    }[t]!;

    return GestureDetector(
      onTap: () => onChange(t),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFF9500).withValues(alpha: 0.1) : _card(isDark),
          borderRadius: BorderRadius.circular(12),
          border: active ? Border.all(color: const Color(0xFFFF9500), width: 1.5) : null,
        ),
        child: Row(
          children: [
            Icon(info.$3, color: active ? const Color(0xFFFF9500) : _sub(isDark), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.$1, style: TextStyle(fontWeight: FontWeight.w600, color: _text(isDark))),
                  Text(info.$2, style: TextStyle(fontSize: 12, color: _sub(isDark))),
                ],
              ),
            ),
            if (active) const Icon(Icons.check_circle_rounded, color: Color(0xFFFF9500)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Header control page
// ─────────────────────────────────────────────────────────
class _HeaderPage extends StatelessWidget {
  final bool showHeader;
  final bool showPageHeader;
  final bool isDark;
  final ValueChanged<bool> onHeader;
  final ValueChanged<bool> onPageHeader;
  const _HeaderPage({required this.showHeader, required this.showPageHeader, required this.isDark, required this.onHeader, required this.onPageHeader});

  @override
  Widget build(BuildContext context) {
    return _Page(isDark: isDark, children: [
      _sectionTitle('Sidebar Header', isDark),
      _PCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Show Sidebar Header', style: TextStyle(fontWeight: FontWeight.w600, color: _text(isDark))),
              subtitle: Text('Logo, title, and toggle button in sidebar mode', style: TextStyle(color: _sub(isDark))),
              value: showHeader,
              onChanged: onHeader,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _sectionTitle('Page Header', isDark),
      _PCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Show Page Header', style: TextStyle(fontWeight: FontWeight.w600, color: _text(isDark))),
              subtitle: Text('Automatic icon + title header for each page', style: TextStyle(color: _sub(isDark))),
              value: showPageHeader,
              onChanged: onPageHeader,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _sectionTitle('Header Types', isDark),
      _PCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerType('MorphingNavHeader()', 'Full header with logo, title, subtitle, trailing widget'),
            const Divider(height: 24),
            _headerType('MorphingNavHeader.simple(title)', 'Just a title, no logo'),
            const Divider(height: 24),
            _headerType('MorphingNavHeader.withLogo(...)', 'Logo + title + optional subtitle'),
            const Divider(height: 24),
            _headerType('MorphingNavHeader.custom(builder)', 'Complete custom layout via builder'),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _headerType(String api, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(api, style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600, fontSize: 13, color: _text(isDark))),
        const SizedBox(height: 4),
        Text(desc, style: TextStyle(color: _sub(isDark), fontSize: 13)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Footer control page
// ─────────────────────────────────────────────────────────
class _FooterPage extends StatelessWidget {
  final bool showFooter;
  final bool isDark;
  final ValueChanged<bool> onChanged;
  const _FooterPage({required this.showFooter, required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _Page(isDark: isDark, children: [
      _sectionTitle('Sidebar Footer', isDark),
      _PCard(
        isDark: isDark,
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Show Footer', style: TextStyle(fontWeight: FontWeight.w600, color: _text(isDark))),
          subtitle: Text('User avatar, name, and email in sidebar mode', style: TextStyle(color: _sub(isDark))),
          value: showFooter,
          onChanged: onChanged,
        ),
      ),
      const SizedBox(height: 16),
      _sectionTitle('Footer Types', isDark),
      _PCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _footerType('MorphingNavFooter.user(name, email)', 'User info with auto-generated avatar initials'),
            const Divider(height: 24),
            _footerType('MorphingNavFooter(avatar, title, ...)', 'Full configuration with custom avatar widget'),
            const Divider(height: 24),
            _footerType('MorphingNavFooter.custom(builder)', 'Complete custom layout via builder function'),
            const Divider(height: 24),
            _footerType('MorphingNavFooter.none', 'Empty footer — nothing shown'),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _footerType(String api, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(api, style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600, fontSize: 13, color: _text(isDark))),
        const SizedBox(height: 4),
        Text(desc, style: TextStyle(color: _sub(isDark), fontSize: 13)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Status control page
// ─────────────────────────────────────────────────────────
class _StatusPage extends StatelessWidget {
  final bool show;
  final double cpu, mem, disk;
  final bool isDark;
  final ValueChanged<bool> onShow;
  final ValueChanged<double> onCpu, onMem, onDisk;
  const _StatusPage({
    required this.show,
    required this.cpu,
    required this.mem,
    required this.disk,
    required this.isDark,
    required this.onShow,
    required this.onCpu,
    required this.onMem,
    required this.onDisk,
  });

  @override
  Widget build(BuildContext context) {
    return _Page(isDark: isDark, children: [
      _sectionTitle('System Status Panel', isDark),
      _PCard(
        isDark: isDark,
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Show Status Panel', style: TextStyle(fontWeight: FontWeight.w600, color: _text(isDark))),
          subtitle: Text('CPU, memory, disk, time, and warning indicators', style: TextStyle(color: _sub(isDark))),
          value: show,
          onChanged: onShow,
        ),
      ),
      if (show) ...[
        const SizedBox(height: 16),
        _sectionTitle('Adjust Values', isDark),
        _PCard(
          isDark: isDark,
          child: Column(
            children: [
              _slider('CPU Usage', cpu, onCpu, const Color(0xFF007AFF)),
              _slider('Memory Usage', mem, onMem, const Color(0xFFFF9500)),
              _slider('Disk Usage', disk, onDisk, const Color(0xFF34C759)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionTitle('Current Values', isDark),
        _PCard(
          isDark: isDark,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _gauge('CPU', cpu, const Color(0xFF007AFF)),
              _gauge('MEM', mem, const Color(0xFFFF9500)),
              _gauge('DISK', disk, const Color(0xFF34C759)),
            ],
          ),
        ),
      ],
      const SizedBox(height: 16),
      _PCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Display Modes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: _text(isDark))),
            const SizedBox(height: 8),
            Text(
              'In sidebar mode, the status panel shows linear progress bars with labels. '
              'In tab bar mode, it shows compact circular indicators with tooltips. '
              'The values update in real-time as you drag the sliders above.',
              style: TextStyle(color: _sub(isDark), height: 1.5),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(color: _text(isDark), fontWeight: FontWeight.w500))),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(activeTrackColor: color, thumbColor: color, inactiveTrackColor: color.withValues(alpha: 0.2)),
              child: Slider(value: value, onChanged: onChanged),
            ),
          ),
          SizedBox(width: 44, child: Text('${(value * 100).round()}%', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, color: _text(isDark)))),
        ],
      ),
    );
  }

  Widget _gauge(String label, double value, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
              ),
              Text('${(value * 100).round()}', style: TextStyle(fontWeight: FontWeight.bold, color: _text(isDark))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _sub(isDark))),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Responsive page
// ─────────────────────────────────────────────────────────
class _ResponsivePage extends StatelessWidget {
  final bool isDark;
  const _ResponsivePage({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return _Page(isDark: isDark, children: [
      _sectionTitle('Responsive Behavior', isDark),
      _PCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Screen Width', style: TextStyle(color: _sub(isDark))),
            const SizedBox(height: 4),
            Text('${width.round()}px', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: _text(isDark))),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _sectionTitle('Breakpoints', isDark),
      _breakpointCard('Large (Sidebar)', '> 1024px', width > 1024, Icons.desktop_windows_rounded, const Color(0xFF007AFF)),
      const SizedBox(height: 8),
      _breakpointCard('Medium (Top Tab Bar)', '768 - 1024px', width >= 768 && width <= 1024, Icons.tablet_rounded, const Color(0xFFFF9500)),
      const SizedBox(height: 8),
      _breakpointCard('Small (Bottom Tab Bar)', '< 768px', width < 768, Icons.phone_iphone_rounded, const Color(0xFFFF3B30)),
      const SizedBox(height: 16),
      _sectionTitle('How It Works', isDark),
      _PCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The navigation automatically switches between sidebar and tab bar '
              'based on screen width. The tab bar position (top vs bottom) also '
              'adapts based on the medium breakpoint.\n\n'
              'Press T to manually toggle mode — this sets a user override that '
              'prevents auto-switching. The override persists until the controller\'s '
              'resetUserOverride() is called.',
              style: TextStyle(color: _sub(isDark), height: 1.5),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _breakpointCard(String title, String range, bool active, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.1) : _card(isDark),
        borderRadius: BorderRadius.circular(12),
        border: active ? Border.all(color: color, width: 1.5) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: active ? color : _sub(isDark), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: _text(isDark))),
                Text(range, style: TextStyle(fontSize: 12, color: _sub(isDark))),
              ],
            ),
          ),
          if (active) Icon(Icons.radio_button_checked, color: color) else Icon(Icons.radio_button_off, color: _sub(isDark)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// About page
// ─────────────────────────────────────────────────────────
class _AboutPage extends StatelessWidget {
  final bool keyboard;
  final bool isDark;
  final ValueChanged<bool> onKeyboard;
  const _AboutPage({required this.keyboard, required this.isDark, required this.onKeyboard});

  @override
  Widget build(BuildContext context) {
    return _Page(isDark: isDark, children: [
      _sectionTitle('Morphing Navigation', isDark),
      _PCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'An iPadOS-style adaptive navigation widget that morphs between '
              'a sidebar layout and a tab bar layout with smooth animations.',
              style: TextStyle(color: _sub(isDark), height: 1.5),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _sectionTitle('Keyboard Shortcuts', isDark),
      _PCard(
        isDark: isDark,
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Enable Keyboard Shortcuts', style: TextStyle(fontWeight: FontWeight.w600, color: _text(isDark))),
              subtitle: Text('Press T to toggle between sidebar and tab bar', style: TextStyle(color: _sub(isDark))),
              value: keyboard,
              onChanged: onKeyboard,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _sectionTitle('All Features', isDark),
      _PCard(
        isDark: isDark,
        child: Column(
          children: [
            _feature(Icons.swap_horiz_rounded, 'Smooth morphing animation between sidebar and tab bar'),
            _feature(Icons.devices_rounded, 'Automatic responsive switching based on screen width'),
            _feature(Icons.touch_app_rounded, 'Manual mode toggle with user override'),
            _feature(Icons.folder_open_rounded, 'Collapsible sections with staggered animations'),
            _feature(Icons.menu_rounded, 'Dropdown menus for sections in tab bar mode'),
            _feature(Icons.palette_rounded, 'Comprehensive theming with light/dark presets'),
            _feature(Icons.animation_rounded, '14 page transitions: fade, slide, scale, rotation, and more'),
            _feature(Icons.monitor_heart_rounded, 'System status panel (CPU, memory, disk)'),
            _feature(Icons.notifications_rounded, 'Badge support for notification counts'),
            _feature(Icons.keyboard_rounded, 'Keyboard shortcut (T) to toggle mode'),
            _feature(Icons.blur_on_rounded, 'Glassmorphism effects in tab bar mode'),
            _feature(Icons.person_rounded, 'Customizable header and footer'),
            _feature(Icons.title_rounded, 'Automatic page headers with icon and title'),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _feature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF007AFF)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: _text(isDark), fontSize: 14))),
        ],
      ),
    );
  }
}
