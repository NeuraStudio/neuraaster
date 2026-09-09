import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';

class StorageService {
  static const _messagesKey = 'neuraaster.messages.v1';

  Future<List<ChatMessage>> loadMessages() async {
    final prefs = await SharedPreferencesAsync();
    final raw = await prefs.getString(_messagesKey);
    if (raw == null || raw.isEmpty) return <ChatMessage>[];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(ChatMessage.fromJson)
          .toList();
    } catch (_) {
      return <ChatMessage>[];
    }
  }

  Future<void> saveMessages(List<ChatMessage> messages) async {
    final prefs = await SharedPreferencesAsync();
    final raw = jsonEncode(messages.map((message) => message.toJson()).toList());
    await prefs.setString(_messagesKey, raw);
  }

  Future<void> clearMessages() async {
    final prefs = await SharedPreferencesAsync();
    await prefs.remove(_messagesKey);
  }
}
