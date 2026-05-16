import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/features/color/color_repository.dart';
import 'package:point_hue/core/router.dart';
import 'package:point_hue/core/theme.dart';
import 'package:point_hue/shared/extensions/time_extensions.dart';

/// Screen displaying saved colors and color history
/// in two tabs.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(colorLibraryProvider);
    final historyAsync = ref.watch(colorHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Color Library')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Saved'),
                Tab(text: 'History'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ColorList(
                    asyncData: libraryAsync,
                    allowDelete: true,
                    showTimestamp: false,
                    onDelete: (hex) {
                      ref.read(colorLibraryProvider.notifier).removeColor(hex);
                    },
                    onRefresh: () async {
                      ref.invalidate(colorLibraryProvider);
                    },
                  ),
                  _ColorList(
                    asyncData: historyAsync,
                    allowDelete: false,
                    showTimestamp: true,
                    onRefresh: () async {
                      ref.invalidate(colorHistoryProvider);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorList extends StatelessWidget {
  final AsyncValue<List<ColorModel>> asyncData;
  final bool allowDelete;
  final bool showTimestamp;
  final ValueChanged<String>? onDelete;
  final Future<void> Function()? onRefresh;

  const _ColorList({
    required this.asyncData,
    this.allowDelete = false,
    this.showTimestamp = false,
    this.onDelete,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return asyncData.when(
      data: (colors) {
        if (colors.isEmpty) {
          return _EmptyState(theme: theme);
        }

        final list = ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: colors.length,
          itemBuilder: (context, index) {
            final color = colors[index];
            return _ColorCard(
              color: color,
              theme: theme,
              showTimestamp: showTimestamp,
              allowDelete: allowDelete,
              onDelete: onDelete,
            );
          },
        );

        if (onRefresh != null) {
          return RefreshIndicator(onRefresh: onRefresh!, child: list);
        }
        return list;
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text('Failed to load colors', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '$e',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual color card in the list.
class _ColorCard extends StatelessWidget {
  final ColorModel color;
  final ThemeData theme;
  final bool showTimestamp;
  final bool allowDelete;
  final ValueChanged<String>? onDelete;

  const _ColorCard({
    required this.color,
    required this.theme,
    required this.showTimestamp,
    required this.allowDelete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = showTimestamp && color.timestamp != null
        ? '${color.hex}  ·  '
              '${formatRelativeTime(color.timestamp!)}'
        : color.hex;

    final card = Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Hero(
          tag: 'color-${color.hex}',
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.toColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: color.toColor().withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
        title: Text(
          color.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.outline),
        onTap: () {
          final hexValue = color.hex.replaceAll('#', '');
          ColorDetailRoute(hex: hexValue).go(context);
        },
      ),
    );

    if (allowDelete) {
      return Dismissible(
        key: ValueKey(color.hex),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.delete_outline, color: theme.colorScheme.onError),
        ),
        onDismissed: (_) {
          onDelete?.call(color.hex);
          ScaffoldMessenger.of(context).showSnackBar(
            PointHueSnackBar.create(
              context: context,
              message: '${color.name} removed',
              icon: Icons.delete_outline,
            ),
          );
        },
        child: card,
      );
    }

    return card;
  }
}

/// Empty state with a visual illustration and
/// helpful guidance.
class _EmptyState extends StatelessWidget {
  final ThemeData theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.secondary.withValues(alpha: 0.15),
                  ],
                ),
              ),
              child: Icon(
                Icons.palette_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No colors yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Point at something colorful, lock '
              'the color, and tap save!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start Scanning'),
            ),
          ],
        ),
      ),
    );
  }
}
