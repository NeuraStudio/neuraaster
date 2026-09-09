import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/composer.dart';
import '../widgets/model_selector.dart';
import '../widgets/sidebar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chat = ref.watch(chatControllerProvider);
    final fileService = ref.watch(fileServiceProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const AppSidebar(),
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onMenu: () => Scaffold.of(context).openDrawer(),
            ),
            Expanded(
              child: chat.messages.isEmpty
                  ? const _Hero()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                      reverse: false,
                      itemCount: chat.messages.length + (chat.loading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chat.messages.length) {
                          return const Padding(
                            padding: EdgeInsets.only(left: 50, top: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }
                        return ChatBubble(
                          message: chat.messages[index],
                          fileService: fileService,
                        );
                      },
                    ),
            ),
            if (chat.error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Text(
                  chat.error!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
                ),
              ),
            const Composer(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onMenu;

  const _Header({required this.onMenu});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          IconButton(
            onPressed: onMenu,
            icon: const Icon(Icons.menu_rounded, size: 27),
          ),
          const Expanded(
            child: Center(child: ModelSelector()),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => showModalBottomSheet<void>(
                context: context,
                backgroundColor: AppTheme.surface,
                showDragHandle: true,
                builder: (_) => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'NeuraAster\n\nYour private AI workspace connected to your own API.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/neuraaster_logo.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF15CFFF),
                    Color(0xFF4B61FF),
                    Color(0xFFB62DFF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF4D5EFF),
                    blurRadius: 38,
                    spreadRadius: -5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/neuraaster_logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              "Hi Javed, let's get into it",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                height: 1.08,
                fontWeight: FontWeight.w400,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ask anything, build anything.',
              style: TextStyle(color: AppTheme.muted, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
