import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorTheme {
  final String name;
  final Color primary;
  final Color background;
  final Color surface;
  final Color text;

  const ColorTheme({
    required this.name,
    required this.primary,
    required this.background,
    required this.surface,
    required this.text,
  });
}

const List<ColorTheme> colorThemes = [
  ColorTheme(
    name: 'Domates',
    primary: Color(0xFFE53935),
    background: Color(0xFF1A1A2E),
    surface: Color(0xFF16213E),
    text: Color(0xFFFAFAFA),
  ),
  ColorTheme(
    name: 'Okyanus',
    primary: Color(0xFF1E88E5),
    background: Color(0xFF0D1B2A),
    surface: Color(0xFF1B2B3C),
    text: Color(0xFFFAFAFA),
  ),
  ColorTheme(
    name: 'Orman',
    primary: Color(0xFF43A047),
    background: Color(0xFF0F1F0F),
    surface: Color(0xFF1B2E1B),
    text: Color(0xFFFAFAFA),
  ),
  ColorTheme(
    name: 'Lavanta',
    primary: Color(0xFF8E24AA),
    background: Color(0xFF1A0A2E),
    surface: Color(0xFF2A1040),
    text: Color(0xFFFAFAFA),
  ),
  ColorTheme(
    name: 'Gün Batımı',
    primary: Color(0xFFFB8C00),
    background: Color(0xFF1A1005),
    surface: Color(0xFF2A1F0A),
    text: Color(0xFFFAFAFA),
  ),
];

class ThemeNotifier extends ChangeNotifier {
  int _index;

  ThemeNotifier(this._index);

  int get index => _index;
  ColorTheme get theme => colorThemes[_index];

  void setIndex(int i) {
    _index = i;
    notifyListeners();
  }
}

class AppSettings {
  int pomodoroDuration;
  int breakDuration;
  int themeIndex;
  bool vibrationEnabled;
  bool keepScreenOn;
  bool notificationsEnabled;

  AppSettings({
    this.pomodoroDuration = 25,
    this.breakDuration = 5,
    this.themeIndex = 0,
    this.vibrationEnabled = false,
    this.keepScreenOn = false,
    this.notificationsEnabled = true,
  });

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pomodoroDuration', pomodoroDuration);
    await prefs.setInt('breakDuration', breakDuration);
    await prefs.setInt('themeIndex', themeIndex);
    await prefs.setBool('vibrationEnabled', vibrationEnabled);
    await prefs.setBool('keepScreenOn', keepScreenOn);
    await prefs.setBool('notificationsEnabled', notificationsEnabled);
  }

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      pomodoroDuration: prefs.getInt('pomodoroDuration') ?? 25,
      breakDuration: prefs.getInt('breakDuration') ?? 5,
      themeIndex: prefs.getInt('themeIndex') ?? 0,
      vibrationEnabled: prefs.getBool('vibrationEnabled') ?? false,
      keepScreenOn: prefs.getBool('keepScreenOn') ?? false,
      notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
    );
  }

  AppSettings copyWith({
    int? pomodoroDuration,
    int? breakDuration,
    int? themeIndex,
    bool? vibrationEnabled,
    bool? keepScreenOn,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      pomodoroDuration: pomodoroDuration ?? this.pomodoroDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      themeIndex: themeIndex ?? this.themeIndex,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
