import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/kata.dart';
import '../services/audio_service.dart';
import '../services/kosakata_service.dart';
import '../services/speech_service.dart';
import '../widgets/falling_item.dart';
import 'game_over_screen.dart';

enum ModeInput { ketik, ngomong }

/// Layar permainan utama.
class GameScreen extends StatefulWidget {
  final ModeInput mode;

  const GameScreen({super.key, required this.mode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const _maxNyawa = 3;
  static const _durasiTurun = Duration(seconds: 18);
  static const _maksGambarSekaligus = 3;

  final _speech = SpeechService();
  final _controllerKetik = TextEditingController();
  final _audio = AudioService();

  List<Kata> _daftarKata = [];
  int _indeks = 0;

  // Item yang sedang turun: kata + posisi (0..1) + progress animasi.
  final List<_ItemTurun> _items = [];
  late final AnimationController _anim;

  int _skor = 0;
  int _nyawa = _maxNyawa;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: _durasiTurun);
    _mulai();
  }

  Future<void> _mulai() async {
    final semua = await KosakataService.loadAll();
    _daftarKata = KosakataService.shuffle(semua);
    _spawnItem();
    _anim.addListener(_onTick);
    _anim.forward();
    if (widget.mode == ModeInput.ngomong) {
      await _speech.init();
      _mulaiDengar();
    }
  }

  void _spawnItem() {
    if (_items.length >= _maksGambarSekaligus) return;
    if (_indeks >= _daftarKata.length) {
      _daftarKata = KosakataService.shuffle(_daftarKata);
      _indeks = 0;
    }
    final kata = _daftarKata[_indeks++];
    // Staggered start: item baru mulai dari atas, sisanya jalan.
    _items.add(_ItemTurun(kata: kata, progress: 0));
  }

  void _onTick() {
    setState(() {
      for (final item in _items) {
        item.progress = _anim.value;
      }
      // Cek item yang mentok (progress >= 1).
      _cekNentok();
    });
  }

  void _cekNentok() {
    final nentok = _items.where((i) => i.progress >= 1.0).toList();
    for (final item in nentok) {
      _items.remove(item);
      _nyawa -= 1;
      _spawnItem();
    }
    if (_nyawa <= 0) {
      _gameOver = true;
      _anim.stop();
      _speech.stop();
      _audio.gameOver();
      Future.microtask(_keGameOver);
    }
  }

  void _jawab(_ItemTurun item) {
    if (!_items.contains(item)) return;
    setState(() {
      _items.remove(item);
      _skor += 10;
      _spawnItem();
    });
    _audio.benar();
  }

  void _jawabBenar(String input) {
    // Cari item yang jawabannya cocok (case-insensitive).
    for (final item in _items.toList()) {
      if (item.kata.en.toLowerCase().trim() == input.toLowerCase().trim()) {
        _jawab(item);
        return;
      }
    }
    // Salah → efek suara (tidak hilang nyawa).
    _audio.salah();
  }

  void _mulaiDengar() {
    _speech.setErrorHandler((_) => _mulaiDengar()); // retry kalau error
    _speech.listen(
      onResult: (text) => _jawabBenar(text),
    );
  }

  void _keGameOver() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameOverScreen(skor: _skor),
      ),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    _controllerKetik.dispose();
    _speech.stop();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF0FF),
      body: SafeArea(
        child: Stack(
          children: [
            // Area item turun.
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      for (final item in _items)
                        Positioned(
                          left: _xRandom(item),
                          top: constraints.maxHeight * item.progress,
                          child: FallingItem(kata: item.kata, progress: item.progress),
                        ),
                    ],
                  );
                },
              ),
            ),
            // Header: skor & nyawa.
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: _Header(skor: _skor, nyawa: _nyawa),
            ),
            // Input di bawah.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _InputBar(
                mode: widget.mode,
                controller: _controllerKetik,
                onSubmit: _jawabBenar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _xRandom(_ItemTurun item) {
    // Posisi x pseudo-random per item (biar tidak menumpuk).
    final seed = item.kata.en.hashCode % 100;
    return (seed / 100) * 200; // 0..200 px dari kiri
  }
}

class _ItemTurun {
  final Kata kata;
  double progress;
  _ItemTurun({required this.kata, required this.progress});
}

class _Header extends StatelessWidget {
  final int skor;
  final int nyawa;

  const _Header({required this.skor, required this.nyawa});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 4)],
            ),
            child: Text(
              '⭐ $skor',
              style: GoogleFonts.baloo2(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF3B5BA5),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 4)],
            ),
            child: Text(
              '❤️' * nyawa + '🖤' * (3 - nyawa),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final ModeInput mode;
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;

  const _InputBar({
    required this.mode,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == ModeInput.ngomong) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white.withValues(alpha: 0.95),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic, color: Color(0xFF3B5BA5), size: 28),
            const SizedBox(width: 8),
            Text(
              'Ucapkan jawabannya… 🎤',
              style: GoogleFonts.baloo2(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3B5BA5),
              ),
            ),
          ],
        ),
      );
    }
    // Mode ketik — autofocus, Enter untuk kirim, tanpa tombol.
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white.withValues(alpha: 0.95),
      child: TextField(
        controller: controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            onSubmit(value);
            controller.clear();
          }
        },
        style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: 'Ketik jawaban, tekan Enter…',
          filled: true,
          fillColor: const Color(0xFFF0F4FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}
