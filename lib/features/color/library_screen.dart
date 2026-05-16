import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/features/color/color_repository.dart';
import 'package:point_hue/core/router.dart';

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
                    onDelete: (hex) {
                      ref.read(colorLibraryProvider.notifier).removeColor(hex);
                    },
                  ),
                  _ColorList(asyncData: historyAsync, allowDelete: false),
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
  final ValueChanged<String>? onDelete;

  const _ColorList({
    required this.asyncData,
    this.allowDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return asyncData.when(
      data: (colors) {
        if (colors.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.palette_outlined,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No colors yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Point at something colorful and '
                  'tap save!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: colors.length,
          itemBuilder: (context, index) {
            final color = colors[index];
            final tile = ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.toColor(),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                ),
              ),
              title: Text(color.name),
              subtitle: Text(color.hex),
              trailing: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
              onTap: () {
                final hexValue = color.hex.replaceAll('#', '');
                ColorDetailRoute(hex: hexValue).go(context);
              },
            );

            if (allowDelete) {
              return Dismissible(
                key: ValueKey(color.hex),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  color: theme.colorScheme.error,
                  child: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.onError,
                  ),
                ),
                onDismissed: (_) {
                  onDelete?.call(color.hex);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${color.name} removed'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: tile,
              );
            }

            return tile;
          },
        );
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
