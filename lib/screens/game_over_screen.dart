import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/skor_service.dart';

/// Layar Game Over: input nama + simpan skor + tampil leaderboard.
class GameOverScreen extends StatefulWidget {
  final int skor;

  const GameOverScreen({super.key, required this.skor});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  final _namaController = TextEditingController();
  List<SkorEntry> _leaderboard = [];
  bool _tersimpan = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lb = await SkorService.bacaSkor();
    if (mounted) setState(() => _leaderboard = lb);
  }

  Future<void> _simpan() async {
    final nama = _namaController.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis nama dulu ya!')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF0FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Text('🏁', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 8),
              Text(
                'GAME OVER',
                style: GoogleFonts.baloo2(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3B5BA5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Skor kamu: ${widget.skor}',
                style: GoogleFonts.baloo2(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5B8DEF),
                ),
              ),
              const SizedBox(height: 24),
              if (!_tersimpan)
                TextField(
                  controller: _namaController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _simpan(),
                  decoration: InputDecoration(
                    hintText: 'Tulis nama kamu…',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                )
              else
                const SizedBox(height: 8),
              const SizedBox(height: 12),
              if (!_tersimpan)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BA5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: _simpan,
                  child: Text(
                    'SIMPAN SKOR',
                    style: GoogleFonts.baloo2(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                _Leaderboard(list: _leaderboard),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: Text(
                  '← Kembali ke Menu',
                  style: GoogleFonts.baloo2(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3B5BA5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  final List<SkorEntry> list;

  const _Leaderboard({required this.list});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return Text(
        'Belum ada skor.',
        style: GoogleFonts.baloo2(color: Colors.grey[600]),
      );
    }
    return Column(
      children: [
        Text(
          '🏆 Papan Skor',
          style: GoogleFonts.baloo2(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF3B5BA5),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (var i = 0; i < list.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '${i + 1}.',
                        style: GoogleFonts.baloo2(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF5B8DEF),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          list[i].nama,
                          style: GoogleFonts.baloo2(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${list[i].skor}',
                        style: GoogleFonts.baloo2(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF3B5BA5),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
