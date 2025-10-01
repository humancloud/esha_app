import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/app_ctrl.dart';
import 'providers/auth_provider.dart';
import 'screens/agent_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/welcome_screen.dart';
import 'ui/color_pallette.dart' show LKColorPaletteLight, LKColorPaletteDark;

final appCtrl = AppCtrl();

class VoiceAssistantApp extends StatelessWidget {
  const VoiceAssistantApp({super.key});

  ThemeData buildTheme({required bool isLight}) {
    final colorPallete = isLight ? LKColorPaletteLight() : LKColorPaletteDark();

    return ThemeData(
      useMaterial3: true,
      cardColor: colorPallete.bg2,
      inputDecorationTheme: InputDecorationTheme(
        fillColor: colorPallete.bg2,
        hintStyle: TextStyle(color: colorPallete.fg4, fontSize: 14),
      ),
      buttonTheme: ButtonThemeData(
        disabledColor: Colors.red,
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white,
          surface: colorPallete.fgAccent,
        ),
      ),
      colorScheme: isLight
          ? const ColorScheme.light(
              primary: Colors.black,
              secondary: Colors.black,
              surface: Colors.white,
            )
          : const ColorScheme.dark(
              primary: Colors.white,
              secondary: Colors.white,
              surface: Colors.black,
            ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider.value(value: appCtrl),
          ChangeNotifierProvider.value(value: appCtrl.roomContext),
        ],
        child: MaterialApp(
          title: 'Voice Assistant',
          theme: buildTheme(isLight: true),
          darkTheme: buildTheme(isLight: false),
          // themeMode: ThemeMode.dark,
          home: Consumer2<AuthProvider, AppCtrl>(
            builder: (ctx, authProvider, appCtrl, _) {
              // Show loading screen while checking auth status
              if (authProvider.isLoading) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // If not logged in, show login screen
              if (!authProvider.isLoggedIn) {
                return const LoginScreen();
              }

              // If logged in, show main app with proper routing
              switch (appCtrl.appScreenState) {
                case AppScreenState.login:
                  return const LoginScreen();
                case AppScreenState.welcome:
                  return const WelcomeScreen();
                case AppScreenState.agent:
                  return const AgentScreen();
                case AppScreenState.settings:
                  return const SettingsScreen();
              }
            },
          ),
        ),
      );
}
