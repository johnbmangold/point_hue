import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:point_hue/features/camera/camera_controller.dart';
import 'package:point_hue/features/color/color_detector.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/features/color/color_repository.dart';
import 'package:point_hue/features/home/home_screen.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([CameraController])
void main() {
  late MockCameraController mockCameraController;

  setUp(() {
    mockCameraController = MockCameraController();

    when(mockCameraController.value).thenReturn(
      const CameraValue(
        isInitialized: true,
        isRecordingVideo: false,
        isTakingPicture: false,
        isStreamingImages: false,
        errorDescription: null,
        previewSize: Size(100, 100),
        isRecordingPaused: false,
        flashMode: FlashMode.off,
        exposureMode: ExposureMode.auto,
        focusMode: FocusMode.auto,
        exposurePointSupported: false,
        focusPointSupported: false,
        deviceOrientation: DeviceOrientation.portraitUp,
        description: CameraDescription(
          name: 'cam1',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90,
        ),
      ),
    );

    when(mockCameraController.buildPreview()).thenReturn(const SizedBox());

    // Mock method channels
    const MethodChannel cameraChannel = MethodChannel(
      'plugins.flutter.io/camera',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(cameraChannel, (MethodCall methodCall) async {
          return null;
        });

    const MethodChannel wakelockChannel = MethodChannel(
      'dev.fluttercommunity.plus/wakelock',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(wakelockChannel, (
          MethodCall methodCall,
        ) async {
          return true;
        });
  });

  testWidgets('HomeScreen renders correctly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cameraProvider.overrideWith(
            () => FakeCameraNotifier(mockCameraController),
          ),
          colorLibraryProvider.overrideWith(() => FakeLibraryNotifier()),
          colorHistoryProvider.overrideWith(() => FakeHistoryNotifier()),
          colorDetectorProvider.overrideWith(() => FakeColorDetectorNotifier()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pump();

    // Verify key elements
    expect(find.text('PointHue'), findsOneWidget);
    expect(find.byIcon(Icons.collections_bookmark), findsOneWidget);
    expect(find.byIcon(Icons.flip_camera_ios), findsOneWidget);

    // ColorInfoCard should appear
    expect(find.byType(ColorInfoCard), findsOneWidget);

    // Verify copy icon is present
    expect(find.byIcon(Icons.copy), findsOneWidget);
  });

  testWidgets('Lock toggles icon', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cameraProvider.overrideWith(
            () => FakeCameraNotifier(mockCameraController),
          ),
          colorLibraryProvider.overrideWith(() => FakeLibraryNotifier()),
          colorHistoryProvider.overrideWith(() => FakeHistoryNotifier()),
          colorDetectorProvider.overrideWith(() => FakeColorDetectorNotifier()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pump();

    // Initially unlocked
    expect(find.byIcon(Icons.lock_open), findsOneWidget);

    // Tap lock
    await tester.tap(find.byIcon(Icons.lock_open));
    await tester.pumpAndSettle();

    // Now locked
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });
}

class FakeCameraNotifier extends CameraNotifier {
  final CameraController _controller;
  FakeCameraNotifier(this._controller);

  @override
  Future<CameraState?> build() async {
    return CameraState(
      controller: _controller,
      currentCameraIndex: 0,
      isFlashOn: false,
    );
  }

  @override
  Future<void> toggleFlash() async {}
}

class FakeLibraryNotifier extends ColorLibraryNotifier {
  @override
  Future<List<ColorModel>> build() async {
    return [];
  }

  @override
  Future<void> saveColor(ColorModel color) async {}
}

class FakeHistoryNotifier extends ColorHistoryNotifier {
  @override
  Future<List<ColorModel>> build() async {
    return [];
  }

  @override
  Future<void> addRecord(ColorModel color) async {}
}

class FakeColorDetectorNotifier extends ColorDetectorNotifier {
  @override
  ColorModel build() {
    return const ColorModel(hex: '#000000', r: 0, g: 0, b: 0, name: 'Fake');
  }
}
