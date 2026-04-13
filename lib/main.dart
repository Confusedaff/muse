import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/music_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF080F08),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
      ],
      child: const MuseApp(),
    ),
  );
}

class MuseApp extends StatelessWidget {
  const MuseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      title: 'Muse',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: MuseTheme.lightTheme,
      darkTheme: MuseTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}

class MuseTheme {
  static const Color _primaryGreen = Color(0xFF4CAF78);
  static const Color _darkBg = Color(0xFF080F08);
  // static const Color _darkSurface = Color(0xFF101A10);
  static const Color _darkCard = Color(0xFF172017);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: _primaryGreen,
          surface: _darkBg,
          surfaceContainerHighest: _darkCard,
          onPrimary: Color(0xFF080F08),
          onSurface: Color(0xFFE8F5E8),
          secondary: Color(0xFF81C784),
          tertiary: Color(0xFF2D4A2D),
        ),
        scaffoldBackgroundColor: _darkBg,
        cardColor: _darkCard,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.w300,
            color: Color(0xFFE8F5E8),
            letterSpacing: 1.5,
          ),
          iconTheme: IconThemeData(color: Color(0xFF81C784)),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'serif',
            color: Color(0xFFE8F5E8),
            fontWeight: FontWeight.w200,
            letterSpacing: 2,
          ),
          titleLarge: TextStyle(
            color: Color(0xFFE8F5E8),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          titleMedium: TextStyle(
            color: Color(0xFFB8D4B8),
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF81C784),
            fontSize: 13,
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: _primaryGreen,
          inactiveTrackColor: _darkCard,
          thumbColor: _primaryGreen,
          overlayColor: _primaryGreen.withOpacity(0.15),
          trackHeight: 2,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? _darkBg
                  : const Color(0xFF4A4A4A)),
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? _primaryGreen
                  : const Color(0xFF2A2A2A)),
        ),
        dividerColor: const Color(0xFF1E2E1E),
        listTileTheme: const ListTileThemeData(
          iconColor: Color(0xFF4CAF78),
          textColor: Color(0xFFE8F5E8),
          subtitleTextStyle: TextStyle(color: Color(0xFF81C784), fontSize: 12),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFF81C784),
          ),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? _primaryGreen
                  : const Color(0xFF4A4A4A)),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          },
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2E7D32),
          surface: Color(0xFFF1F8F1),
          surfaceContainerHighest: Color(0xFFDCEDDC),
          onPrimary: Colors.white,
          onSurface: Color(0xFF1A2E1A),
          secondary: Color(0xFF4CAF50),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F8F1),
        cardColor: const Color(0xFFDCEDDC),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}
