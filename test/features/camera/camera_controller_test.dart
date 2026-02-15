import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:point_hue/features/camera/camera_controller.dart';

import 'camera_controller_test.mocks.dart';

@GenerateMocks([CameraController, CameraValue])
class FakeCameraNotifier extends CameraNotifier {
  final CameraController _controller;
  final bool _isFlashOn;
  final int _currentCameraIndex;

  FakeCameraNotifier(
    this._controller, {
    bool isFlashOn = false,
    int currentCameraIndex = 0,
  }) : _isFlashOn = isFlashOn,
       _currentCameraIndex = currentCameraIndex;

  @override
  Future<CameraState?> build() async {
    return CameraState(
      controller: _controller,
      isFlashOn: _isFlashOn,
      currentCameraIndex: _currentCameraIndex,
    );
  }

  @override
  Future<void> toggleFlash() async {
    final currentState = state.value;
    if (currentState == null) return;
    state = AsyncData(
      currentState.copyWith(isFlashOn: !currentState.isFlashOn),
    );
  }

  @override
  Future<void> switchCamera() async {
    final currentState = state.value;
    if (currentState == null) return;
    state = AsyncData(
      currentState.copyWith(
        currentCameraIndex: (currentState.currentCameraIndex + 1) % 2,
      ),
    );
  }
}

void main() {
  late ProviderContainer container;
  late MockCameraController mockController;
  late MockCameraValue mockValue;

  setUp(() {
    mockController = MockCameraController();
    mockValue = MockCameraValue();

    when(mockController.value).thenReturn(mockValue);
    when(mockValue.isInitialized).thenReturn(true);

    container = ProviderContainer(
      overrides: [
        cameraProvider.overrideWith(() => FakeCameraNotifier(mockController)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('CameraNotifier (Fake) initializes successfully', () async {
    // Keep provider alive
    container.listen(cameraProvider, (_, __) {});

    // Wait for initialization
    await container.read(cameraProvider.future);

    final state = container.read(cameraProvider);

    expect(state.value, isNotNull);
    expect(state.value?.controller, mockController);
    expect(state.value?.isFlashOn, false);
    expect(state.value?.currentCameraIndex, 0);
  });

  test('toggleFlash toggles the flash state in FakeCameraNotifier', () async {
    // Keep provider alive
    container.listen(cameraProvider, (_, __) {});

    // Wait for initialization
    await container.read(cameraProvider.future);
    final notifier = container.read(cameraProvider.notifier);

    // Initial state check
    expect(container.read(cameraProvider).value?.isFlashOn, false);

    // Toggle Flash
    await notifier.toggleFlash();

    // Verify state change
    expect(container.read(cameraProvider).value?.isFlashOn, true);

    // Toggle Flash back
    await notifier.toggleFlash();
    expect(container.read(cameraProvider).value?.isFlashOn, false);
  });

  test('switchCamera switches camera index in FakeCameraNotifier', () async {
    // Keep provider alive
    container.listen(cameraProvider, (_, __) {});

    // Wait for initialization
    await container.read(cameraProvider.future);
    final notifier = container.read(cameraProvider.notifier);

    // Initial state check
    expect(container.read(cameraProvider).value?.currentCameraIndex, 0);

    // Switch Camera
    await notifier.switchCamera();

    // Verify state change
    expect(container.read(cameraProvider).value?.currentCameraIndex, 1);

    // Switch Camera back
    await notifier.switchCamera();
    expect(container.read(cameraProvider).value?.currentCameraIndex, 0);
  });
}
