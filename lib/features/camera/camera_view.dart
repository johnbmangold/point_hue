import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:point_hue/features/camera/camera_controller.dart';
import 'package:point_hue/features/color/color_detector.dart';

class CameraView extends ConsumerStatefulWidget {
  const CameraView({super.key});

  @override
  ConsumerState<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends ConsumerState<CameraView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDetection();
    });
  }

  void _startDetection() {
    final cameraState = ref.read(cameraProvider);
    cameraState.whenData((controller) {
      if (controller != null) {
        ref.read(colorDetectorProvider.notifier).startDetection(controller);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);

    return cameraState.when(
      data: (controller) {
        if (controller == null) {
          return const Center(child: Text('No camera available'));
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(controller),
            const ReticleOverlay(),
            const Positioned(top: 80, right: 20, child: ZoomPreview()),
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
