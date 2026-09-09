import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

class ModelSelector extends ConsumerWidget {
  const ModelSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(selectedModelProvider);
    final extended = ref.watch(extendedThinkingProvider);

    return PopupMenuButton<String>(
      color: AppTheme.surface2,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      onSelected: (value) {
        if (value == '__extended__') {
          ref.read(extendedThinkingProvider.notifier).state = !extended;
          return;
        }
        ref.read(selectedModelProvider.notifier).state = value;
      },
      itemBuilder: (context) => [
        for (final option in AppConstants.supportedModels)
          PopupMenuItem<String>(
            value: option.name,
            child: _ModelRow(
              title: option.name,
              subtitle: option.subtitle,
              selected: option.name == model,
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: '__extended__',
          child: _ModelRow(
            title: 'Extended thinking',
            subtitle: 'Complex problem solving',
            selected: extended,
            trailing: Switch.adaptive(
              value: extended,
              onChanged: (_) {
                Navigator.of(context).pop('__extended__');
              },
            ),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(model, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(width: 5),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ModelRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final Widget? trailing;

  const _ModelRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
            ],
          ),
        ),
        trailing ??
            (selected
                ? const Icon(Icons.check_rounded, size: 20, color: AppTheme.text)
                : const SizedBox(width: 20)),
      ],
    );
  }
}
