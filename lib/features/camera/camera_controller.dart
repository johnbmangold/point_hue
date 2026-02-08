import 'dart:async';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'camera_controller.g.dart';

@riverpod
class CameraNotifier extends _$CameraNotifier {
  CameraController? _controller;
  bool _isFlashOn = false;

  @override
  FutureOr<CameraController?> build() async {
    ref.onDispose(() {
      _controller?.dispose();
    });
    return _initialize();
  }

  Future<CameraController?> _initialize() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return null;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return null;

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      return _controller;
    } catch (e) {
      return null;
    }
  }

  Future<void> toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      // We don't need to rebuild everything for flash, but could notify if needed.
    } catch (e) {
      _isFlashOn = !_isFlashOn; // revert state on failure
    }
  }

  bool get isFlashOn => _isFlashOn;

  CameraController? get controller => _controller;
}
