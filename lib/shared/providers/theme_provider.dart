import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

// ── Combined state holding both theme type and dark mode ──────────
class ThemeState {
  final AppThemeType type;
  final bool isDark;

  const ThemeState({
    required this.type,
    required this.isDark,
  });

  ThemeState copyWith({AppThemeType? type, bool? isDark}) {
    return ThemeState(
      type: type ?? this.type,
      isDark: isDark ?? this.isDark,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
      : super(const ThemeState(type: AppThemeType.mint, isDark: false)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('themeIndex') ?? 0;
    final isDark = prefs.getBool('isDark') ?? false;
    state = ThemeState(
      type: AppThemeType.values[index],
      isDark: isDark,
    );
  }

  /// Cycles through mint → blue → pink → mint
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final nextIndex = (state.type.index + 1) % AppThemeType.values.length;
    state = state.copyWith(type: AppThemeType.values[nextIndex]);
    await prefs.setInt('themeIndex', nextIndex);
  }

  /// Directly set a specific theme (for settings page picker)
  Future<void> setTheme(AppThemeType type) async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(type: type);
    await prefs.setInt('themeIndex', type.index);
  }

  /// Toggle dark / light mode
  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(isDark: !state.isDark);
    await prefs.setBool('isDark', state.isDark);
  }

  /// Directly set dark mode
  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(isDark: value);
    await prefs.setBool('isDark', value);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);