import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chat = ref.watch(chatControllerProvider);

    return Drawer(
      backgroundColor: AppTheme.background,
      width: MediaQuery.sizeOf(context).width * .84,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 12, 18),
              child: Row(
                children: [
                  const Text('NeuraAster', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            _SideAction(
              icon: Icons.edit_outlined,
              label: 'New chat',
              onTap: () async {
                await ref.read(chatControllerProvider.notifier).clear();
                if (context.mounted) Navigator.pop(context);
              },
            ),
            _SideAction(
              icon: Icons.search_rounded,
              label: 'Search chats',
              onTap: () => _showComingSoon(context, 'Chat search'),
            ),
            const Divider(height: 28, color: Color(0xFF202126)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Recent', style: TextStyle(color: AppTheme.muted, fontSize: 14)),
              ),
            ),
            Expanded(
              child: chat.messages.isEmpty
                  ? const Center(
                      child: Text('No recent chats', style: TextStyle(color: AppTheme.muted)),
                    )
                  : ListView.builder(
                      itemCount: _recentPrompts(chat.messages).length,
                      itemBuilder: (context, index) {
                        final title = _recentPrompts(chat.messages)[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.chat_bubble_outline_rounded, size: 19),
                          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          onTap: () => Navigator.pop(context),
                        );
                      },
                    ),
            ),
            const Divider(color: Color(0xFF202126)),
            _SideAction(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => _showSettings(context),
            ),
            _SideAction(
              icon: Icons.account_circle_outlined,
              label: 'Account',
              onTap: () => _showAccount(context),
            ),
            const Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundImage: AssetImage('assets/neuraaster_logo.png'),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NeuraAster User', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('NeuraAster', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _recentPrompts(List messages) {
    final values = messages
        .where((m) => m.role.name == 'user')
        .map<String>((m) => m.text.toString())
        .toList()
        .reversed
        .take(12)
        .toList();
    return values;
  }

  void _showComingSoon(BuildContext context, String title) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
        child: Text('$title is ready for the next backend/search integration.',
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      showDragHandle: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(24, 10, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.dark_mode_outlined),
              title: Text('AMOLED dark mode'),
              subtitle: Text('Optimized for OLED displays'),
            ),
            ListTile(
              leading: Icon(Icons.lock_outline_rounded),
              title: Text('Privacy'),
              subtitle: Text('Chats are stored locally on this device'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccount(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      showDragHandle: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(24, 10, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 36, backgroundImage: AssetImage('assets/neuraaster_logo.png')),
            SizedBox(height: 12),
            Text('NeuraAster User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('NeuraAster account', style: TextStyle(color: AppTheme.muted)),
          ],
        ),
      ),
    );
  }
}

class _SideAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SideAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
