import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/app_ctrl.dart';
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
          ChangeNotifierProvider.value(value: appCtrl),
          ChangeNotifierProvider.value(value: appCtrl.roomContext),
        ],
        child: MaterialApp(
          title: 'Voice Assistant',
          theme: buildTheme(isLight: true),
          darkTheme: buildTheme(isLight: false),
          // themeMode: ThemeMode.dark,
          home: Builder(
            builder: (ctx) => Selector<AppCtrl, AppScreenState>(
              selector: (ctx, appCtx) => appCtx.appScreenState,
              builder: (ctx, screen, _) {
                // Listen for error messages and show them as snackbars
                Selector<AppCtrl, String?>(
                  selector: (ctx, appCtx) => appCtx.errorMessage,
                  builder: (ctx, errorMessage, _) {
                    if (errorMessage != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 4),
                            action: SnackBarAction(
                              label: 'Dismiss',
                              textColor: Colors.white,
                              onPressed: () {
                                ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
                                appCtrl.clearError();
                              },
                            ),
                          ),
                        );
                        // Auto-clear error after showing
                        appCtrl.clearError();
                      });
                    }
                    return const SizedBox.shrink();
                  },
                );

                switch (screen) {
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
        ),
      );
}
