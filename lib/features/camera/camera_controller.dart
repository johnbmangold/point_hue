import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'camera_controller.freezed.dart';
part 'camera_controller.g.dart';

@freezed
abstract class CameraState with _$CameraState {
  const factory CameraState({
    required CameraController controller,
    @Default(0) int currentCameraIndex,
    @Default(false) bool isFlashOn,
  }) = _CameraState;
}

@riverpod
class CameraNotifier extends _$CameraNotifier {
  @override
  Future<CameraState?> build() async {
    final cameraState = await _initialize();

    if (cameraState != null) {
      ref.onDispose(() {
        cameraState.controller.dispose();
      });
    }

    return cameraState;
  }

  Future<CameraState?> _initialize({int? index}) async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) return null;

      final cameras = await availableCameras();
      if (cameras.isEmpty) return null;

      int cameraIndex;
      if (index != null) {
        cameraIndex = index % cameras.length;
      } else {
        // Find the first back camera
        final backCameraIndex = cameras.indexWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
        );
        cameraIndex = backCameraIndex != -1 ? backCameraIndex : 0;
      }

      final controller = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );

      await controller.initialize();
      return CameraState(
        controller: controller,
        currentCameraIndex: cameraIndex,
      );
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      return null;
    }
  }

  Future<void> switchCamera() async {
    final currentState = state.value;
    if (currentState == null) return;

    final cameras = await availableCameras();
    if (cameras.length < 2) return;

    final nextIndex = (currentState.currentCameraIndex + 1) % cameras.length;

    // Dispose old controller
    await currentState.controller.dispose();

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _initialize(index: nextIndex));
  }

  Future<void> toggleFlash() async {
    final currentState = state.value;
    if (currentState == null || !currentState.controller.value.isInitialized) {
      return;
    }

    final newFlashMode = !currentState.isFlashOn;

    try {
      await currentState.controller.setFlashMode(
        newFlashMode ? FlashMode.torch : FlashMode.off,
      );
      state = AsyncData(currentState.copyWith(isFlashOn: newFlashMode));
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }
}
