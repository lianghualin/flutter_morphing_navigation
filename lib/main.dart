import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/adaptive_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationProvider(),
      child: MaterialApp(
        title: 'iPadOS Adaptive Navigation',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainLayout(),
      ),
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AdaptiveNavigation(
        child: HomeScreen(),
      ),
    );
  }
}
