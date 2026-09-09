import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  final AudioPlayer _player = AudioPlayer();

  bool _initialized = false;
  bool _continuous = false;
  bool _restartScheduled = false;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize();
    return _initialized;
  }

  Future<void> startContinuous({
    required void Function(String text) onFinalText,
    required void Function(bool listening) onListeningChanged,
  }) async {
    if (!await initialize()) {
      throw VoiceException('Speech recognition is not available on this device.');
    }
    _continuous = true;
    _restartScheduled = false;
    await _listen(
      onFinalText: onFinalText,
      onListeningChanged: onListeningChanged,
    );
  }

  Future<void> _listen({
    required void Function(String text) onFinalText,
    required void Function(bool listening) onListeningChanged,
  }) async {
    if (!_continuous) return;

    await _speech.listen(
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      cancelOnError: false,
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          onFinalText(result.recognizedWords.trim());
        }
      },
    );
    onListeningChanged(true);

    _speech.statusListener = (status) async {
      if (!_continuous) return;
      if (status == 'done' || status == 'notListening') {
        onListeningChanged(false);
        if (_restartScheduled) return;
        _restartScheduled = true;
        await Future<void>.delayed(const Duration(milliseconds: 300));
        _restartScheduled = false;
        if (_continuous) {
          await _listen(
            onFinalText: onFinalText,
            onListeningChanged: onListeningChanged,
          );
        }
      }
    };
  }

  Future<void> stop() async {
    _continuous = false;
    _restartScheduled = false;
    await _speech.stop();
  }

  Future<void> playTts(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/neuraaster_tts.mp3');
    await file.writeAsBytes(bytes, flush: true);
    await _player.stop();
    await _player.play(DeviceFileSource(file.path));
  }

  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}

class VoiceException implements Exception {
  final String message;
  VoiceException(this.message);

  @override
  String toString() => message;
}
