import 'package:speech_to_text/speech_to_text.dart';

/// Layanan speech recognition untuk mode "Ngomong".
/// Player langsung ngomong, hasil langsung tertangkap otomatis.
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;
  void Function(String)? _errorHandler;

  bool get available => _available;

  /// Inisialisasi mic. Panggil sekali sebelum mulai.
  Future<bool> init() async {
    _available = await _speech.initialize(
      onError: (error) => _errorHandler?.call(error.errorMsg),
    );
    return _available;
  }

  /// Set handler error global (mis. retry saat error).
  void setErrorHandler(void Function(String error) handler) {
    _errorHandler = handler;
  }

  /// Mulai mendengarkan. [onResult] dipanggil setiap kali ada kata tertangkap.
  Future<void> listen({
    required void Function(String text) onResult,
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
    );
  }

  /// Berhenti mendengarkan.
  Future<void> stop() async {
    await _speech.stop();
  }
}
