enum MessageRole { user, assistant, system }

enum MediaType { text, image, audio, video }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String text;
  final MediaType type;
  final String? mediaUrl;
  final DateTime createdAt;
  final String? model;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.type = MediaType.text,
    this.mediaUrl,
    required this.createdAt,
    this.model,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'text': text,
        'type': type.name,
        'media_url': mediaUrl,
        'created_at': createdAt.toIso8601String(),
        'model': model,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final role = MessageRole.values.firstWhere(
      (value) => value.name == json['role'],
      orElse: () => MessageRole.assistant,
    );
    final type = MediaType.values.firstWhere(
      (value) => value.name == json['type'],
      orElse: () => MediaType.text,
    );
    return ChatMessage(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      role: role,
      text: json['text'] as String? ?? '',
      type: type,
      mediaUrl: json['media_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      model: json['model'] as String?,
    );
  }
}

class ChatResponse {
  final MediaType type;
  final String reply;
  final String? mediaUrl;

  const ChatResponse({
    required this.type,
    required this.reply,
    this.mediaUrl,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] as String? ?? 'text').toLowerCase();
    final type = MediaType.values.firstWhere(
      (value) => value.name == rawType,
      orElse: () => MediaType.text,
    );
    return ChatResponse(
      type: type,
      reply: json['reply'] as String? ?? '',
      mediaUrl: json['media_url'] as String?,
    );
  }
}
