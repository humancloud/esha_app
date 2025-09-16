
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/ai_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/ai',
      builder: (BuildContext context, GoRouterState state) {
        return const AiScreen();
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) {
        return const SettingsScreen();
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Isha AI Friend',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2c3e50),
        scaffoldBackgroundColor: const Color(0xFF2c3e50),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4a6741),
          secondary: Color(0xFF4a6741),
          surface: Color(0xFF2c3e50),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0f2027),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4a6741),
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
