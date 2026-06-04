import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'models.dart';
import 'home_screen.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {}

Future<void> initNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);
  await notificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (response) {
      if (response.actionId == 'pause_resume') {
        HomeScreenState.togglePauseCallback?.call();
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  final androidPlugin = notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.requestNotificationsPermission();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatefulWidget {
  const PomodoroApp({super.key});

  @override
  State<PomodoroApp> createState() => _PomodoroAppState();
}

class _PomodoroAppState extends State<PomodoroApp> {
  AppSettings _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    AppSettings.load().then((s) => setState(() => _settings = s));
  }

  void _onSettingsChanged(AppSettings s) => setState(() => _settings = s);

  @override
  Widget build(BuildContext context) {
    final theme = colorThemes[_settings.themeIndex];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: theme.background,
        colorScheme: ColorScheme.dark(
          primary: theme.primary,
          surface: theme.surface,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(
        settings: _settings,
        onSettingsChanged: _onSettingsChanged,
      ),
    );
  }
}
