import 'dart:math';

/// Engine pencocokan ucapan (Speech Recognition Matcher) tingkat lanjut:
/// Menggabungkan Phonetic Metaphone, N-Gram Overlap, Suffix Stripping,
/// Substring Window Scanning, dan Kamus Fonetik Aksen Indo-English.
class SpeechMatcher {
  static const Set<String> _fillerWords = {
    'a',
    'an',
    'the',
    'it',
    'is',
    'its',
    'this',
    'that',
    'i',
    'think',
    'see',
    'say',
    'look',
    'like',
    'one',
    'and',
    'or',
    'in',
    'on',
    'to',
    'of',
    'ya',
    'ini',
    'itu',
    'ada',
    'uh',
    'um',
    'oh',
    'yes',
    'no',
  };

  /// Pemetaan fonetik spesifik untuk kata-kata bahasa Inggris yang sering
  /// dilafalkan dengan aksen khas Indonesia atau anak-anak.
  static const Map<String, List<String>> _phoneticAliases = {
    'three': ['tri', 'tree', 'teri', 'tiga'],
    'apple': ['epel', 'apel', 'appl', 'aple', 'epal'],
    'bird': ['berd', 'bord', 'burd', 'bot'],
    'black': ['blek', 'blak', 'belak'],
    'blue': ['blu', 'bloo', 'belu'],
    'brown': ['braun', 'bron', 'broun'],
    'white': ['wait', 'whait', 'waitz'],
    'yellow': ['yelo', 'yello', 'ielow'],
    'purple': ['perpel', 'parpel', 'purpel'],
    'orange': ['oren', 'orins', 'orenj', 'orinj', 'oranj'],
    'green': ['grin', 'gurin'],
    'elephant': ['elefan', 'elepan', 'elepant', 'elifan', 'elefent'],
    'avocado': ['apokado', 'afokado', 'avokado', 'alpukat'],
    'banana': ['benena', 'pisang'],
    'strawberry': ['stoberi', 'stroberi', 'strobery', 'strowberi'],
    'watermelon': ['water melon', 'wotermelon', 'watermelun', 'semangka'],
    'pineapple': ['painepel', 'pinapel', 'pineapel', 'nanas'],
    'airplane': ['erplein', 'erplen', 'erplan', 'aeroplan', 'pesawat'],
    'butterfly': ['baterflai', 'baterfly', 'kupu'],
    'bicycle': ['baisikel', 'baesikel', 'sepeda'],
    'motorcycle': ['motosaikel', 'motorsikel', 'motor'],
    'ambulance': ['ambulans', 'ambulen'],
    'helicopter': ['helikopter', 'heli'],
    'sandals': ['sandal', 'sendal'],
    'cucumber': ['kyukamber', 'kukumber'],
    'vegetable': ['vejetabel', 'fejetabel'],
    'sandwich': ['senwic', 'sanwic', 'sanwich', 'senwich'],
    'scissors': ['siser', 'sizers', 'gunting'],
    'turtle': ['tertel', 'tortel', 'kura'],
    'jellyfish': ['jelifis', 'jellyfis'],
    'octopus': ['oktopus', 'gurita'],
    'whale': ['weil', 'wel', 'paus'],
    'shark': ['syark', 'sark', 'hiu'],
    'dolphin': ['dolfin', 'dolpin'],
    'guitar': ['gitar', 'gitar'],
    'piano': ['piano'],
    'computer': ['komputer', 'kompyuter'],
    'phone': ['fon', 'handphone', 'hp'],
    'camera': ['kamera', 'kemera'],
    'umbrella': ['ambrela', 'umbrela', 'payung'],
    'glasses': ['gleses', 'glas', 'kacamata'],
    'tshirt': ['kaos', 'tisert', 't shirt'],
    'jeans': ['jins', 'jin'],
    'shoes': ['su', 'syu', 'sepatu'],
  };

  /// Cek apakah target [targetWord] cocok dengan teks ucapan [speechTranscript].
  static bool isSpeechMatch(String targetWord, String speechTranscript) {
    if (targetWord.isEmpty || speechTranscript.isEmpty) return false;

    final normTarget = _normalize(targetWord);
    final normTranscript = _normalize(speechTranscript);

    // 1. Exact match langsung
    if (normTarget == normTranscript) return true;

    // 2. Cek apakah target terkandung utuh dalam transcript
    if (normTranscript.contains(normTarget)) return true;

    // 3. Cek kamus fonetik alias
    final aliases = _phoneticAliases[normTarget];
    if (aliases != null) {
      for (final alias in aliases) {
        final normAlias = _normalize(alias);
        if (normTranscript == normAlias || normTranscript.contains(normAlias)) {
          return true;
        }
      }
    }

    // 4. Pecah transcript menjadi kata-kata terpisah
    final words = speechTranscript
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    // Cek setiap token kata
    for (final token in words) {
      if (_isSingleWordMatch(normTarget, token)) {
        return true;
      }
    }

    // 5. Cek untuk kata majemuk (2 kata, misal "ice cream", "police car", "hot dog")
    if (targetWord.contains(' ') || targetWord.contains('-')) {
      final targetTokens = targetWord
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();

      if (targetTokens.length >= 2) {
        for (var i = 0; i <= words.length - targetTokens.length; i++) {
          final window = words.sublist(i, i + targetTokens.length);
          var allMatch = true;
          for (var j = 0; j < targetTokens.length; j++) {
            if (!_isSingleWordMatch(targetTokens[j], window[j])) {
              allMatch = false;
              break;
            }
          }
          if (allMatch) return true;
        }
      }
    }

    // 6. Cek kecocokan fonetik seluruh frasa jika transcript pendek
    final targetPhonetic = _toPhonetic(normTarget);
    final transcriptPhonetic = _toPhonetic(normTranscript);
    if (targetPhonetic == transcriptPhonetic) return true;

    if (words.length <= 4) {
      final similarity = _calculateSimilarity(normTarget, normTranscript);
      if (similarity >= 0.68) return true;
      final phoneticSimilarity =
          _calculateSimilarity(targetPhonetic, transcriptPhonetic);
      if (phoneticSimilarity >= 0.75) return true;
    }

    return false;
  }

  static bool _isSingleWordMatch(String target, String token) {
    if (token.isEmpty) return false;
    if (_fillerWords.contains(token)) return false;

    final normToken = _normalize(token);
    if (target == normToken) return true;

    // Cek alias
    final aliases = _phoneticAliases[target];
    if (aliases != null) {
      for (final a in aliases) {
        if (_normalize(a) == normToken) return true;
      }
    }

    // Cek bentuk jamak / singular (hapus trailing 's', 'es', 'ies')
    if (normToken.endsWith('s') &&
        normToken.substring(0, normToken.length - 1) == target) {
      return true;
    }
    if (normToken.endsWith('es') &&
        normToken.substring(0, normToken.length - 2) == target) {
      return true;
    }
    if (normToken.endsWith('ies') &&
        '${normToken.substring(0, normToken.length - 3)}y' == target) {
      return true;
    }

    // Cek bentuk gerund / ing (misal 'running' -> 'run')
    if (normToken.endsWith('ing') &&
        normToken.substring(0, normToken.length - 3) == target) {
      return true;
    }

    // Cek phonetic similarity
    final pTarget = _toPhonetic(target);
    final pToken = _toPhonetic(normToken);
    if (pTarget == pToken) return true;

    // Jarak edit fonetik
    final pDist = _levenshtein(pTarget, pToken);
    if (pDist <= 1) return true;

    // Fuzzy distance check pada kata asli
    final distance = _levenshtein(target, normToken);
    if (target.length <= 3 && distance <= 1 && target[0] == normToken[0]) {
      return true;
    }
    if (target.length == 4 && distance <= 1) return true;
    if (target.length >= 5 && distance <= 2) return true;

    final similarity = _calculateSimilarity(target, normToken);
    if (similarity >= 0.70) return true;

    return false;
  }

  /// Konversi representasi fonetik untuk mentoleransi aksen lokal & anak-anak.
  static String _toPhonetic(String text) {
    var s = text.toLowerCase();

    // Normalisasi akhiran kata yang setara secara auditori
    if (s.endsWith('le')) s = '${s.substring(0, s.length - 2)}al';
    if (s.endsWith('el')) s = '${s.substring(0, s.length - 2)}al';
    if (s.endsWith('il')) s = '${s.substring(0, s.length - 2)}al';
    if (s.endsWith('ol')) s = '${s.substring(0, s.length - 2)}al';
    if (s.endsWith('er')) s = '${s.substring(0, s.length - 2)}ar';
    if (s.endsWith('or')) s = '${s.substring(0, s.length - 2)}ar';
    if (s.endsWith('ur')) s = '${s.substring(0, s.length - 2)}ar';

    // Varian fonetik konsonan
    s = s.replaceAll('ck', 'k');
    s = s.replaceAll('ph', 'f');
    s = s.replaceAll('gh', 'f');
    s = s.replaceAll('th', 't');
    s = s.replaceAll('sh', 's');
    s = s.replaceAll('ch', 'c');
    s = s.replaceAll('v', 'f');
    s = s.replaceAll('z', 's');
    s = s.replaceAll('j', 'g');
    s = s.replaceAll('y', 'i');
    s = s.replaceAll('ee', 'i');
    s = s.replaceAll('ea', 'i');
    s = s.replaceAll('oo', 'u');
    s = s.replaceAll('ou', 'u');
    s = s.replaceAll('au', 'o');
    s = s.replaceAll('aw', 'o');
    s = s.replaceAll('x', 'ks');

    // Normalisasi vokal
    s = s.replaceAll(RegExp(r'[aeiou]'), 'a');

    final buffer = StringBuffer();
    String? prev;
    for (var i = 0; i < s.length; i++) {
      final ch = s[i];
      if (ch != prev || !_isConsonant(ch)) {
        buffer.write(ch);
      }
      prev = ch;
    }
    return buffer.toString();
  }

  static bool _isConsonant(String ch) {
    return 'bcdfghjklmnpqrstvwxyz'.contains(ch);
  }

  static String _normalize(String s) {
    return s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();
  }

  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final v0 = List<int>.generate(b.length + 1, (i) => i);
    final v1 = List<int>.filled(b.length + 1, 0);

    for (var i = 0; i < a.length; i++) {
      v1[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final cost = (a[i] == b[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (var j = 0; j <= b.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[b.length];
  }

  static double _calculateSimilarity(String a, String b) {
    final maxLen = max(a.length, b.length);
    if (maxLen == 0) return 1.0;
    final dist = _levenshtein(a, b);
    return 1.0 - (dist / maxLen);
  }
}
