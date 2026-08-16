import 'package:speech_to_text/speech_to_text.dart';

/// Layanan speech recognition untuk mode "Ngomong".
/// Player langsung ngomong, hasil langsung tertangkap otomatis.
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;

  bool get available => _available;

  /// Inisialisasi mic. Panggil sekali sebelum mulai.
  Future<bool> init() async {
    _available = await _speech.initialize();
    return _available;
  }

  /// Mulai mendengarkan. [onResult] dipanggil setiap kali ada kata tertangkap.
  Future<void> listen({
    required void Function(String text) onResult,
    void Function(String error)? onError,
  }) async {
    if (!_available) return;
    await _speech.listen(
      localeId: 'en_US',
      listenMode: ListenMode.confirmation,
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords.trim());
        }
      },
      onError: (error) => onError?.call(error.errorMsg),
    );
  }

  /// Berhenti mendengarkan.
  Future<void> stop() async {
    await _speech.stop();
  }
}
