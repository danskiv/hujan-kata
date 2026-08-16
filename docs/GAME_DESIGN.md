# Game Design — Hujan Kata

## Konsep

Game edukasi Bahasa Inggris bergaya "falling objects". Gambar turun pelan dari atas seperti hujan; pemain menebak nama Bahasa Inggris. Cocok untuk semua usia, fokus anak-anak.

## Mekanik Inti

### Spawning
- 1-3 gambar turun sekaligus (random), dengan staggered start
- Kosakata diambil acak dari pool 100 kata
- Setelah pool habis → shuffle ulang (endless)

### Falling
- Durasi turun tetap: **18 detik** per gambar
- Posisi = progress animasi linear 0 → 1
- Posisi x pseudo-random (hash kata) agar tidak menumpuk

### Hint Bertahap
| Progress | Hint |
|---|---|
| 0 - 0.33 | `_ _ _ _` (jumlah huruf) |
| 0.33 - 0.66 | `c _ _` (huruf pertama) |
| 0.66 - 1.0 | `c a t` (pertama + terakhir + 1 tengah acak) |

### Nyawa & Skor
- 3 nyawa; gambar mentok ke bawah = -1
- Jawaban benar = +10 poin
- (Roadmap: bonus kecepatan +5)

### Input
- **Mode Ketik:** TextField autofocus, Enter kirim (tanpa tombol)
- **Mode Ngomong:** speech_to_text, hasil langsung dicek otomatis

## Layar

1. **Home** — judul, tombol Mulai, deskripsi
2. **Mode Picker** — bottom sheet pilih Ketik/Ngomong
3. **Game** — area turun + header (skor/nyawa) + input bar
4. **Game Over** — input nama, simpan skor, leaderboard

## Arsitektur Kode

```
lib/
  main.dart                 # entry, tema
  models/kata.dart          # Kata + Kategori
  screens/home_screen.dart  # Home + ModePicker
  screens/game_screen.dart  # Gameplay (animasi, input)
  screens/game_over_screen.dart  # Skor + leaderboard
  services/kosakata_service.dart # Load JSON + shuffle
  services/skor_service.dart     # SharedPreferences leaderboard
  services/speech_service.dart   # speech_to_text wrapper
  widgets/hint_builder.dart      # Logika hint (unit-testable)
  widgets/falling_item.dart      # Gambar + arti + hint visual
```

## Aset

- Gambar: placeholder emoji sementara → ganti aset CC0 dari OpenGameArt
- Font: Baloo 2 (Google Fonts)
- Audio: (roadmap) efek benar/salah dari Freesound CC0

## Roadmap MVP → Rilis

1. ✅ Struktur project + 100 kosakata
2. ✅ Logika hint (tertest)
3. ✅ Gameplay dasar (turun + input + skor + nyawa)
4. ⏳ Aset gambar CC0 (100)
5. ⏳ AdMob rewarded (lihat iklan → +1 nyawa)
6. ⏳ Efek suara
7. ⏳ Test di perangkat → rilis Play Store

## Catatan Anti-Copyright

- Semua aset visual/audio harus original atau CC0/CC BY (kredit)
- Mekanik "falling + tebak" tidak bisa dipatenkan → bebas
- Hindari karakter/meme berhak cipta
