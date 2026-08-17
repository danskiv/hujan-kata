import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/kata.dart';
import '../services/audio_service.dart';
import '../services/kosakata_service.dart';
import '../services/skor_service.dart';
import 'game_screen.dart';

/// Layar utama: Pilihan mode permainan (Klasik vs Unlimited) dan kategori kata.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Kategori> _categories = [];
  String _selectedCategoryId = 'all';
  bool _isUnlimitedMode = false; // Mode Klasik (false) vs Unlimited (true)

  @override
  void initState() {
    super.initState();
    AudioService.initPreferences();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await KosakataService.loadCategories();
    if (mounted) {
      setState(() => _categories = cats);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141724),
      body: Stack(
        children: [
          // Background ambient grid & rain dots
          Positioned.fill(
            child: CustomPaint(
              painter: _HomeBackgroundPainter(),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge Weather Emblem
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2338),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF333D5E), width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🌧️', style: TextStyle(fontSize: 46)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Judul Game
                    Text(
                      'HUJAN KATA',
                      style: GoogleFonts.fredoka(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF8FAFC),
                        letterSpacing: 2.0,
                        shadows: const [
                          Shadow(
                            color: Color(0xFF0F121D),
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      'Tebak Kosakata Bahasa Inggris yang Turun!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pilihan Tipe Permainan: Klasik vs Unlimited
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2338),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF333D5E), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTypeTab(
                            title: '🏆 Klasik (3 Nyawa)',
                            isActive: !_isUnlimitedMode,
                            onTap: () => setState(() => _isUnlimitedMode = false),
                          ),
                          _buildTypeTab(
                            title: '♾️ Unlimited (Santai)',
                            isActive: _isUnlimitedMode,
                            onTap: () => setState(() => _isUnlimitedMode = true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pilihan Kategori Kosakata (Pill Selector)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2338),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF333D5E), width: 1.5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategoryId,
                          dropdownColor: const Color(0xFF1E2338),
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFF59E0B)),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'all',
                              child: Text('🎲 Semua Kategori (300 Kosakata)'),
                            ),
                            for (final cat in _categories)
                              DropdownMenuItem(
                                value: cat.id,
                                child: Text('📁 ${cat.name} (${cat.words.length} kata)'),
                              ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCategoryId = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol 3D Physical "MULAI MAIN"
                    GestureDetector(
                      onTap: _pilihMode,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 280),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isUnlimitedMode
                              ? const Color(0xFF3B82F6) // Ocean Blue for Unlimited
                              : const Color(0xFF10B981), // Action Green for Classic
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: _isUnlimitedMode
                                ? const Color(0xFF60A5FA)
                                : const Color(0xFF34D399),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _isUnlimitedMode
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFF065F46),
                              offset: const Offset(0, 5),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _isUnlimitedMode ? 'MAIN UNLIMITED' : 'MULAI MAIN',
                            style: GoogleFonts.fredoka(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Fitur Highlight Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _FeatureTag(
                          icon: _isUnlimitedMode ? '♾️' : '❤️',
                          label: _isUnlimitedMode ? 'Nyawa Bebas' : '3 Nyawa',
                        ),
                        const _FeatureTag(icon: '⚡', label: 'Bonus Cepat'),
                        const _FeatureTag(icon: '🎤', label: 'Voice AI Presisi'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Tombol Baris Papan Skor & Tentang
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFF59E0B),
                          ),
                          onPressed: _bukaLeaderboard,
                          icon: const Icon(Icons.emoji_events_outlined, size: 20),
                          label: Text(
                            'Papan Skor',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF94A3B8),
                          ),
                          onPressed: () => showAboutDialog(
                            context: context,
                            applicationName: 'Hujan Kata',
                            applicationVersion: '1.0.0',
                            applicationIcon:
                                const Text('🌧️', style: TextStyle(fontSize: 40)),
                            children: [
                              Text(
                                'Game edukasi belajar Bahasa Inggris berbasis gambar falling objects.\n\n'
                                '• Mode: Klasik (3 Nyawa) & Unlimited (Santai)\n'
                                '• Gambar: OpenMoji (openmoji.org) — Lisensi CC BY-SA 4.0\n'
                                '• Font: Fredoka & Plus Jakarta Sans (Google Fonts, OFL)\n'
                                '• Efek Suara: Original (bebas hak cipta)',
                                style: GoogleFonts.plusJakartaSans(fontSize: 13),
                              ),
                            ],
                          ),
                          icon: const Icon(Icons.info_outline, size: 20),
                          label: Text(
                            'Tentang',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2D3654) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: const Color(0xFF475569), width: 1.2)
              : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  void _pilihMode() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ModePicker(
        categoryId: _selectedCategoryId,
        isUnlimited: _isUnlimitedMode,
      ),
    );
  }

  Future<void> _bukaLeaderboard() async {
    final list = await SkorService.bacaSkor();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2338),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🏆 Top 10 Papan Skor',
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Belum ada rekor skor tersimpan. Jadilah yang pertama!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8)),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: list.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Color(0xFF2D3654), height: 1),
                    itemBuilder: (context, i) {
                      final item = list[i];
                      final medali = i == 0
                          ? '🥇'
                          : i == 1
                              ? '🥈'
                              : i == 2
                                  ? '🥉'
                                  : '${i + 1}.';
                      return ListTile(
                        leading: Text(
                          medali,
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                        title: Text(
                          item.nama,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        trailing: Text(
                          '${item.skor} ⭐',
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF333D5E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Tutup',
                  style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeatureTag extends StatelessWidget {
  final String icon;
  final String label;

  const _FeatureTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2338),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D3654)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet pemilih cara bermain (Ketik vs Ngomong)
class ModePicker extends StatelessWidget {
  final String categoryId;
  final bool isUnlimited;

  const ModePicker({
    super.key,
    required this.categoryId,
    this.isUnlimited = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2338),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFF333D5E), width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF333D5E),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isUnlimited ? 'Pilih Input (Mode Unlimited ♾️)' : 'Pilih Cara Bermain',
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ModeCard(
                  emoji: '⌨️',
                  label: 'Ketik',
                  desc: 'Ketik jawaban lalu tekan Enter',
                  badgeColor: const Color(0xFF3B82F6),
                  onTap: () => _start(context, ModeInput.ketik),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ModeCard(
                  emoji: '🎤',
                  label: 'Ngomong',
                  desc: 'Ucapkan kata langsung lewat mic',
                  badgeColor: const Color(0xFF10B981),
                  onTap: () => _start(context, ModeInput.ngomong),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _start(BuildContext context, ModeInput mode) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          mode: mode,
          categoryId: categoryId,
          isUnlimited: isUnlimited,
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String desc;
  final Color badgeColor;
  final VoidCallback onTap;

  const _ModeCard({
    required this.emoji,
    required this.label,
    required this.desc,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF161928),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2D3654), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 38)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rainPaint = Paint()
      ..color = const Color(0x0CFFFFFF)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final random = Random(999);
    for (var i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final len = 25.0 + random.nextDouble() * 30.0;
      canvas.drawLine(Offset(x, y), Offset(x - 6, y + len), rainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
