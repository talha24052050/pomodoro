import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'main.dart';
import 'models.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppSettings settings;
  final void Function(AppSettings) onSettingsChanged;

  const HomeScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static void Function()? togglePauseCallback;

  bool _isRunning = false;
  bool _isPomodoro = true;
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    togglePauseCallback = _togglePause;
    _remainingSeconds = widget.settings.pomodoroDuration * 60;
    _applyWakelock();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isRunning) {
      _remainingSeconds = _isPomodoro
          ? widget.settings.pomodoroDuration * 60
          : widget.settings.breakDuration * 60;
    }
    _applyWakelock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    togglePauseCallback = null;
    WakelockPlus.disable();
    super.dispose();
  }

  void _applyWakelock() {
    widget.settings.keepScreenOn
        ? WakelockPlus.enable()
        : WakelockPlus.disable();
  }

  int get _totalSeconds => _isPomodoro
      ? widget.settings.pomodoroDuration * 60
      : widget.settings.breakDuration * 60;

  double get _progress =>
      _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0;

  String get _timeString {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _togglePause() {
    if (!mounted) return;
    _isRunning ? _pause() : _start();
  }

  void _start() {
    if (!mounted) return;
    _timer?.cancel();
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _updateProgressNotification();
  }

  void _pause() {
    if (!mounted) return;
    _timer?.cancel();
    _timer = null;
    setState(() => _isRunning = false);
    _updateProgressNotification();
  }

  void _reset() {
    if (!mounted) return;
    _timer?.cancel();
    _timer = null;
    final total = _totalSeconds;
    setState(() {
      _isRunning = false;
      _remainingSeconds = total;
    });
    notificationsPlugin.cancel(1);
  }

  void _tick() {
    if (!mounted) return;

    if (_remainingSeconds <= 0) {
      _onPhaseComplete();
      return;
    }

    setState(() => _remainingSeconds--);

    if (widget.settings.notificationsEnabled && _remainingSeconds % 5 == 0) {
      _updateProgressNotification();
    }
  }

  void _onPhaseComplete() {
    _timer?.cancel();
    _timer = null;

    // Fire notification and vibrate BEFORE toggling phase
    final wasPomodoro = _isPomodoro;
    _fireTransitionNotification(wasPomodoro: wasPomodoro);

    if (widget.settings.vibrationEnabled) {
      Vibration.hasVibrator().then((has) {
        if (has) Vibration.vibrate(duration: 800, amplitude: 200);
      });
    }

    if (!mounted) return;

    final nextIsPomodoro = !_isPomodoro;
    final nextSeconds = nextIsPomodoro
        ? widget.settings.pomodoroDuration * 60
        : widget.settings.breakDuration * 60;

    setState(() {
      _isPomodoro = nextIsPomodoro;
      _remainingSeconds = nextSeconds;
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _updateProgressNotification();
  }

  Future<void> _updateProgressNotification() async {
    if (!mounted) return;
    if (!widget.settings.notificationsEnabled) return;

    final phase = _isPomodoro ? 'Pomodoro' : 'Kısa Mola';
    final body = _isRunning ? '$_timeString kaldı' : '$_timeString — Duraklatıldı';
    final total = _totalSeconds;
    final remaining = _remainingSeconds;
    final running = _isRunning;

    await notificationsPlugin.show(
      1,
      phase,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro_progress',
          'Zamanlayıcı Durumu',
          channelDescription: 'Pomodoro zamanlayıcı ilerlemesi',
          importance: Importance.low,
          priority: Priority.low,
          showProgress: true,
          maxProgress: total,
          progress: remaining,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          actions: [
            AndroidNotificationAction(
              'pause_resume',
              running ? 'Duraklat' : 'Devam Et',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fireTransitionNotification({required bool wasPomodoro}) async {
    if (!widget.settings.notificationsEnabled) return;
    final title = wasPomodoro ? 'Pomodoro bitti!' : 'Mola bitti!';
    final body = wasPomodoro ? 'Kısa mola başlıyor.' : 'Yeni Pomodoro başlıyor!';
    await notificationsPlugin.show(
      2,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro_alert',
          'Zamanlayıcı Bildirimleri',
          channelDescription: 'Pomodoro geçiş bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: false,
        ),
      ),
    );
  }

  void _openSettings() async {
    final result = await Navigator.push<AppSettings>(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(settings: widget.settings),
      ),
    );
    if (!mounted) return;
    if (result != null) {
      await result.save();
      widget.onSettingsChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = colorThemes[widget.settings.themeIndex];
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(theme),
            const Spacer(),
            _buildPhaseChip(theme),
            const SizedBox(height: 48),
            _buildArc(theme),
            const SizedBox(height: 64),
            _buildControls(theme),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'POMODORO',
            style: TextStyle(
              color: theme.text.withValues(alpha: 0.4),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined,
                color: theme.text.withValues(alpha: 0.5), size: 24),
            onPressed: _openSettings,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseChip(ColorTheme theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        _isPomodoro ? 'POMODORO' : 'KISA MOLA',
        style: TextStyle(
          color: theme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
        ),
      ),
    );
  }

  Widget _buildArc(ColorTheme theme) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(280, 280),
            painter: TimerArcPainter(progress: _progress, color: theme.primary),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _timeString,
                style: TextStyle(
                  color: theme.text,
                  fontSize: 54,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isRunning
                    ? 'devam ediyor'
                    : (_remainingSeconds < _totalSeconds ? 'duraklatıldı' : 'hazır'),
                style: TextStyle(
                  color: theme.text.withValues(alpha: 0.35),
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(ColorTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _reset,
          child: Icon(Icons.replay,
              color: theme.text.withValues(alpha: 0.4), size: 26),
        ),
        const SizedBox(width: 36),
        GestureDetector(
          onTap: _togglePause,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withValues(alpha: 0.45),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
        ),
        const SizedBox(width: 36),
        const SizedBox(width: 26),
      ],
    );
  }
}

class TimerArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  const TimerArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(TimerArcPainter old) =>
      old.progress != progress || old.color != color;
}
