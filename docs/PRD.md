# PRD — Hujan Kata (Mobile Game Edukasi)

**Versi:** 1.0.0 (FIX — terkunci 2026-08-16)
**Platform:** Android (Play Store), gratis + iklan AdMob
**Teknologi:** Flutter (ringan, satu kode Android/iOS)

---

## 1. Ringkasan

Game edukasi belajar Bahasa Inggris. Gambar + arti Bahasa Indonesia turun pelan dari atas (seperti hujan pelan). Pemain menebak nama Bahasa Inggris dari gambar. Benar = poin. Gambar sampai bawah = -1 nyawa. 3 nyawa habis = game over.

## 2. Keputusan Terkunci (jangan diubah tanpa diskusi)

| Elemen | Keputusan |
|---|---|
| **Nama game** | Hujan Kata |
| **Kosakata** | Random (campur semua kategori) |
| **Kategori** | Hewan, Buah, Benda, Angka, Warna |
| **Jumlah kosakata** | 20 kata/kategori = **100 kata total** (MVP) |
| **Kecepatan turun** | Tetap pelan (konsisten) |
| **Jumlah gambar sekali turun** | Random 1-3 sekaligus (tidak banyak) |
| **Target** | Semua usia, fokus anak-anak |
| **UI bahasa** | Bahasa Indonesia |
| **Skor** | +10/benar, bonus cepat, leaderboard nama |
| **Teknologi** | Flutter |
| **Aset** | Gratis (OpenGameArt / emoji / bebas lisensi) |
| **Monetisasi** | AdMob (rewarded + banner opsional) |

## 3. Mode Input (WAJIB pilih setelah tekan "Mulai")

**Mode Ketik:**
- Keyboard muncul & fokus otomatis
- Langsung ketik → **Enter** kirim
- Tanpa sentuh/tap apa pun

**Mode Ngomong:**
- Mic aktif otomatis
- Langsung ngomong → **otomatis tertangkap**
- Tanpa sentuh/tap apa pun

## 4. Mekanik Hint (bertahap sesuai posisi gambar)

```
Turun 1/3     → _ _ _ _ _ _      (jumlah huruf + arti ID)
Turun 2/3     → a _ _ _ _ _      (huruf pertama muncul)
Hampir mentok → a p _ _ _ _      (huruf pertama + belakang + 1 tengah acak)
```

## 5. Alur Game

```
Home → Mulai → PILIH MODE (Ketik/Ngomong) → Main
  → Gambar turun pelan + hint bertahap
  → Jawab benar → hilang + poin
  → Sampai bawah → -1 nyawa
  → Nyawa habis → Game Over → input nama → leaderboard
```

## 6. Skor & Leaderboard

- **+10 poin** per jawaban benar
- **Bonus kecepatan**: makin cepat jawab makin besar (maks +5)
- **Leaderboard lokal** (SharedPreferences): nama + skor, top 10

## 7. Teknis

- **Flutter** (SDK di laptop Tuan)
- **Speech recognition**: package `speech_to_text`
- **Timer/animasi turun**: `AnimationController` — durasi tetap (15-20 detik/gambar)
- **Random 1-3 gambar**: spawn dengan staggered start
- **Leaderboard**: `shared_preferences`

## 8. Aset

- **Gambar**: OpenGameArt / emoji (bebas lisensi) — 100 gambar kosakata
- **Musik/efek**: YouTube Audio Library / Freesound (CC0)
- **Font**: Google Fonts (gratis)
- **Karakter**: original, hindari hak cipta

## 9. Roadmap

### MVP (rilis pertama)
- [ ] 100 kosakata (5 kategori × 20)
- [ ] Mekanik turun + hint bertahap
- [ ] Mode ketik + mode ngomong
- [ ] Skor + nyawa + game over
- [ ] Leaderboard lokal
- [ ] AdMob rewarded

### Pasca-MVP
- [ ] Level & progres belajar
- [ ] Kategori baru
- [ ] Sound effect lengkap
- [ ] Upload ke Play Store

## 10. Anti-Copyright (ringkas)

- Mekanik game tidak bisa dipatenkan → bebas
- Gunakan **konsep** (istilah umum), bukan karakter berhak cipta
- Aset visual/audio: original atau lisensi bebas (CC0/CC BY dengan kredit)
- Dokumentasikan sumber aset di `assets/CREDITS.md`
