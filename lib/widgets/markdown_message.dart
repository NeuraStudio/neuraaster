import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../services/file_service.dart';
import '../theme/app_theme.dart';

class MarkdownMessage extends StatelessWidget {
  final String data;
  final FileService fileService;

  const MarkdownMessage({
    super.key,
    required this.data,
    required this.fileService,
  });

  @override
  Widget build(BuildContext context) {
    final segments = _parseFences(data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final segment in segments)
          if (segment.isCode)
            _CodeBlock(
              code: segment.content,
              language: segment.language,
              fileService: fileService,
            )
          else if (segment.content.trim().isNotEmpty)
            MarkdownBody(
              data: segment.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 15.5, height: 1.55, color: AppTheme.text),
                h1: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                h3: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                code: const TextStyle(
                  fontFamily: 'monospace',
                  color: Color(0xFFE4E7EF),
                  backgroundColor: AppTheme.surface2,
                ),
                blockquote: const TextStyle(color: AppTheme.muted),
              ),
            ),
      ],
    );
  }

  List<_Segment> _parseFences(String input) {
    final regex = RegExp(r'```([^\n]*)\n([\s\S]*?)```');
    final segments = <_Segment>[];
    var cursor = 0;

    for (final match in regex.allMatches(input)) {
      if (match.start > cursor) {
        segments.add(_Segment.text(input.substring(cursor, match.start)));
      }
      segments.add(
        _Segment.code(
          language: (match.group(1) ?? '').trim(),
          content: match.group(2) ?? '',
        ),
      );
      cursor = match.end;
    }

    if (cursor < input.length) {
      segments.add(_Segment.text(input.substring(cursor)));
    }
    return segments.isEmpty ? [_Segment.text(input)] : segments;
  }
}

class _Segment {
  final bool isCode;
  final String language;
  final String content;

  const _Segment._(this.isCode, this.language, this.content);

  factory _Segment.text(String content) => _Segment._(false, '', content);

  factory _Segment.code({required String language, required String content}) =>
      _Segment._(true, language, content);
}

class _CodeBlock extends StatefulWidget {
  final String code;
  final String language;
  final FileService fileService;

  const _CodeBlock({
    required this.code,
    required this.language,
    required this.fileService,
  });

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock> {
  bool _saving = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code copied')),
      );
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final path = await widget.fileService.saveCode(
        code: widget.code,
        language: widget.language,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved: $path')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0C0F),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF2B2E35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            color: AppTheme.surface2,
            child: Row(
              children: [
                Text(
                  widget.language.isEmpty ? 'code' : widget.language,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Copy',
                  onPressed: _copy,
                  icon: const Icon(Icons.copy_rounded, size: 17),
                ),
                IconButton(
                  tooltip: 'Save file',
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_alt_rounded, size: 18),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14),
            child: SelectableText(
              widget.code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13.5,
                height: 1.45,
                color: Color(0xFFE6E8ED),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
