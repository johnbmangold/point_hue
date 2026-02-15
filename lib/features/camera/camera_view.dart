import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:point_hue/features/camera/camera_controller.dart';
import 'package:point_hue/features/color/color_detector.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class CameraView extends ConsumerStatefulWidget {
  const CameraView({super.key});

  @override
  ConsumerState<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends ConsumerState<CameraView> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(cameraProvider, (previous, next) {
      next.whenData((state) {
        if (state != null &&
            state.controller.value.isInitialized &&
            (previous?.value?.controller != state.controller)) {
          ref
              .read(colorDetectorProvider.notifier)
              .startDetection(state.controller);
        }
      });
    });

    final cameraState = ref.watch(cameraProvider);

    return cameraState.when(
      data: (state) {
        if (state == null) {
          return const Center(child: Text('No camera available'));
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(state.controller),
            const ReticleOverlay(),
            Positioned(
              top: 40,
              right: 20,
              child: Column(
                children: [
                  const ZoomPreview(),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: 'flip_camera',
                    mini: true,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    onPressed: () {
                      ref.read(cameraProvider.notifier).switchCamera();
                    },
                    child: const Icon(
                      Icons.flip_camera_ios,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: 'toggle_flash',
                    mini: true,
                    backgroundColor: state.isFlashOn
                        ? Colors.yellow.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.3),
                    onPressed: () {
                      ref.read(cameraProvider.notifier).toggleFlash();
                    },
                    child: Icon(
                      state.isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class ZoomPreview extends ConsumerWidget {
  const ZoomPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorModel = ref.watch(colorDetectorProvider);

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: colorModel.toColor(),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10),
        ],
      ),
      child: const Center(
        child: Icon(Icons.add, color: Colors.white, size: 20),
      ),
    );
  }
}

class ReticleOverlay extends StatelessWidget {
  const ReticleOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
