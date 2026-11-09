import 'package:flutter/material.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/core/services/storage_service.dart';
import 'package:ma3arf/core/theme/app_theme.dart';
import 'package:ma3arf/features/home/landing_screen.dart';

class GameStateScope extends InheritedNotifier<GameState> {
  const GameStateScope({
    super.key,
    required GameState gameState,
    required super.child,
  }) : super(notifier: gameState);

  static GameState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GameStateScope>();
    assert(scope != null, 'No GameStateScope found in context');
    return scope!.notifier!;
  }
}

class Ma3arfApp extends StatefulWidget {
  const Ma3arfApp({super.key});

  static Ma3arfAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<Ma3arfAppState>();

  @override
  State<Ma3arfApp> createState() => Ma3arfAppState();
}

class Ma3arfAppState extends State<Ma3arfApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  late final GameState _gameState;

  GameState get gameState => _gameState;
  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
    _gameState.loadProfile();
    _loadTheme();
  }

  @override
  void dispose() {
    _gameState.dispose();
    super.dispose();
  }

  Future<void> _loadTheme() async {
    final theme = await StorageService.loadTheme();
    if (!mounted) return;
    setState(() {
      _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
    StorageService.saveTheme(_themeMode == ThemeMode.dark ? 'dark' : 'light');
  }

  void setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return GameStateScope(
      gameState: _gameState,
      child: MaterialApp(
        title: 'مَعارِف',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        locale: const Locale('ar'),
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        home: const LandingScreen(),
      ),
    );
  }
}
