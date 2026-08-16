import 'package:audioplayers/audioplayers.dart';

/// Layanan efek suara sederhana (benar/salah/game over).
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  /// Mainkan efek benar.
  Future<void> benar() => _play('correct.wav');

  /// Mainkan efek salah.
  Future<void> salah() => _play('wrong.wav');

  /// Mainkan efek game over.
  Future<void> gameOver() => _play('gameover.wav');

  Future<void> _play(String file) async {
    try {
      await _player.play(AssetSource('audio/$file'));
    } catch (_) {
      // audio tidak ada / gagal — abaikan (tidak merusak game)
    }
  }

  void dispose() {
    _player.dispose();
  }
}
