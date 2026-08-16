import 'package:flutter_test/flutter_test.dart';
import 'package:hujan_kata/widgets/hint_builder.dart';

void main() {
  group('HintBuilder', () {
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
    });

    test('kata pendek 2 huruf: tahap 3 tanpa tengah', () {
      final hint = HintBuilder.build('hi', 0.9);
      expect(hint, 'h i');
    });

    test('isCorrect case-insensitive + toleran spasi', () {
      expect(HintBuilder.isCorrect('Cat', 'cat'), true);
      expect(HintBuilder.isCorrect('banana', '  BANANA '), true);
      expect(HintBuilder.isCorrect('apple', 'apel'), false);
    });
  });
}
