// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Layanan speech recognition untuk mode "Ngomong".
/// Mendukung continuous auto-restart dan live sound level visualizer callback.
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;
  bool _shouldKeepListening = false;
  void Function(String)? _errorHandler;
  void Function(String text)? _resultHandler;
  void Function(double level)? _soundLevelHandler;
  void Function(bool isListening)? _statusHandler;

  bool get available => _available;
  bool get isListening => _speech.isListening;

  /// Inisialisasi mikrofon & engine speech recognition.
  Future<bool> init() async {
    try {
      _available = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech recognition error: ${error.errorMsg}');
          _errorHandler?.call(error.errorMsg);
          if (_shouldKeepListening) {
            _restartListeningDelayed();
          }
        },
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
          _statusHandler?.call(status == 'listening');
          if ((status == 'done' || status == 'notListening') &&
              _shouldKeepListening) {
            _restartListeningDelayed();
          }
        },
      );
    } catch (e) {
      debugPrint('Speech initialization failed: $e');
      _available = false;
    }
    return _available;
  }

  /// Set handler error kustom.
  void setErrorHandler(void Function(String error) handler) {
    _errorHandler = handler;
  }

  /// Set handler status aktif/tidaknya mic.
  void setStatusHandler(void Function(bool isListening) handler) {
    _statusHandler = handler;
  }

  /// Mulai mendengarkan ucapan pemain secara berkelanjutan.
  Future<void> listen({
    required void Function(String text) onResult,
    void Function(double level)? onSoundLevelChange,
  }) async {
    _resultHandler = onResult;
    _soundLevelHandler = onSoundLevelChange;
    _shouldKeepListening = true;
    if (!_available) {
      final initialized = await init();
      if (!initialized) return;
    }
    await _startListening();
  }

  Future<void> _startListening() async {
    if (!_available || !_shouldKeepListening) return;
    if (_speech.isListening) return;

    try {
      await _speech.listen(
        localeId: 'en_US',
        listenMode: ListenMode.dictation,
        partialResults: true,
        pauseFor: const Duration(seconds: 3),
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            _resultHandler?.call(result.recognizedWords.trim());
          }
        },
        onSoundLevelChange: (level) {
          _soundLevelHandler?.call(level);
        },
      );
    } catch (e) {
      debugPrint('Error starting speech listen: $e');
    }
  }

  void _restartListeningDelayed() {
    if (!_shouldKeepListening) return;
    Timer(const Duration(milliseconds: 250), () {
      if (_shouldKeepListening && !_speech.isListening) {
        _startListening();
      }
    });
  }

  /// Hentikan mode pendengaran secara permanen untuk sesi ini.
  Future<void> stop() async {
    _shouldKeepListening = false;
    try {
      await _speech.stop();
    } catch (_) {}
  }
}
