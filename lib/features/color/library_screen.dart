import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/features/color/color_repository.dart';
import 'package:point_hue/core/router.dart';
import 'package:point_hue/core/theme.dart';
import 'package:point_hue/shared/extensions/time_extensions.dart';

/// Screen displaying saved colors and color history
/// in two tabs with search and grid/list view toggles.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _isGridView = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(colorLibraryProvider);
    final historyAsync = ref.watch(colorHistoryProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search colors by name or hex...',
                    border: InputBorder.none,
                    filled: false,
                  ),
                  onChanged: (_) => setState(() {}),
                )
              : const Text('Color Library'),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              tooltip: _isSearching ? 'Close search' : 'Search colors',
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) _searchController.clear();
                });
              },
            ),
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              tooltip: _isGridView ? 'List view' : 'Grid view',
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'clear_history') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear History?'),
                      content: const Text(
                        'This will delete all scanned colors from your history.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    ref.read(colorHistoryProvider.notifier).clearHistory();
                    ScaffoldMessenger.of(context).showSnackBar(
                      PointHueSnackBar.create(
                        context: context,
                        message: 'History cleared',
                        icon: Icons.delete_sweep,
                      ),
                    );
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_history',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, size: 20),
                      SizedBox(width: 12),
                      Text('Clear history'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Saved'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ColorList(
              asyncData: libraryAsync,
              allowDelete: true,
              showTimestamp: false,
              isGridView: _isGridView,
              searchQuery: _searchController.text,
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
              isGridView: _isGridView,
              searchQuery: _searchController.text,
              onRefresh: () async {
                ref.invalidate(colorHistoryProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorList extends ConsumerWidget {
  final AsyncValue<List<ColorModel>> asyncData;
  final bool allowDelete;
  final bool showTimestamp;
  final bool isGridView;
  final String searchQuery;
  final ValueChanged<String>? onDelete;
  final Future<void> Function()? onRefresh;

  const _ColorList({
    required this.asyncData,
    this.allowDelete = false,
    this.showTimestamp = false,
    this.isGridView = false,
    this.searchQuery = '',
    this.onDelete,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final savedColors = ref.watch(colorLibraryProvider).value ?? [];

    return asyncData.when(
      data: (colors) {
        if (colors.isEmpty) {
          return _EmptyState(theme: theme);
        }

        final filtered = searchQuery.trim().isEmpty
            ? colors
            : colors.where((c) {
                final query = searchQuery.trim().toLowerCase();
                return c.name.toLowerCase().contains(query) ||
                    c.hex.toLowerCase().contains(query);
              }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 12),
                Text(
                  'No colors match "$searchQuery"',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        Widget content;
        if (isGridView) {
          content = GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final color = filtered[index];
              return _ColorGridCard(
                color: color,
                theme: theme,
                onTap: () {
                  final hexValue = color.hex.replaceAll('#', '');
                  ColorDetailRoute(hex: hexValue).go(context);
                },
              );
            },
          );
        } else {
          content = ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final color = filtered[index];
              final isSaved = savedColors.any((c) => c.hex == color.hex);

              return _ColorCard(
                color: color,
                theme: theme,
                showTimestamp: showTimestamp,
                allowDelete: allowDelete,
                isSaved: isSaved,
                onSaveToggle: () {
                  if (isSaved) {
                    ref
                        .read(colorLibraryProvider.notifier)
                        .removeColor(color.hex);
                    ScaffoldMessenger.of(context).showSnackBar(
                      PointHueSnackBar.create(
                        context: context,
                        message: '${color.name} removed from library',
                      ),
                    );
                  } else {
                    ref.read(colorLibraryProvider.notifier).saveColor(color);
                    ScaffoldMessenger.of(context).showSnackBar(
                      PointHueSnackBar.create(
                        context: context,
                        message: '${color.name} saved to library',
                        icon: Icons.check_circle,
                      ),
                    );
                  }
                },
                onDelete: onDelete,
              );
            },
          );
        }

        if (onRefresh != null) {
          return RefreshIndicator(onRefresh: onRefresh!, child: content);
        }
        return content;
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

/// Palette card for the grid view mode.
class _ColorGridCard extends StatelessWidget {
  final ColorModel color;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ColorGridCard({
    required this.color,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentColor = color.toColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: currentColor.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Hero(
                tag: 'color-${color.hex}',
                child: Container(
                  color: currentColor,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          color.hex,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: theme.colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      color.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      color.rgbString,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
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
  final bool isSaved;
  final VoidCallback? onSaveToggle;
  final ValueChanged<String>? onDelete;

  const _ColorCard({
    required this.color,
    required this.theme,
    required this.showTimestamp,
    required this.allowDelete,
    this.isSaved = false,
    this.onSaveToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = showTimestamp && color.timestamp != null
        ? '${color.hex}  ·  ${formatRelativeTime(color.timestamp!)}'
        : color.hex;

    final card = Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  color: color.toColor().withValues(alpha: 0.35),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
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
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: showTimestamp ? null : 'monospace',
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showTimestamp && onSaveToggle != null)
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  size: 20,
                ),
                tooltip: isSaved ? 'In library' : 'Save to library',
                onPressed: onSaveToggle,
              ),
            Icon(Icons.chevron_right, color: theme.colorScheme.outline),
          ],
        ),
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
            borderRadius: BorderRadius.circular(16),
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
