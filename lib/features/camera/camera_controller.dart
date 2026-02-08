import 'package:camera/camera.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'camera_controller.freezed.dart';
part 'camera_controller.g.dart';

@freezed
abstract class CameraState with _$CameraState {
  const factory CameraState({
    required CameraController controller,
    @Default(false) bool isFlashOn,
  }) = _CameraState;
}

@riverpod
class CameraNotifier extends _$CameraNotifier {
  @override
  Future<CameraState?> build() async {
    ref.onDispose(() {
      state.asData?.value?.controller.dispose();
    });
    return _initialize();
  }

  Future<CameraState?> _initialize() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return null;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return null;

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();
      return CameraState(controller: controller);
    } catch (e) {
      return null;
    }
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
      // Ignore error
    }
  }
}
