import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:point_hue/features/color/color_repository.dart';
import 'package:point_hue/core/router.dart';

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
                  _ColorList(asyncData: libraryAsync),
                  _ColorList(asyncData: historyAsync),
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
  final AsyncValue asyncData;

  const _ColorList({required this.asyncData});

  @override
  Widget build(BuildContext context) {
    return asyncData.when(
      data: (colors) => ListView.builder(
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.toColor(),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            title: Text(color.name),
            subtitle: Text(color.hex),
            onTap: () =>
                ColorDetailRoute(hex: color.hex.substring(1)).go(context),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}
