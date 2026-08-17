import 'dart:math';

/// Engine pencocokan ucapan (Speech Recognition Matcher) tingkat lanjut:
/// Mendukung konversi angka kata <-> digit ("twelve" <-> "12", "sixteen" <-> "16"),
/// kamus fonetik aksen Indo-English, plural/singular, jamak, dan fuzzy matching.
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

  /// Pemetaan angka dalam kata ke bentuk digit dan sebaliknya
  static const Map<String, String> _wordToDigit = {
    'zero': '0',
    'one': '1',
    'two': '2',
    'three': '3',
    'four': '4',
    'five': '5',
    'six': '6',
    'seven': '7',
    'eight': '8',
    'nine': '9',
    'ten': '10',
    'eleven': '11',
    'twelve': '12',
    'thirteen': '13',
    'fourteen': '14',
    'fifteen': '15',
    'sixteen': '16',
    'seventeen': '17',
    'eighteen': '18',
    'nineteen': '19',
    'twenty': '20',
    'thirty': '30',
    'forty': '40',
    'fifty': '50',
    'sixty': '60',
    'seventy': '70',
    'eighty': '80',
    'ninety': '90',
    'hundred': '100',
  };

  static final Map<String, String> _digitToWord = {
    for (final entry in _wordToDigit.entries) entry.value: entry.key,
  };

  /// Pemetaan fonetik spesifik untuk kata-kata bahasa Inggris yang sering
  /// dilafalkan dengan aksen khas Indonesia atau anak-anak.
  static const Map<String, List<String>> _phoneticAliases = {
    'one': ['1', 'wan', 'won', 'satu'],
    'two': ['2', 'tu', 'too', 'dua'],
    'three': ['3', 'tri', 'tree', 'teri', 'tiga'],
    'four': ['4', 'for', 'fur', 'empat'],
    'five': ['5', 'faif', 'paip', 'lima'],
    'six': ['6', 'siks', 'sik', 'enam'],
    'seven': ['7', 'sefen', 'sepen', 'tujuh'],
    'eight': ['8', 'eit', 'eyt', 'delapan'],
    'nine': ['9', 'nain', 'nayen', 'sembilan'],
    'ten': ['10', 'sepuluh'],
    'eleven': ['11', 'ilefen', 'elepen', 'sebelas'],
    'twelve': ['12', 'twelv', 'twelp', 'twel', 'dua belas'],
    'thirteen': ['13', 'tirtin', 'tertin', 'tiga belas'],
    'fourteen': ['14', 'fortin', 'empat belas'],
    'fifteen': ['15', 'fiftin', 'piptin', 'lima belas'],
    'sixteen': ['16', 'sikstin', 'enam belas'],
    'seventeen': ['17', 'seventin', 'sepentin', 'tujuh belas'],
    'eighteen': ['18', 'eitin', 'eytin', 'delapan belas'],
    'nineteen': ['19', 'naintin', 'nayentin', 'sembilan belas'],
    'twenty': ['20', 'twenti', 'tuwenti', 'dua puluh'],
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
    'scorpion': ['skorpion', 'kalajengking'],
    'spider': ['spaider', 'laba'],
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

    // 3. Cek Konversi Angka Kata <-> Digit (misal: "twelve" <-> "12", "sixteen" <-> "16")
    final targetDigit = _wordToDigit[normTarget];
    if (targetDigit != null) {
      if (normTranscript == targetDigit ||
          normTranscript.contains(targetDigit) ||
          speechTranscript.contains(targetDigit)) {
        return true;
      }
    }

    final targetFromDigit = _digitToWord[normTarget];
    if (targetFromDigit != null) {
      if (normTranscript == targetFromDigit ||
          normTranscript.contains(targetFromDigit)) {
        return true;
      }
    }

    // 4. Cek kamus fonetik alias
    final aliases = _phoneticAliases[normTarget];
    if (aliases != null) {
      for (final alias in aliases) {
        final normAlias = _normalize(alias);
        if (normTranscript == normAlias || normTranscript.contains(normAlias)) {
          return true;
        }
      }
    }

    // 5. Pecah transcript menjadi kata-kata terpisah
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

    // 6. Cek untuk kata majemuk (misal "ice cream", "police car", "hot dog")
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

    // 7. Cek kecocokan fonetik seluruh frasa jika transcript pendek
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

    // Cek angka kata <-> digit per-token
    if (_wordToDigit[target] == normToken) return true;
    if (_digitToWord[target] == normToken) return true;
    if (_wordToDigit[normToken] == target) return true;

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
