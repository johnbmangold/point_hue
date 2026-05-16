import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:point_hue/features/camera/camera_view.dart';
import 'package:point_hue/features/color/color_detector.dart';
import 'package:point_hue/core/router.dart';
import 'package:point_hue/features/color/color_repository.dart';
import 'package:point_hue/features/color/color_model.dart';

/// Main screen with live camera preview and color info
/// overlay.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorModel = ref.watch(colorDetectorProvider);

    // Keep providers alive while on this screen.
    ref.watch(colorLibraryProvider);
    ref.watch(colorHistoryProvider);

    final libraryNotifier = ref.read(colorLibraryProvider.notifier);
    final historyNotifier = ref.read(colorHistoryProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          const CameraView(),

          // Header — uses SafeArea-aware positioning.
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.collections_bookmark,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 4)],
                  ),
                  onPressed: () => const LibraryRoute().go(context),
                ),
                Text(
                  'PointHue',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [const Shadow(blurRadius: 4)],
                  ),
                ),
                // Balance the row layout.
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Bottom Info Card
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ColorInfoCard(
              colorModel: colorModel,
              onLock: () {
                HapticFeedback.mediumImpact();
                final wasLocked = colorModel.isLocked;
                ref.read(colorDetectorProvider.notifier).toggleLock();
                // Record to history when locking (was
                // unlocked → now locked).
                if (!wasLocked) {
                  historyNotifier.addRecord(colorModel);
                }
              },
              onSave: () {
                libraryNotifier.saveColor(colorModel);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                        const SizedBox(width: 8),
                        const Text('Color saved to library!'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              onCopyHex: () {
                Clipboard.setData(ClipboardData(text: colorModel.hex));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied ${colorModel.hex}'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Card that displays the currently detected color
/// with lock, save, and copy controls.
class ColorInfoCard extends StatelessWidget {
  final ColorModel colorModel;
  final VoidCallback onLock;
  final VoidCallback onSave;
  final VoidCallback onCopyHex;

  const ColorInfoCard({
    super.key,
    required this.colorModel,
    required this.onLock,
    required this.onSave,
    required this.onCopyHex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorModel.toColor(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      colorModel.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: onCopyHex,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            colorModel.hex,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.copy,
                            size: 14,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: IconButton(
                  key: ValueKey(colorModel.isLocked),
                  icon: Icon(
                    colorModel.isLocked ? Icons.lock : Icons.lock_open,
                    color: colorModel.isLocked
                        ? theme.colorScheme.primary
                        : null,
                  ),
                  onPressed: onLock,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.save_outlined),
                onPressed: onSave,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _RgbInfoItem(label: 'R', value: colorModel.r.toString()),
              _RgbInfoItem(label: 'G', value: colorModel.g.toString()),
              _RgbInfoItem(label: 'B', value: colorModel.b.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

/// Displays a single R/G/B channel label and value.
class _RgbInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _RgbInfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(value, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}
