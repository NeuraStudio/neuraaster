import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../core/constants.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/file_service.dart';
import '../services/storage_service.dart';
import '../services/voice_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final fileServiceProvider = Provider<FileService>((ref) => FileService());
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
final voiceServiceProvider = Provider<VoiceService>((ref) {
  final service = VoiceService();
  ref.onDispose(service.dispose);
  return service;
});

final selectedModelProvider = StateProvider<String>((ref) => AppConstants.defaultModel);
final extendedThinkingProvider = StateProvider<bool>((ref) => true);
final sidebarOpenProvider = StateProvider<bool>((ref) => false);
final liveModeProvider = StateProvider<bool>((ref) => false);
final listeningProvider = StateProvider<bool>((ref) => false);

class ChatState {
  final List<ChatMessage> messages;
  final bool loading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.loading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatController extends Notifier<ChatState> {
  late final ApiService _api;
  late final StorageService _storage;
  late final VoiceService _voice;

  @override
  ChatState build() {
    _api = ref.read(apiServiceProvider);
    _storage = ref.read(storageServiceProvider);
    _voice = ref.read(voiceServiceProvider);
    unawaited(_restore());
    return const ChatState();
  }

  Future<void> _restore() async {
    final messages = await _storage.loadMessages();
    state = state.copyWith(messages: messages, clearError: true);
  }

  Future<void> send(String prompt, {String? imageBase64}) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty && imageBase64 == null) return;

    final model = ref.read(selectedModelProvider);
    final userMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: MessageRole.user,
      text: trimmed.isEmpty ? 'Analyze this image.' : trimmed,
      createdAt: DateTime.now(),
      model: model,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      loading: true,
      clearError: true,
    );
    await _storage.saveMessages(state.messages);

    try {
      final response = await _api.chat(
        prompt: userMessage.text,
        model: model,
        imageBase64: imageBase64,
      );

      final assistant = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        text: response.reply,
        type: response.type,
        mediaUrl: response.mediaUrl == null ? null : _api.resolveMediaUrl(response.mediaUrl!),
        createdAt: DateTime.now(),
        model: model,
      );

      state = state.copyWith(
        messages: [...state.messages, assistant],
        loading: false,
      );
      await _storage.saveMessages(state.messages);
    } catch (error) {
      state = state.copyWith(
        loading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> clear() async {
    state = const ChatState();
    await _storage.clearMessages();
    try {
      await _api.clearRemoteHistory();
    } catch (_) {
      // Local history is still cleared even when the remote endpoint is unavailable.
    }
  }

  Future<void> startLive({
    required void Function(String text) onText,
  }) async {
    ref.read(liveModeProvider.notifier).state = true;
    await _voice.startContinuous(
      onFinalText: (text) async {
        onText(text);
        await send(text);
        final last = state.messages.where((m) => m.role == MessageRole.assistant).lastOrNull;
        if (last != null && last.text.isNotEmpty) {
          try {
            final bytes = await _api.synthesize(last.text);
            await _voice.playTts(bytes);
          } catch (_) {
            // TTS failure should not terminate the live session.
          }
        }
      },
      onListeningChanged: (value) {
        ref.read(listeningProvider.notifier).state = value;
      },
    );
  }

  Future<void> stopLive() async {
    ref.read(liveModeProvider.notifier).state = false;
    ref.read(listeningProvider.notifier).state = false;
    await _voice.stop();
  }
}

final chatControllerProvider =
    NotifierProvider<ChatController, ChatState>(ChatController.new);

extension _LastOrNull<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
