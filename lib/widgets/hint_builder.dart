/// Logika hint bertahap berdasarkan posisi turun.
///
/// Tahap hint:
/// - posisi 0.0 - 0.33 : hanya jumlah huruf (_ _ _ _)
/// - posisi 0.33 - 0.66 : huruf pertama muncul
/// - posisi 0.66 - 1.0 : huruf pertama + terakhir + 1 huruf tengah acak
class HintBuilder {
  /// Bangun teks hint (underscore + huruf yang terbuka).
  static String build(String jawaban, double progress) {
    final lower = jawaban.toLowerCase();
    final n = lower.length;
    final buffer = List<String>.filled(n, '_');

    if (progress >= 0.33) {
      // Huruf pertama muncul di tahap 2.
      buffer[0] = lower[0];
    }
    if (progress >= 0.66) {
      // Huruf terakhir muncul di tahap 3.
      buffer[n - 1] = lower[n - 1];
      // + 1 huruf tengah acak (kalau ada).
      if (n > 2) {
        final middle = _randomMiddle(lower, n);
        if (middle != null) buffer[middle] = lower[middle];
      }
    }
    return buffer.join(' ');
  }

  /// Pilih indeks huruf tengah yang belum terbuka, acak.
  static int? _randomMiddle(String word, int n) {
    final candidates = <int>[];
    for (var i = 1; i < n - 1; i++) {
      candidates.add(i);
    }
    if (candidates.isEmpty) return null;
    candidates.shuffle();
    return candidates.first;
  }

  /// Cek apakah jawaban user benar (case-insensitive, toleran spasi).
  static bool isCorrect(String jawaban, String userInput) {
    return jawaban.toLowerCase().trim() == userInput.toLowerCase().trim();
  }
}
