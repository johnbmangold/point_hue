import 'dart:developer' as developer;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:point_hue/features/camera/camera_controller.dart';
import 'package:point_hue/features/color/color_detector.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Full-screen camera preview with overlay controls.
class CameraView extends ConsumerStatefulWidget {
  const CameraView({super.key});

  @override
  ConsumerState<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends ConsumerState<CameraView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraState = ref.read(cameraProvider).value;
    if (cameraState == null) return;

    final controller = cameraState.controller;

    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _stopStreamSafely(controller);
      case AppLifecycleState.resumed:
        if (controller.value.isInitialized) {
          ref.read(colorDetectorProvider.notifier).startDetection(controller);
        }
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _stopStreamSafely(CameraController controller) async {
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (e, s) {
      developer.log(
        'Error stopping stream on lifecycle',
        name: 'point_hue.camera_view',
        error: e,
        stackTrace: s,
      );
    }
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
    final theme = Theme.of(context);

    return cameraState.when(
      data: (state) {
        if (state == null) {
          return Center(
            child: Text(
              'No camera available',
              style: theme.textTheme.bodyLarge,
            ),
          );
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(state.controller),
            const ReticleOverlay(),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 20,
              child: Column(
                children: [
                  const ColorPreviewBubble(),
                  const SizedBox(height: 16),
                  _CameraActionButton(
                    heroTag: 'flip_camera',
                    icon: Icons.flip_camera_ios,
                    isActive: false,
                    onPressed: () {
                      ref.read(cameraProvider.notifier).switchCamera();
                    },
                  ),
                  const SizedBox(height: 16),
                  _CameraActionButton(
                    heroTag: 'toggle_flash',
                    icon: state.isFlashOn ? Icons.flash_on : Icons.flash_off,
                    isActive: state.isFlashOn,
                    onPressed: () {
                      ref.read(cameraProvider.notifier).toggleFlash();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text('Camera Error', style: theme.textTheme.titleMedium),
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

/// Semi-transparent floating action button for camera
/// controls.
class _CameraActionButton extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;

  const _CameraActionButton({
    required this.heroTag,
    required this.icon,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      mini: true,
      backgroundColor: isActive
          ? Colors.yellow.withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.3),
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white),
    );
  }
}

/// Circular bubble showing the currently detected color.
class ColorPreviewBubble extends ConsumerWidget {
  const ColorPreviewBubble({super.key});

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

/// Cross-hair reticle at the center of the screen.
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
