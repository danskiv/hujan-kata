/// Logika hint bertahap berdasarkan posisi turun.
///
/// Tahap hint:
/// - posisi 0.0 - 0.33 : hanya garis bawah / jumlah huruf (_ _ _ _)
/// - posisi 0.33 - 0.66 : huruf pertama muncul
/// - posisi 0.66 - 1.0 : huruf pertama + terakhir + 1 huruf tengah (deterministik, tidak flicker)
class HintBuilder {
  /// Bangun teks hint (underscore + huruf yang terbuka).
  static String build(String jawaban, double progress) {
    final lower = jawaban.toLowerCase();
    final n = lower.length;
    if (n == 0) return '';

    final buffer = List<String>.generate(n, (i) {
      final ch = lower[i];
      // Jika karakter bukan alfanumerik (misal spasi atau strip), tampilkan apa adanya
      if (!_isAlphanumeric(ch)) return ch;
      return '_';
    });

    final letterIndices = <int>[];
    for (var i = 0; i < n; i++) {
      if (_isAlphanumeric(lower[i])) {
        letterIndices.add(i);
      }
    }

    if (letterIndices.isEmpty) return buffer.join(' ');

    // Tahap 2: Buka huruf pertama
    if (progress >= 0.33) {
      final firstIdx = letterIndices.first;
      buffer[firstIdx] = lower[firstIdx];
    }

    // Tahap 3: Buka huruf terakhir + 1 huruf tengah secara stabil
    if (progress >= 0.66) {
      final lastIdx = letterIndices.last;
      buffer[lastIdx] = lower[lastIdx];

      // Buka satu huruf tengah deterministik (jika ada minimal 3 huruf)
      if (letterIndices.length > 2) {
        final middleLetterIdx = _deterministicMiddleIndex(lower, letterIndices);
        buffer[middleLetterIdx] = lower[middleLetterIdx];
      }
    }

    return buffer.join(' ');
  }

  static bool _isAlphanumeric(String ch) {
    final code = ch.codeUnitAt(0);
    return (code >= 97 && code <= 122) || // a-z
        (code >= 65 && code <= 90) || // A-Z
        (code >= 48 && code <= 57); // 0-9
  }

  /// Pilih indeks huruf tengah secara deterministik menggunakan hash kata
  /// sehingga stabil antar-frame render dan tidak berkedip.
  static int _deterministicMiddleIndex(String word, List<int> letterIndices) {
    final innerIndices = letterIndices.sublist(1, letterIndices.length - 1);
    final hash = word.hashCode.abs();
    final chosenOffset = hash % innerIndices.length;
    return innerIndices[chosenOffset];
  }

  /// Cek apakah jawaban user benar (case-insensitive, toleran spasi, strip, dan tanda baca).
  static bool isCorrect(String jawaban, String userInput) {
    final normJawaban = _normalize(jawaban);
    final normInput = _normalize(userInput);
    if (normJawaban.isEmpty || normInput.isEmpty) return false;
    return normJawaban == normInput;
  }

  /// Normalisasi teks: lowercase dan hapus semua non-alfanumerik.
  static String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();
  }
}
