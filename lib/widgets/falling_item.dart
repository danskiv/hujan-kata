import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/kata.dart';
import 'hint_builder.dart';

/// Satu gambar yang turun dari atas ke bawah.
///
/// [progress] 0.0 = atas, 1.0 = bawah (mentok).
class FallingItem extends StatelessWidget {
  final Kata kata;
  final double progress;

  const FallingItem({super.key, required this.kata, required this.progress});

  @override
  Widget build(BuildContext context) {
    final hint = HintBuilder.build(kata.en, progress);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gambar (placeholder dulu — pakai emoji sebagai fallback
        // sampai aset gambar siap).
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD6E0FF), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(_iconForImage(kata.image), size: 36, color: const Color(0xFF3B5BA5)),
        ),
        const SizedBox(height: 4),
        // Arti Bahasa Indonesia (petunjuk).
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xCCFFFFFF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            kata.id,
            style: GoogleFonts.baloo2(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3B5BA5),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Hint (underscore + huruf terbuka).
        Text(
          hint,
          style: GoogleFonts.baloo2(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF3B5BA5),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  /// Peta nama gambar → ikon (placeholder sampai aset gambar siap).
  static IconData _iconForImage(String image) {
    const map = {
      'cat': Icons.pets,
      'dog': Icons.pets,
      'bird': Icons.flutter_dash,
      'fish': Icons.set_meal,
      'horse': Icons.pets,
      'apple': Icons.apple,
      'book': Icons.menu_book,
      'chair': Icons.chair,
      'phone': Icons.phone,
      'lamp': Icons.lightbulb,
      'key': Icons.key,
      'umbrella': Icons.beach_access,
      'clock': Icons.schedule,
      'one': Icons.looks_one,
      'two': Icons.looks_two,
      'three': Icons.looks_3,
      'four': Icons.looks_4,
      'five': Icons.looks_5,
      'red': Icons.color_lens,
      'blue': Icons.color_lens,
      'green': Icons.color_lens,
      'yellow': Icons.color_lens,
    };
    return map[image] ?? Icons.image;
  }
}
