import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/admob_service.dart';
import '../services/skor_service.dart';
import 'game_screen.dart';

/// Layar Game Over: Hasil permainan bergaya Tactile Arcade Scorecard.
class GameOverScreen extends StatefulWidget {
  final int skor;
  final int kataTebak;
  final ModeInput mode;
  final String? categoryId;

  const GameOverScreen({
    super.key,
    required this.skor,
    this.kataTebak = 0,
    this.mode = ModeInput.ketik,
    this.categoryId,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  final TextEditingController _namaController = TextEditingController();
  final AdMobService _admob = AdMobService();
  List<SkorEntry> _leaderboard = [];
  bool _tersimpan = false;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
    _admob.loadRewardedAd();
  }

  Future<void> _loadLeaderboard() async {
    final lb = await SkorService.bacaSkor();
    if (mounted) setState(() => _leaderboard = lb);
  }

  Future<void> _simpanSkor() async {
    final nama = _namaController.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tulis nama kamu dulu ya! 😊',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFF1E2338),
        ),
      );
      return;
    }

    final lb = await SkorService.simpanSkor(nama, widget.skor);
    if (mounted) {
      setState(() {
        _leaderboard = lb;
        _tersimpan = true;
      });
    }
  }

  Future<void> _tontonIklan() async {
    final ditonton = await _admob.showRewardedAd(onReward: () {});
    if (!mounted) return;

    if (!ditonton) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Iklan belum siap, coba lagi sebentar ya! 🙏',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFF1E2338),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          mode: widget.mode,
          categoryId: widget.categoryId,
        ),
      ),
    );
  }

  String _getRankBadge() {
    if (widget.skor >= 200) return '🏆 Master Kata';
    if (widget.skor >= 100) return '🥇 Juara Emas';
    if (widget.skor >= 50) return '🥈 Juara Perak';
    return '🥉 Juara Perunggu';
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141724),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏁', style: TextStyle(fontSize: 54)),
                const SizedBox(height: 8),
                Text(
                  'PERMAINAN SELESAI',
                  style: GoogleFonts.fredoka(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Text(
                    _getRankBadge(),
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Kartu Skor Utama Tactile
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2338),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF333D5E), width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        offset: Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TOTAL SKOR KAMU',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.skor}',
                        style: GoogleFonts.fredoka(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFF59E0B),
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '🎯 ${widget.kataTebak} kata berhasil ditebak',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Form Input Nama & Leaderboard
                if (!_tersimpan) ...[
                  TextField(
                    controller: _namaController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _simpanSkor(),
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ketik nama kamu untuk papan skor...',
                      hintStyle: GoogleFonts.fredoka(
                        fontSize: 15,
                        color: const Color(0xFF64748B),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E2338),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(color: Color(0xFF333D5E), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(color: Color(0xFF333D5E), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(color: Color(0xFF10B981), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF10B981)),
                        onPressed: _simpanSkor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _simpanSkor,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF60A5FA), width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF1D4ED8),
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'SIMPAN KE PAPAN SKOR',
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  _LeaderboardWidget(list: _leaderboard),
                ],
                const SizedBox(height: 18),

                // Tombol Iklan Rewarded
                GestureDetector(
                  onTap: _tontonIklan,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2338),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_circle_fill_rounded,
                            color: Color(0xFFF59E0B), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Tonton Iklan • Lanjut Main (+1 Nyawa)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tombol Main Lagi
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameScreen(
                          mode: widget.mode,
                          categoryId: widget.categoryId,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF34D399), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF065F46),
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'MAIN LAGI',
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tombol Kembali ke Menu
                TextButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  child: Text(
                    '← Kembali ke Menu Utama',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF94A3B8),
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
}

class _LeaderboardWidget extends StatelessWidget {
  final List<SkorEntry> list;

  const _LeaderboardWidget({required this.list});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2338),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF333D5E), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            '🏆 Papan Skor Tersimpan',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < list.take(5).length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    i == 0
                        ? '🥇'
                        : i == 1
                            ? '🥈'
                            : i == 2
                                ? '🥉'
                                : '${i + 1}.',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      list[i].nama,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    '${list[i].skor} ⭐',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
