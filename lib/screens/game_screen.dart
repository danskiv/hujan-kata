import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/kata.dart';
import '../services/audio_service.dart';
import '../services/kosakata_service.dart';
import '../services/speech_matcher.dart';
import '../services/speech_service.dart';
import '../widgets/falling_item.dart';
import '../widgets/hint_builder.dart';
import 'game_over_screen.dart';

enum ModeInput { ketik, ngomong }

/// Item yang sedang aktif turun di layar permainan.
class ItemJatuh {
  final Kata kata;
  final int lane; // 0, 1, atau 2
  double progress; // 0.0 (atas) -> 1.0 (bawah)
  final double speed;

  ItemJatuh({
    required this.kata,
    required this.lane,
    this.progress = 0.0,
    this.speed = 1.0 / 18.0, // 18 detik per item
  });
}

/// Floating feedback teks bonus saat tebakan berhasil
class FloatingFeedback {
  final String text;
  final Color color;
  final double x;
  final double y;
  double opacity;

  FloatingFeedback({
    required this.text,
    required this.color,
    required this.x,
    required this.y,
    this.opacity = 1.0,
  });
}

/// Layar gameplay utama Hujan Kata dengan indikator mic ultra-jelas dan mode unlimited.
class GameScreen extends StatefulWidget {
  final ModeInput mode;
  final String? categoryId;
  final bool isUnlimited;

  const GameScreen({
    super.key,
    required this.mode,
    this.categoryId,
    this.isUnlimited = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxNyawa = 3;
  static const int _maksItemAktif = 3;
  static const double _intervalSpawnDetik = 5.0;

  final SpeechService _speech = SpeechService();
  final TextEditingController _controllerKetik = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AudioService _audio = AudioService();

  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  List<Kata> _poolKata = [];
  int _indeksKata = 0;

  final List<ItemJatuh> _items = [];
  final List<FloatingFeedback> _feedbacks = [];

  double _timerSpawnAkumulasi = 0.0;
  int _skor = 0;
  int _nyawa = _maxNyawa;
  int _kataBerhasil = 0;
  bool _isPaused = false;
  bool _isGameOver = false;
  bool _isAudioMuted = false;
  bool _isMicActive = false;
  double _soundLevel = 0.0; // 0.0 sampai 1.0
  String _speechTranscript = '';

  @override
  void initState() {
    super.initState();
    _isAudioMuted = AudioService.isMuted;
    _ticker = createTicker(_onTick);
    _mulaiGame();
  }

  Future<void> _mulaiGame() async {
    final list = await KosakataService.loadKata(categoryId: widget.categoryId);
    _poolKata = KosakataService.shuffle(list);
    _indeksKata = 0;

    _spawnItem();

    if (widget.mode == ModeInput.ngomong) {
      await _speech.init();
      _mulaiDengar();
    }

    _lastElapsed = Duration.zero;
    _ticker.start();
  }

  void _spawnItem() {
    if (_items.length >= _maksItemAktif || _isGameOver || _isPaused) return;

    if (_indeksKata >= _poolKata.length) {
      _poolKata = KosakataService.shuffle(_poolKata);
      _indeksKata = 0;
    }

    final kata = _poolKata[_indeksKata++];

    // Tentukan lane (0, 1, 2) yang paling sepi
    final laneCounts = [0, 0, 0];
    for (final it in _items) {
      if (it.progress < 0.5) {
        laneCounts[it.lane]++;
      }
    }

    int chosenLane = 0;
    int minCount = 999;
    for (var i = 0; i < 3; i++) {
      if (laneCounts[i] < minCount) {
        minCount = laneCounts[i];
        chosenLane = i;
      }
    }

    setState(() {
      _items.add(ItemJatuh(
        kata: kata,
        lane: chosenLane,
        progress: 0.0,
      ));
    });
  }

  void _onTick(Duration elapsed) {
    if (_isPaused || _isGameOver) return;

    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final delta = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    if (delta <= 0 || delta > 0.1) return;

    setState(() {
      // 1. Perbarui posisi item yang jatuh
      final toRemove = <ItemJatuh>[];
      for (final item in _items) {
        item.progress += item.speed * delta;
        if (item.progress >= 1.0) {
          toRemove.add(item);
        }
      }

      // 2. Tangani item yang mentok di bawah
      for (final item in toRemove) {
        _items.remove(item);
        _handleMentok(item);
      }

      // 3. Tangani timer spawn berkala
      _timerSpawnAkumulasi += delta;
      if (_items.isEmpty ||
          (_timerSpawnAkumulasi >= _intervalSpawnDetik &&
              _items.length < _maksItemAktif)) {
        _timerSpawnAkumulasi = 0;
        _spawnItem();
      }

      // 4. Perbarui animasi floating feedback
      for (final fb in _feedbacks.toList()) {
        fb.opacity -= delta * 1.5;
        if (fb.opacity <= 0) {
          _feedbacks.remove(fb);
        }
      }
    });
  }

  void _handleMentok(ItemJatuh item) {
    if (widget.isUnlimited) {
      // Mode Unlimited: Nyawa tidak berkurang, tidak game over
      _audio.click();
      if (_items.isEmpty) {
        _spawnItem();
      }
      return;
    }

    // Mode Klasik: -1 Nyawa
    _audio.salah();
    _nyawa--;

    if (_nyawa <= 0) {
      _triggerGameOver();
    } else if (_items.isEmpty) {
      _spawnItem();
    }
  }

  void _periksaJawaban(String input) {
    if (_isGameOver || _isPaused || input.trim().isEmpty) return;

    // Cari item aktif yang cocok menggunakan SpeechMatcher / HintBuilder
    ItemJatuh? matchedItem;
    for (final item in _items) {
      if (widget.mode == ModeInput.ngomong) {
        if (SpeechMatcher.isSpeechMatch(item.kata.en, input)) {
          matchedItem = item;
          break;
        }
      } else {
        if (HintBuilder.isCorrect(item.kata.en, input)) {
          matchedItem = item;
          break;
        }
      }
    }

    if (matchedItem != null) {
      final targetItem = matchedItem;
      int poin = 10;
      String bonusText = '+10 ⭐';

      if (targetItem.progress < 0.33) {
        poin = 15;
        bonusText = '+15 CEPAT! ⚡';
      } else if (targetItem.progress < 0.66) {
        poin = 12;
        bonusText = '+12 BAGUS! ✨';
      }

      _audio.benar();

      setState(() {
        _skor += poin;
        _kataBerhasil++;
        _feedbacks.add(FloatingFeedback(
          text: bonusText,
          color: const Color(0xFF10B981),
          x: _hitungPosX(targetItem.lane, MediaQuery.of(context).size.width),
          y: MediaQuery.of(context).size.height * targetItem.progress * 0.65 + 40,
        ));
        _items.remove(targetItem);
        _speechTranscript = '';
      });

      if (_items.isEmpty) {
        _spawnItem();
      }
    } else {
      if (widget.mode == ModeInput.ketik) {
        _audio.salah();
      }
    }
  }

  double _hitungPosX(int lane, double screenWidth) {
    const itemWidth = 96.0;
    final usableWidth = max(screenWidth - itemWidth - 28, 100.0);
    final laneSpacing = usableWidth / 2;
    return 14 + (lane * laneSpacing);
  }

  void _mulaiDengar() {
    _speech.setStatusHandler((listening) {
      if (mounted) setState(() => _isMicActive = listening);
    });

    _speech.listen(
      onResult: (text) {
        if (!mounted || _isPaused || _isGameOver) return;
        setState(() {
          _speechTranscript = text;
        });
        _periksaJawaban(text);
      },
      onSoundLevelChange: (level) {
        if (!mounted || _isPaused || _isGameOver) return;
        double normalized = 0.0;
        if (level > 0) {
          normalized = (level / 10.0).clamp(0.0, 1.0);
        } else if (level < 0) {
          normalized = ((level + 10.0) / 10.0).clamp(0.0, 1.0);
        }
        setState(() {
          _soundLevel = normalized;
          _isMicActive = true;
        });
      },
    );
  }

  void _triggerGameOver() {
    _isGameOver = true;
    _ticker.stop();
    _speech.stop();
    _audio.gameOver();

    Future.microtask(() {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameOverScreen(
            skor: _skor,
            kataTebak: _kataBerhasil,
            mode: widget.mode,
            categoryId: widget.categoryId,
          ),
        ),
      );
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _ticker.stop();
        _speech.stop();
      } else {
        _lastElapsed = Duration.zero;
        _ticker.start();
        if (widget.mode == ModeInput.ngomong) {
          _mulaiDengar();
        }
      }
    });

    if (_isPaused) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _buildPauseDialog(ctx),
      );
    }
  }

  Widget _buildPauseDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF202538),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF333D5E), width: 2),
      ),
      title: Center(
        child: Text(
          'Permainan Dijeda ⏸️',
          style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF161928),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2D3654)),
            ),
            child: Text(
              'Skor: $_skor ⭐ • ${widget.isUnlimited ? "Unlimited" : "$_nyawa Nyawa"}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFF59E0B),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _togglePause();
            },
            child: Text(
              'LANJUTKAN',
              style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text(
              'Keluar ke Menu Utama',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controllerKetik.dispose();
    _focusNode.dispose();
    _speech.stop();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161928),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Canvas Grid & Rain Streaks
            Positioned.fill(
              child: CustomPaint(
                painter: _TactileArcadeBackgroundPainter(),
              ),
            ),

            // Area Jatuh Objek
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxY = constraints.maxHeight - 170;
                  return Stack(
                    children: [
                      for (final item in _items)
                        Positioned(
                          left: _hitungPosX(item.lane, constraints.maxWidth),
                          top: max(0.0, maxY * item.progress),
                          child: FallingItem(
                            kata: item.kata,
                            progress: item.progress,
                          ),
                        ),

                      // Floating Feedback (Skor Bonus)
                      for (final fb in _feedbacks)
                        Positioned(
                          left: fb.x,
                          top: fb.y,
                          child: Opacity(
                            opacity: fb.opacity.clamp(0.0, 1.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2238),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFF333D5E), width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Color(0x66000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 3)),
                                ],
                              ),
                              child: Text(
                                fb.text,
                                style: GoogleFonts.fredoka(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: fb.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // Header Atas (Skor, Nyawa / Unlimited, Sound, Pause)
            Positioned(
              top: 10,
              left: 14,
              right: 14,
              child: _buildHeader(),
            ),

            // Input Bar di Bawah (dengan Live Audio Visualizer Ultra Jelas)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildInputBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Badge Skor Tactile
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF202538),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF333D5E), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 3),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                '$_skor',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),

        // Indikator Nyawa (Klasik 3 Hearts ATAU Unlimited Infinity Badge)
        if (widget.isUnlimited)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x333B82F6),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('♾️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  'UNLIMITED',
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF60A5FA),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF202538),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF333D5E), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final active = index < _nyawa;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    active ? '❤️' : '🖤',
                    style: TextStyle(
                      fontSize: 18,
                      color: active ? Colors.redAccent : Colors.grey[700],
                    ),
                  ),
                );
              }),
            ),
          ),
        const SizedBox(width: 8),

        // Tombol Suara
        InkWell(
          onTap: () async {
            final muted = await AudioService.toggleMute();
            setState(() => _isAudioMuted = muted);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF202538),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF333D5E), width: 1.5),
            ),
            child: Icon(
              _isAudioMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: const Color(0xFF94A3B8),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Tombol Jeda (Pause)
        InkWell(
          onTap: _togglePause,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF202538),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF333D5E), width: 1.5),
            ),
            child: const Icon(
              Icons.pause_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    if (widget.mode == ModeInput.ngomong) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2235),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: const Border(top: BorderSide(color: Color(0xFF333D5E), width: 2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 20,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Mic Orb dengan Animated Glowing Ring
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isMicActive
                    ? const Color(0xFF10B981)
                    : const Color(0xFF333D5E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isMicActive
                      ? const Color(0xFF34D399)
                      : const Color(0xFF64748B),
                  width: 2.5,
                ),
                boxShadow: _isMicActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(
                              alpha: (0.4 + _soundLevel * 0.6).clamp(0.0, 1.0)),
                          blurRadius: 16 + _soundLevel * 18,
                          spreadRadius: 3 + _soundLevel * 8,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                Icons.mic_rounded,
                color: _isMicActive ? Colors.white : const Color(0xFF94A3B8),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),

            // Transcript text dan Live Audio Leveling Equalizer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _isMicActive
                              ? const Color(0xFF10B981).withValues(alpha: 0.2)
                              : const Color(0xFF333D5E),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isMicActive
                                ? const Color(0xFF10B981)
                                : const Color(0xFF475569),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: _isMicActive
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF94A3B8),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isMicActive
                                  ? 'MIC AKTIF (BICARA)'
                                  : 'MENYIAPKAN...',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _isMicActive
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF94A3B8),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Equalizer Waveform Bars
                      _AudioWaveVisualizer(
                        isActive: _isMicActive,
                        soundLevel: _soundLevel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141724),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _speechTranscript.isNotEmpty
                            ? const Color(0xFF10B981)
                            : const Color(0xFF2D3654),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _speechTranscript.isEmpty
                          ? 'Sebutkan kata dalam Bahasa Inggris...'
                          : '"$_speechTranscript"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _speechTranscript.isEmpty
                            ? const Color(0xFF64748B)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mode Ketik
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2235),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: const Border(top: BorderSide(color: Color(0xFF333D5E), width: 1.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: TextField(
        controller: _controllerKetik,
        focusNode: _focusNode,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            _periksaJawaban(value);
            _controllerKetik.clear();
            _focusNode.requestFocus();
          }
        },
        style: GoogleFonts.fredoka(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: 'Ketik jawaban lalu tekan Enter ↵',
          hintStyle: GoogleFonts.fredoka(
            fontSize: 15,
            color: const Color(0xFF64748B),
          ),
          filled: true,
          fillColor: const Color(0xFF141724),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF2D3654), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF2D3654), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_upward_rounded,
                    color: Colors.white, size: 20),
              ),
              onPressed: () {
                if (_controllerKetik.text.trim().isNotEmpty) {
                  _periksaJawaban(_controllerKetik.text);
                  _controllerKetik.clear();
                  _focusNode.requestFocus();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Visualizer gelombang equalizer audio real-time yang bereaksi dinamis terhadap desibel suara
class _AudioWaveVisualizer extends StatelessWidget {
  final bool isActive;
  final double soundLevel;

  const _AudioWaveVisualizer({
    required this.isActive,
    required this.soundLevel,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return const SizedBox(width: 40);
    }

    final level = soundLevel.clamp(0.0, 1.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBar(5 + level * 14),
        const SizedBox(width: 3),
        _buildBar(8 + level * 18),
        const SizedBox(width: 3),
        _buildBar(12 + level * 22),
        const SizedBox(width: 3),
        _buildBar(8 + level * 16),
        const SizedBox(width: 3),
        _buildBar(5 + level * 12),
      ],
    );
  }

  Widget _buildBar(double height) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      width: 4.0,
      height: height.clamp(4.0, 26.0),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x6610B981),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

/// Background artistik tetesan hujan bergaya tactile arcade
class _TactileArcadeBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rainPaint = Paint()
      ..color = const Color(0x12FFFFFF)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final random = Random(1234);
    for (var i = 0; i < 35; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final len = 20.0 + random.nextDouble() * 25.0;
      canvas.drawLine(Offset(x, y), Offset(x - 5, y + len), rainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
