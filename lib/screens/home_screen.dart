import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'game_screen.dart';

/// Layar utama: judul + tombol Mulai.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3B5BA5), Color(0xFF5B8DEF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🌧️',
                  style: TextStyle(fontSize: 72),
                ),
                const SizedBox(height: 16),
                Text(
                  'HUJAN KATA',
                  style: GoogleFonts.baloo2(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tebak nama Bahasa Inggris dari gambar!',
                  style: GoogleFonts.baloo2(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3B5BA5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _pilihMode,
                  child: Text(
                    'MULAI',
                    style: GoogleFonts.baloo2(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '3 nyawa · 300 kata · seru!',
                  style: GoogleFonts.baloo2(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 24),
                // Tombol Tentang (kredit aset — wajib lisensi OpenMoji)
                TextButton(
                  onPressed: () => showAboutDialog(
                    context: context,
                    applicationName: 'Hujan Kata',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Text('🌧️', style: TextStyle(fontSize: 40)),
                    children: [
                      Text(
                        'Game edukasi belajar Bahasa Inggris.\n\n'
                        'Emoji oleh OpenMoji — openmoji.org (CC BY-SA 4.0)\n'
                        'Font: Baloo 2 (Google Fonts, OFL)\n'
                        'Efek suara: original (bebas hak cipta)',
                        style: GoogleFonts.baloo2(fontSize: 13),
                      ),
                    ],
                  ),
                  child: Text(
                    'ℹ️ Tentang & Kredit',
                    style: GoogleFonts.baloo2(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pilihMode() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const ModePicker(),
    );
  }
}

/// Bottom sheet pemilih mode: Ketik atau Ngomong.
class ModePicker extends StatelessWidget {
  const ModePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pilih Cara Menjawab',
            style: GoogleFonts.baloo2(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ModeCard(
                  emoji: '⌨️',
                  label: 'Ketik',
                  desc: 'Ketik jawaban, tekan Enter',
                  onTap: () => _start(context, ModeInput.ketik),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModeCard(
                  emoji: '🎤',
                  label: 'Ngomong',
                  desc: 'Langsung ucapkan jawaban',
                  onTap: () => _start(context, ModeInput.ngomong),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _start(BuildContext context, ModeInput mode) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(mode: mode)),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String desc;
  final VoidCallback onTap;

  const _ModeCard({
    required this.emoji,
    required this.label,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD6E0FF)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.baloo2(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
