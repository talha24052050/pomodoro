# 🍅 Pomodoro

Sade ve şık bir Flutter Pomodoro zamanlayıcısı. Odaklanmak için ihtiyacın olan tek şey.

---

## Özellikler

- **Akıcı dairesel zamanlayıcı** — Arc smooth animasyonla azalır, sıçramaz
- **Otomatik faz geçişi** — Pomodoro → Kısa Mola döngüsü otomatik ilerler
- **Bildirim çubuğu entegrasyonu** — Süre ve ilerleme bildirimlerde görünür, duraklatma bildirimlere geçilir
- **5 renk teması** — Domates, Okyanus, Orman, Lavanta, Gün Batımı
- **Titreşim desteği** — Faz geçişlerinde isteğe bağlı titreşim
- **Ekranı açık tut** — Uygulama açıkken ekranın kapanmasını engeller
- **Kalıcı ayarlar** — Tüm tercihler uygulama kapansa da saklanır

---

## Ekran Görüntüleri

> _Yakında eklenecek_

---

## Kurulum

```bash
# Bağımlılıkları yükle
flutter pub get

# Android için debug APK derle
flutter build apk --debug

# Cihazda çalıştır
flutter run
```

### Gereksinimler

- Flutter 3.x+
- Android SDK 21+
- Dart 3.x+

---

## Kullanılan Paketler

| Paket | Amaç |
|---|---|
| `flutter_local_notifications` | Bildirim çubuğu entegrasyonu |
| `shared_preferences` | Ayarların kalıcı saklanması |
| `provider` | Tema state yönetimi |
| `vibration` | Geçiş titreşimleri |
| `wakelock_plus` | Ekranı açık tutma |

---

## Nasıl Kullanılır

1. **Başlat** butonuna basarak zamanlayıcıyı başlat
2. **25 dakika** boyunca odaklanarak çalış
3. Süre bitince otomatik **5 dakikalık kısa mola** başlar
4. Mola bitince otomatik yeni **Pomodoro** başlar
5. Ayarlardan süreleri ve temayı özelleştirebilirsin
6. Bildirim çubuğundan zamanlayıcıyı duraklatabilirsin

---

## Geliştiriciler

| İsim | Telefon |
|---|---|
| Hamdi Gülle | 0531 951 00 41 |
| Talha Özaslan | 0546 633 66 16 |
