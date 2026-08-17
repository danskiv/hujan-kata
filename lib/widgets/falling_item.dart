import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/kata.dart';
import 'hint_builder.dart';

/// Kartu kata fisik (tactile flashcard) yang turun seperti tetesan hujan kata.
/// Dirancang agar teks nama Indonesia tidak terpotong (multi-line & responsif).
class FallingItem extends StatelessWidget {
  final Kata kata;
  final double progress;
  final bool isTarget;

  const FallingItem({
    super.key,
    required this.kata,
    required this.progress,
    this.isTarget = false,
  });

  @override
  Widget build(BuildContext context) {
    final hint = HintBuilder.build(kata.en, progress);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Kartu Utama Bergaya Tactile Flashcard
        Container(
          width: 96,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF8), // Warm ivory paper
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isTarget ? const Color(0xFFF59E0B) : const Color(0xFFE5DECF),
              width: 2.2,
            ),
            boxShadow: [
              // 3D Extrusion bottom shadow
              BoxShadow(
                color: isTarget ? const Color(0xFFD97706) : const Color(0xFFC7BEAB),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
              // Soft ambient shadow
              const BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 6),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gambar Objek
              Container(
                width: 66,
                height: 66,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EFE6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/${kata.image}.png',
                    width: 58,
                    height: 58,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_outlined,
                      size: 36,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Label Arti Bahasa Indonesia (Maksimal 2 baris agar kata panjang tidak terpotong)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE5D5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  kata.id.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: kata.id.length > 10 ? 9.5 : 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF475569),
                    letterSpacing: 0.3,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Teks Hint (Underscore & Huruf Terbuka) dalam pill kontras tinggi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2235), // Dark slate pill
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF333A56), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            hint,
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF8FAFC),
              letterSpacing: 2.0,
            ),
          ),
        ),
      ],
    );
  }
}
