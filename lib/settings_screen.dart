import 'package:flutter/material.dart';
import 'models.dart';

class SettingsScreen extends StatefulWidget {
  final AppSettings settings;

  const SettingsScreen({super.key, required this.settings});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _s;

  @override
  void initState() {
    super.initState();
    _s = widget.settings.copyWith();
  }

  ColorTheme get _theme => colorThemes[_s.themeIndex];

  @override
  Widget build(BuildContext context) {
    final t = _theme;
    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: t.text.withValues(alpha: 0.7), size: 20),
          onPressed: () => Navigator.pop(context, _s),
        ),
        title: Text(
          'Ayarlar',
          style:
              TextStyle(color: t.text, fontSize: 18, fontWeight: FontWeight.w400),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          _section('Zamanlayıcı'),
          _durationTile('Pomodoro Süresi', _s.pomodoroDuration, 1, 99, (v) {
            setState(() => _s = _s.copyWith(pomodoroDuration: v));
          }),
          const SizedBox(height: 8),
          _durationTile('Kısa Mola Süresi', _s.breakDuration, 1, 30, (v) {
            setState(() => _s = _s.copyWith(breakDuration: v));
          }),
          const SizedBox(height: 28),
          _section('Renk Teması'),
          _themePicker(),
          const SizedBox(height: 28),
          _section('Genel'),
          _switchTile(
            Icons.vibration_rounded,
            'Titreşim',
            'Geçişlerde telefon titreşir',
            _s.vibrationEnabled,
            (v) => setState(() => _s = _s.copyWith(vibrationEnabled: v)),
          ),
          const SizedBox(height: 8),
          _switchTile(
            Icons.screen_lock_portrait_rounded,
            'Ekranı Açık Tut',
            'Uygulama açıkken ekran kapanmaz',
            _s.keepScreenOn,
            (v) => setState(() => _s = _s.copyWith(keepScreenOn: v)),
          ),
          const SizedBox(height: 8),
          _switchTile(
            Icons.notifications_outlined,
            'Bildirimleri Göster',
            'Zamanlayıcı durumunu bildirim çubuğunda gösterir',
            _s.notificationsEnabled,
            (v) => setState(() => _s = _s.copyWith(notificationsEnabled: v)),
          ),
          const SizedBox(height: 28),
          _section('Nasıl Kullanılır'),
          _infoCard(
            '1. Başlat butonuna basarak zamanlayıcıyı başlatın.\n'
            '2. 25 dakika boyunca odaklanarak çalışın.\n'
            '3. Süre bitince otomatik 5 dakikalık kısa molaya geçilir.\n'
            '4. Mola bitince otomatik yeni Pomodoro başlar.\n'
            '5. Ayarlardan süreleri ve temayı özelleştirebilirsiniz.\n'
            '6. Bildirim çubuğundan zamanlayıcıyı duraklatabilirsiniz.',
          ),
          const SizedBox(height: 28),
          _section('Bize Ulaşın'),
          _contactCard(),
        ],
      ),
    );
  }

  Widget _section(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: _theme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  Widget _durationTile(
      String label, int value, int min, int max, ValueChanged<int> onChange) {
    final t = _theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: t.text, fontSize: 15)),
          ),
          _stepBtn(Icons.remove, value > min ? () => onChange(value - 1) : null, t),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$value dk',
              style: TextStyle(
                  color: t.text, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          _stepBtn(Icons.add, value < max ? () => onChange(value + 1) : null, t),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback? onTap, ColorTheme t) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null
              ? t.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 18,
            color: onTap != null
                ? t.primary
                : t.text.withValues(alpha: 0.2)),
      ),
    );
  }

  Widget _themePicker() {
    final t = _theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(colorThemes.length, (i) {
          final ct = colorThemes[i];
          final selected = _s.themeIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _s = _s.copyWith(themeIndex: i)),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: ct.primary,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: Colors.white, width: 2.5)
                        : Border.all(color: Colors.transparent, width: 2.5),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                                color: ct.primary.withValues(alpha: 0.55),
                                blurRadius: 14)
                          ]
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
                const SizedBox(height: 6),
                Text(
                  ct.name,
                  style: TextStyle(
                    color: selected
                        ? t.primary
                        : t.text.withValues(alpha: 0.45),
                    fontSize: 10,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _switchTile(IconData icon, String title, String subtitle, bool value,
      ValueChanged<bool> onChanged) {
    final t = _theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: t.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: t.text, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        color: t.text.withValues(alpha: 0.4), fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: t.primary,
            activeTrackColor: t.primary.withValues(alpha: 0.4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String text) {
    final t = _theme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: t.text.withValues(alpha: 0.75),
          fontSize: 14,
          height: 1.7,
        ),
      ),
    );
  }

  Widget _contactCard() {
    final t = _theme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Geliştiriciler',
            style: TextStyle(
              color: t.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          _devRow('Hamdi Gülle', '0531 951 00 41', t),
          const SizedBox(height: 12),
          _devRow('Talha Özaslan', '0546 633 66 16', t),
        ],
      ),
    );
  }

  Widget _devRow(String name, String phone, ColorTheme t) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: t.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child:
              Icon(Icons.person_outline_rounded, color: t.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: TextStyle(
                    color: t.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(phone,
                style: TextStyle(
                    color: t.text.withValues(alpha: 0.5), fontSize: 13)),
          ],
        ),
      ],
    );
  }
}
