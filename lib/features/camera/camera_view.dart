import 'dart:developer' as developer;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:point_hue/core/theme.dart';
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
    final overlay = theme.extension<PointHueOverlayTheme>()!;

    return cameraState.when(
      data: (state) {
        if (state == null) {
          return _PermissionDeniedView(theme: theme);
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
                    tooltip: 'Switch camera',
                    overlayTheme: overlay,
                    onPressed: () {
                      ref.read(cameraProvider.notifier).switchCamera();
                    },
                  ),
                  const SizedBox(height: 16),
                  _CameraActionButton(
                    heroTag: 'toggle_flash',
                    icon: state.isFlashOn ? Icons.flash_on : Icons.flash_off,
                    isActive: state.isFlashOn,
                    tooltip: state.isFlashOn
                        ? 'Turn flash off'
                        : 'Turn flash on',
                    overlayTheme: overlay,
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

/// View shown when camera permission is denied.
class _PermissionDeniedView extends StatelessWidget {
  final ThemeData theme;

  const _PermissionDeniedView({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera Access Required',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'PointHue needs camera access to '
              'detect colors from your surroundings.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => openAppSettings(),
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Semi-transparent floating action button for camera
/// controls with themed colors.
class _CameraActionButton extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final bool isActive;
  final String tooltip;
  final PointHueOverlayTheme overlayTheme;
  final VoidCallback onPressed;

  const _CameraActionButton({
    required this.heroTag,
    required this.icon,
    required this.isActive,
    required this.tooltip,
    required this.overlayTheme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      mini: true,
      backgroundColor: isActive
          ? overlayTheme.activeIndicator.withValues(alpha: 0.5)
          : overlayTheme.overlayIcon.withValues(alpha: 0.3),
      tooltip: tooltip,
      onPressed: onPressed,
      child: Icon(icon, color: overlayTheme.overlayIcon),
    );
  }
}

/// Circular bubble showing the currently detected
/// color with semantic description.
class ColorPreviewBubble extends ConsumerWidget {
  const ColorPreviewBubble({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorModel = ref.watch(colorDetectorProvider);
    final overlay = Theme.of(context).extension<PointHueOverlayTheme>()!;

    return Semantics(
      label:
          'Color preview: ${colorModel.name}, '
          '${colorModel.hex}',
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: colorModel.toColor(),
          shape: BoxShape.circle,
          border: Border.all(color: overlay.overlayIcon, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Icon(Icons.colorize, color: overlay.overlayIcon, size: 20),
        ),
      ),
    );
  }
}

/// Animated cross-hair reticle at the center of the
/// screen with a gentle pulsing effect.
class ReticleOverlay extends StatefulWidget {
  const ReticleOverlay({super.key});

  @override
  State<ReticleOverlay> createState() => _ReticleOverlayState();
}

class _ReticleOverlayState extends State<ReticleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overlay = Theme.of(context).extension<PointHueOverlayTheme>()!;

    return Center(
      child: Semantics(
        label: 'Color detection reticle',
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(color: overlay.reticle, width: 2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: overlay.reticle,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
