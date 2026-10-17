import 'dart:developer' as developer;

import 'package:camera/camera.dart';
import 'package:material_ui/material_ui.dart';
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
/// controls with themed colors and glassmorphic styling.
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
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: overlayTheme.activeIndicator.withValues(alpha: 0.5),
              blurRadius: 12,
              spreadRadius: 2,
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: heroTag,
        mini: true,
        elevation: 0,
        highlightElevation: 2,
        backgroundColor: isActive
            ? overlayTheme.activeIndicator
            : const Color(0x66000000),
        shape: CircleBorder(
          side: BorderSide(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        tooltip: tooltip,
        onPressed: onPressed,
        child: Icon(
          icon,
          color: isActive ? Colors.black87 : overlayTheme.overlayIcon,
          size: 20,
        ),
      ),
    );
  }
}

/// Circular bubble showing the currently detected
/// color with semantic description and ambient glow.
class ColorPreviewBubble extends ConsumerWidget {
  const ColorPreviewBubble({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorModel = ref.watch(colorDetectorProvider);
    final currentColor = colorModel.toColor();
    final isLocked = colorModel.isLocked;

    return Semantics(
      label:
          'Color preview: ${colorModel.name}, '
          '${colorModel.hex}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: currentColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isLocked ? const Color(0xFF00E5FF) : Colors.white,
            width: isLocked ? 3.5 : 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: currentColor.withValues(alpha: 0.55),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.colorize,
            color: colorModel.contrastForeground,
            size: 22,
          ),
        ),
      ),
    );
  }
}

/// Precision optical cross-hair reticle at the center of the
/// screen with dynamic lock feedback and animated pulse.
class ReticleOverlay extends ConsumerStatefulWidget {
  const ReticleOverlay({super.key});

  @override
  ConsumerState<ReticleOverlay> createState() => _ReticleOverlayState();
}

class _ReticleOverlayState extends ConsumerState<ReticleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 0.94,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorModel = ref.watch(colorDetectorProvider);
    final overlay = Theme.of(context).extension<PointHueOverlayTheme>()!;
    final isLocked = colorModel.isLocked;
    final sampledColor = colorModel.toColor();

    return Center(
      child: Semantics(
        label: isLocked ? 'Color locked at reticle' : 'Color detection reticle',
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final scale = isLocked ? 1.0 : _pulseAnimation.value;
            return Transform.scale(
              scale: scale,
              child: SizedBox(
                width: 64,
                height: 64,
                child: CustomPaint(
                  painter: _ReticlePainter(
                    reticleColor: isLocked
                        ? (overlay.activeIndicator)
                        : overlay.reticle,
                    centerColor: sampledColor,
                    isLocked: isLocked,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  final Color reticleColor;
  final Color centerColor;
  final bool isLocked;

  _ReticlePainter({
    required this.reticleColor,
    required this.centerColor,
    required this.isLocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    // Outer corner target brackets
    final bracketPaint = Paint()
      ..color = reticleColor.withValues(alpha: isLocked ? 0.9 : 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 8.0;
    // Top-left
    canvas.drawLine(
      const Offset(4, 4),
      const Offset(4 + cornerLength, 4),
      bracketPaint,
    );
    canvas.drawLine(
      const Offset(4, 4),
      const Offset(4, 4 + cornerLength),
      bracketPaint,
    );
    // Top-right
    canvas.drawLine(
      Offset(size.width - 4, 4),
      Offset(size.width - 4 - cornerLength, 4),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width - 4, 4),
      Offset(size.width - 4, 4 + cornerLength),
      bracketPaint,
    );
    // Bottom-left
    canvas.drawLine(
      Offset(4, size.height - 4),
      Offset(4 + cornerLength, size.height - 4),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(4, size.height - 4),
      Offset(4, size.height - 4 - cornerLength),
      bracketPaint,
    );
    // Bottom-right
    canvas.drawLine(
      Offset(size.width - 4, size.height - 4),
      Offset(size.width - 4 - cornerLength, size.height - 4),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width - 4, size.height - 4),
      Offset(size.width - 4, size.height - 4 - cornerLength),
      bracketPaint,
    );

    // Inner targeting circle
    final circlePaint = Paint()
      ..color = reticleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isLocked ? 2.5 : 1.5;
    canvas.drawCircle(center, radius - 14, circlePaint);

    // Crosshairs
    final crossPaint = Paint()
      ..color = reticleColor.withValues(alpha: 0.8)
      ..strokeWidth = 1.0;
    const tick = 4.0;
    canvas.drawLine(
      Offset(center.dx, center.dy - radius + 14),
      Offset(center.dx, center.dy - radius + 14 + tick),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + radius - 14),
      Offset(center.dx, center.dy + radius - 14 - tick),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius + 14, center.dy),
      Offset(center.dx - radius + 14 + tick, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius - 14, center.dy),
      Offset(center.dx + radius - 14 - tick, center.dy),
      crossPaint,
    );

    // Center focal point colored with live sample
    final centerFill = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill;
    final centerStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, 4.0, centerFill);
    canvas.drawCircle(center, 4.0, centerStroke);
  }

  @override
  bool shouldRepaint(covariant _ReticlePainter oldDelegate) {
    return oldDelegate.reticleColor != reticleColor ||
        oldDelegate.centerColor != centerColor ||
        oldDelegate.isLocked != isLocked;
  }
}
