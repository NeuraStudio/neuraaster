import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../providers/app_providers.dart';
import '../services/file_service.dart';
import '../theme/app_theme.dart';
import 'markdown_message.dart';
import 'media_widgets.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final FileService fileService;

  const ChatBubble({
    super.key,
    required this.message,
    required this.fileService,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          margin: const EdgeInsets.only(bottom: 18, left: 54),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface2,
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomRight: const Radius.circular(6),
            ),
          ),
          child: Text(message.text, style: const TextStyle(fontSize: 15.5, height: 1.45)),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 22, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 17,
            backgroundImage: AssetImage('assets/neuraaster_logo.png'),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownMessage(data: message.text, fileService: fileService),
                if (message.mediaUrl != null) ...[
                  const SizedBox(height: 10),
                  switch (message.type) {
                    MediaType.image => GeneratedImage(url: message.mediaUrl!, fileService: fileService),
                    MediaType.video => GeneratedVideo(url: message.mediaUrl!, fileService: fileService),
                    MediaType.audio => AudioReply(url: message.mediaUrl!),
                    MediaType.text => const SizedBox.shrink(),
                  },
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
