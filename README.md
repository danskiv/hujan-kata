# Hujan Kata 🌧️🔤

Game edukasi belajar Bahasa Inggris. Gambar + arti Bahasa Indonesia turun pelan dari atas. Tebak nama Bahasa Inggris-nya!

- **Target:** Semua usia, fokus anak-anak
- **Platform:** Android (Play Store)
- **Teknologi:** Flutter
- **Bahasa UI:** Bahasa Indonesia

## Cara Main

1. Tekan **Mulai**
2. Pilih mode: **Ketik** (Enter untuk kirim) atau **Ngomong** (otomatis tertangkap)
3. Tebak nama Bahasa Inggris dari gambar yang turun
4. Benar = poin (+10, bonus cepat)
5. Gambar sampai bawah = -1 nyawa (3 nyawa)
6. Nyawa habis = Game Over → catat nama & skor

## Fitur

- 🖼️ **300 kosakata** (14 kategori: Hewan, Buah, Benda, Angka, Warna, Kendaraan, Makanan, Alam, Tempat, Pakaian, Tubuh, Olahraga, Musik, Hewan Laut)
- 🔤 Hint bertahap (jumlah huruf → huruf depan → huruf depan+belakang)
- 🎤 Mode ketik ATAU ngomong
- 💯 Leaderboard lokal (top 10)
- 🎁 Iklan rewarded (lihat iklan → lanjut nyawa)

## Struktur Project

```
lib/
  main.dart              # entry point
  models/                # data model kosakata, skor
  screens/               # home, game, gameover, leaderboard
  services/              # speech recognition, skor, audio
  widgets/               # falling image, hint, nyawa
assets/
  images/                # 100 gambar kosakata
  audio/                 # efek suara, musik
  data/                  # kosakata.json
docs/
  PRD.md                 # Product Requirements (desain fix)
  GAME_DESIGN.md         # detail desain game
test/
  widget_test.dart       # test
```

## Development

```bash
# di laptop Tuan (Flutter SDK sudah terinstall)
flutter create . --project-name hujan_kata
flutter pub get
flutter run
```

### Setup yang perlu dilakukan setelah `flutter create`

**1. AndroidManifest.xml** — tambahkan izin mic + AdMob App ID:
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<application ...>
  <meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY" />
</application>
```

**2. AdMob App ID** — ganti `ca-app-pub-...` di atas dengan ID asli dari:
- https://apps.admob.com → Apps → App ID

**3. Test Ad Unit** — file `lib/services/admob_service.dart` sudah pakai **test ID** Google:
- `ca-app-pub-3940256099942544/5224354917` (rewarded test)
- Ganti dengan **Ad Unit ID asli** sebelum rilis

**4. Izin mic** — mode "Ngomong" butuh izin RECORD_AUDIO (sudah di atas)

## Lisensi Aset

Lihat `assets/CREDITS.md` untuk sumber aset (semua bebas lisensi / original).
