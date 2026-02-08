import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:point_hue/features/camera/camera_controller.dart';
import 'package:point_hue/features/camera/camera_view.dart';
import 'package:point_hue/features/color/color_detector.dart';
import 'package:point_hue/core/router.dart';
import 'package:point_hue/features/color/color_repository.dart';
import 'package:point_hue/features/color/color_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorModel = ref.watch(colorDetectorProvider);
    final cameraNotifier = ref.read(cameraProvider.notifier);
    final libraryNotifier = ref.read(colorLibraryProvider.notifier);
    final historyNotifier = ref.read(colorHistoryProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          const CameraView(),

          // Header
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.collections_bookmark,
                    color: Colors.white,
                  ),
                  onPressed: () => const LibraryRoute().go(context),
                ),
                const Text(
                  'PointHue',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.flash_on, color: Colors.white),
                  onPressed: () => cameraNotifier.toggleFlash(),
                ),
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
                ref.read(colorDetectorProvider.notifier).toggleLock();
                if (!colorModel.isLocked) {
                  historyNotifier.addRecord(colorModel);
                }
              },
              onSave: () {
                libraryNotifier.saveColor(colorModel);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Color saved to library!')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ColorInfoCard extends StatelessWidget {
  final ColorModel colorModel;
  final VoidCallback onLock;
  final VoidCallback onSave;

  const ColorInfoCard({
    super.key,
    required this.colorModel,
    required this.onLock,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.9),
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
                  border: Border.all(color: Colors.white24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      colorModel.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      colorModel.hex,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  colorModel.isLocked ? Icons.lock : Icons.lock_open,
                  color: colorModel.isLocked ? Colors.orange : null,
                ),
                onPressed: onLock,
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
              _infoItem('R', colorModel.r.toString()),
              _infoItem('G', colorModel.g.toString()),
              _infoItem('B', colorModel.b.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
