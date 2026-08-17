import 'package:flutter_test/flutter_test.dart';
import 'package:hujan_kata/widgets/hint_builder.dart';

void main() {
  group('HintBuilder Tests', () {
    test('tahap awal hanya underscore (jumlah huruf)', () {
      final hint = HintBuilder.build('cat', 0.1);
      expect(hint, '_ _ _');
    });

    test('tahap 2 muncul huruf pertama', () {
      final hint = HintBuilder.build('cat', 0.5);
      expect(hint, 'c _ _');
    });

    test('tahap 3 muncul huruf pertama + terakhir + 1 tengah', () {
      final hint = HintBuilder.build('cat', 0.9);
      expect(hint.split(' ').length, 3);
      expect(hint.startsWith('c'), true);
      expect(hint.endsWith('t'), true);
      expect(hint, 'c a t');
    });

    test('deterministik: hasil hint pada progress >= 0.66 selalu konsisten (tidak flicker)', () {
      final hint1 = HintBuilder.build('elephant', 0.8);
      final hint2 = HintBuilder.build('elephant', 0.8);
      final hint3 = HintBuilder.build('elephant', 0.9);
      expect(hint1, hint2);
      expect(hint2, hint3);
      expect(hint1.startsWith('e'), true);
      expect(hint1.endsWith('t'), true);
    });

    test('kata pendek 2 huruf: tahap 3 tanpa tengah', () {
      final hint = HintBuilder.build('hi', 0.9);
      expect(hint, 'h i');
    });

    test('kata dengan spasi (compound words) mempertahankan spasi', () {
      final hint1 = HintBuilder.build('ice cream', 0.1);
      expect(hint1, '_ _ _   _ _ _ _ _');
      final hint2 = HintBuilder.build('ice cream', 0.5);
      expect(hint2.startsWith('i'), true);
    });

    test('isCorrect case-insensitive + toleran spasi dan strip', () {
      expect(HintBuilder.isCorrect('Cat', 'cat'), true);
      expect(HintBuilder.isCorrect('banana', '  BANANA '), true);
      expect(HintBuilder.isCorrect('ice cream', 'icecream'), true);
      expect(HintBuilder.isCorrect('ice-cream', 'ice cream'), true);
      expect(HintBuilder.isCorrect('t-shirt', 'tshirt'), true);
      expect(HintBuilder.isCorrect('apple', 'apel'), false);
    });
  });
}
