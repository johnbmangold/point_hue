import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_hue/features/camera/camera_controller.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCameraPlatform extends CameraPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<List<CameraDescription>> availableCameras() async {
    return [
      const CameraDescription(
        name: 'cam1',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      ),
    ];
  }

  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset, {
    bool? enableAudio,
  }) async {
    return 1;
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup? imageFormatGroup,
  }) async {
    // Return successfully
  }

  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) async {
    // Return successfully
  }

  @override
  Future<void> dispose(int cameraId) async {
    // Return successfully
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return Stream.value(
      CameraInitializedEvent(
        cameraId,
        1920,
        1080,
        ExposureMode.auto,
        true,
        FocusMode.auto,
        true,
      ),
    );
  }

  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(int cameraId) {
    return const Stream.empty();
  }

  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) {
    return const Stream.empty();
  }

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    return const Stream.empty();
  }

  @override
  Stream<VideoRecordedEvent> onVideoRecordedEvent(int cameraId) {
    return const Stream.empty();
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    return const Stream.empty();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();

    // Mock Camera Platform
    CameraPlatform.instance = MockCameraPlatform();

    // Mock Permission Handler Channel (keep this as it is external package)
    const MethodChannel permissionChannel = MethodChannel(
      'flutter.baseflow.com/permissions/methods',
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'requestPermissions') {
            return {
              1: 1, // PermissionStatus.granted
            };
          }
          return null;
        });
  });

  tearDown(() {
    container.dispose();
  });

  test('CameraNotifier initializes successfully', () async {
    // Keep provider alive
    container.listen(cameraProvider, (_, _) {});

    final CameraState? cameraState = await container.read(
      cameraProvider.future,
    );

    expect(cameraState, isNotNull);
    expect(cameraState!.controller, isA<CameraController>());
    expect(cameraState.isFlashOn, false);
  });

  test('toggleFlash toggles the flash state', () async {
    // Keep provider alive
    container.listen(cameraProvider, (_, _) {});

    // Wait for initialization
    await container.read(cameraProvider.future);
    final notifier = container.read(cameraProvider.notifier);

    // Initial state check
    CameraState? state = container.read(cameraProvider).value;
    expect(state, isNotNull);
    expect(state?.isFlashOn, false);

    // Toggle Flash
    await notifier.toggleFlash();

    // Verify state change
    state = container.read(cameraProvider).value;
    expect(state?.isFlashOn, true);

    // Toggle Flash back
    await notifier.toggleFlash();

    state = container.read(cameraProvider).value;
    expect(state?.isFlashOn, false);
  });
}
