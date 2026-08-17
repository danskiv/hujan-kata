import 'package:flutter_test/flutter_test.dart';
import 'package:hujan_kata/services/speech_matcher.dart';

void main() {
  group('SpeechMatcher Tests', () {
    test('Exact match and casing variations', () {
      expect(SpeechMatcher.isSpeechMatch('cat', 'cat'), true);
      expect(SpeechMatcher.isSpeechMatch('cat', 'Cat'), true);
      expect(SpeechMatcher.isSpeechMatch('banana', 'BANANA'), true);
    });

    test('Number words vs digit transcriptions (e.g. twelve <-> 12, sixteen <-> 16)', () {
      expect(SpeechMatcher.isSpeechMatch('twelve', '12'), true);
      expect(SpeechMatcher.isSpeechMatch('12', 'twelve'), true);
      expect(SpeechMatcher.isSpeechMatch('sixteen', '16'), true);
      expect(SpeechMatcher.isSpeechMatch('sixteen', 'number 16'), true);
      expect(SpeechMatcher.isSpeechMatch('one', '1'), true);
      expect(SpeechMatcher.isSpeechMatch('three', '3'), true);
      expect(SpeechMatcher.isSpeechMatch('twenty', '20'), true);
    });

    test('Filler phrases and sentences match target word inside', () {
      expect(SpeechMatcher.isSpeechMatch('cat', 'it is a cat'), true);
      expect(SpeechMatcher.isSpeechMatch('apple', 'I see an apple here'), true);
      expect(SpeechMatcher.isSpeechMatch('dog', 'the dog'), true);
      expect(SpeechMatcher.isSpeechMatch('car', 'red car'), true);
    });

    test('Plural and singular forms tolerance', () {
      expect(SpeechMatcher.isSpeechMatch('cat', 'cats'), true);
      expect(SpeechMatcher.isSpeechMatch('apple', 'apples'), true);
      expect(SpeechMatcher.isSpeechMatch('box', 'boxes'), true);
    });

    test('Compound words matching', () {
      expect(SpeechMatcher.isSpeechMatch('ice cream', 'ice cream'), true);
      expect(SpeechMatcher.isSpeechMatch('ice cream', 'i want ice cream'), true);
      expect(SpeechMatcher.isSpeechMatch('police car', 'look at the police car'), true);
      expect(SpeechMatcher.isSpeechMatch('hot dog', 'hot dog'), true);
    });

    test('Phonetic accent tolerance for common Indo-English pronunciations', () {
      expect(SpeechMatcher.isSpeechMatch('three', 'tri'), true);
      expect(SpeechMatcher.isSpeechMatch('apple', 'epel'), true);
      expect(SpeechMatcher.isSpeechMatch('bird', 'berd'), true);
      expect(SpeechMatcher.isSpeechMatch('black', 'blek'), true);
      expect(SpeechMatcher.isSpeechMatch('fish', 'vis'), true);
      expect(SpeechMatcher.isSpeechMatch('twelve', 'twelv'), true);
    });

    test('Fuzzy distance tolerance', () {
      expect(SpeechMatcher.isSpeechMatch('elephant', 'elepant'), true);
      expect(SpeechMatcher.isSpeechMatch('avocado', 'afocado'), true);
      expect(SpeechMatcher.isSpeechMatch('monkey', 'mungkey'), true);
      expect(SpeechMatcher.isSpeechMatch('cat', 'dog'), false);
    });
  });
}
