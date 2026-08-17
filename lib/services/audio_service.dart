import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Layanan efek suara terpadu dengan opsi Mute/Unmute.
class AudioService {
  static const _prefMuteKey = 'is_audio_muted';
  static bool _isMuted = false;
  static bool _initialized = false;

  final AudioPlayer _player = AudioPlayer();

  static bool get isMuted => _isMuted;

  /// Inisialisasi preferensi audio (apakah di-mute atau tidak) dari local storage.
  static Future<void> initPreferences() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMuted = prefs.getBool(_prefMuteKey) ?? false;
      _initialized = true;
    } catch (_) {
      _isMuted = false;
    }
  }

  /// Toggle mute status dan simpan preferensi.
  static Future<bool> toggleMute() async {
    _isMuted = !_isMuted;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefMuteKey, _isMuted);
    } catch (_) {}
    return _isMuted;
  }

  /// Mainkan efek suara benar (jawaban tepat).
  Future<void> benar() => _play('correct.wav');

  /// Mainkan efek suara salah (jawaban keliru).
  Future<void> salah() => _play('wrong.wav');

  /// Mainkan efek suara game over (nyawa habis).
  Future<void> gameOver() => _play('gameover.wav');

  /// Mainkan efek suara tombol / interaksi UI.
  Future<void> click() => _play('click.wav');

  Future<void> _play(String file) async {
    if (_isMuted) return;
    try {
      // Hentikan pemutaran sebelumnya jika masih berjalan untuk responsivitas cepat
      await _player.stop();
      await _player.play(AssetSource('audio/$file'), mode: PlayerMode.lowLatency);
    } catch (_) {
      // Jika audio error di platform tertentu, abaikan agar gameplay tidak crash
    }
  }

  void dispose() {
    _player.dispose();
  }
}
