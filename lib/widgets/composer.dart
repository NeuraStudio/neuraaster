import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../screens/live_screen.dart';
import '../theme/app_theme.dart';

class Composer extends ConsumerStatefulWidget {
  const Composer({super.key});

  @override
  ConsumerState<Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<Composer> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    await ref.read(chatControllerProvider.notifier).send(text);
    if (mounted) _focus.requestFocus();
  }

  Future<void> _openLive() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LiveScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(chatControllerProvider).loading;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _showAttach(context),
                icon: const Icon(Icons.add_rounded, size: 28),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    fillColor: Colors.transparent,
                    hintText: 'Ask NeuraAster...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              IconButton(
                tooltip: 'Live voice and camera',
                onPressed: loading ? null : _openLive,
                icon: const Icon(Icons.graphic_eq_rounded),
              ),
              const SizedBox(width: 3),
              Material(
                color: AppTheme.blue,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: loading ? null : _send,
                  color: Colors.white,
                  icon: loading
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.arrow_upward_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttach(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 26),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Live camera / vision'),
              onTap: () {
                Navigator.pop(context);
                _openLive();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Image'),
              subtitle: const Text('Use Live camera to capture and analyze a frame'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
