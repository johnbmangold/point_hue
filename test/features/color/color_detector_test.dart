import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:point_hue/features/color/color_detector.dart';

import 'color_detector_test.mocks.dart';

@GenerateMocks([CameraController, CameraImage, Plane, ImageFormat])
void main() {
  late ProviderContainer container;
  late MockCameraController mockController;

  setUp(() {
    container = ProviderContainer();
    mockController = MockCameraController();
  });

  tearDown(() {
    container.dispose();
  });

  test('ColorDetectorNotifier initializes with default black color', () {
    // Keep alive
    container.listen(colorDetectorProvider, (_, _) {});

    final state = container.read(colorDetectorProvider);
    expect(state.hex, '#000000');
    expect(state.name, 'Initial');
  });

  test('startDetection starts image stream', () async {
    // Keep alive
    container.listen(colorDetectorProvider, (_, _) {});

    final notifier = container.read(colorDetectorProvider.notifier);

    when(mockController.startImageStream(any)).thenAnswer((_) async {});

    await notifier.startDetection(mockController);

    verify(mockController.startImageStream(any)).called(1);
  });

  test('Color processing logic (YUV420)', () async {
    // Keep alive
    container.listen(colorDetectorProvider, (_, _) {});

    final notifier = container.read(colorDetectorProvider.notifier);

    // Mock Image Data for a simple color (e.g., Red-ish or Grey-ish)
    // create a 2x2 image
    final mockImage = MockCameraImage();
    final mockPlaneY = MockPlane();
    final mockPlaneU = MockPlane();
    final mockPlaneV = MockPlane();
    final mockFormat = MockImageFormat();

    when(mockFormat.group).thenReturn(ImageFormatGroup.yuv420);
    when(mockImage.format).thenReturn(mockFormat);
    when(mockImage.width).thenReturn(2);
    when(mockImage.height).thenReturn(2);
    when(mockImage.planes).thenReturn([mockPlaneY, mockPlaneU, mockPlaneV]);

    // Y Plane (2x2)
    // 4 bytes
    final yBytes = Uint8List.fromList([100, 100, 100, 100]);
    when(mockPlaneY.bytes).thenReturn(yBytes);
    when(mockPlaneY.bytesPerRow).thenReturn(2);

    // U Plane (1x1 for 2x2 image in 4:2:0 subsampling usually means quarter size, so 1x1)
    // But Android might give different strides. Let's assume standard.
    // 2x2 image -> 1x1 UV
    final uvBytes = Uint8List.fromList([128]);
    when(mockPlaneU.bytes).thenReturn(uvBytes);
    when(mockPlaneU.bytesPerRow).thenReturn(1);
    when(mockPlaneU.bytesPerPixel).thenReturn(1);

    final vBytes = Uint8List.fromList([128]);
    when(mockPlaneV.bytes).thenReturn(vBytes);
    when(mockPlaneV.bytesPerRow).thenReturn(1);
    when(mockPlaneV.bytesPerPixel).thenReturn(1);

    // Setup StartImageStream to capture callback and execute it
    when(mockController.startImageStream(any)).thenAnswer((invocation) async {
      final callback =
          invocation.positionalArguments[0] as void Function(CameraImage);
      callback(mockImage);
    });

    await notifier.startDetection(mockController);

    final state = container.read(colorDetectorProvider);

    // With Y=100, U=128, V=128 (neutral gray)
    // R = Y + 1.402*(V-128) = 100
    // G = Y - 0.344136*(U-128) - 0.714136*(V-128) = 100
    // B = Y + 1.772*(U-128) = 100
    // Expect RGB(100, 100, 100) -> Hex #646464

    expect(state.r, 100);
    expect(state.g, 100);
    expect(state.b, 100);
    expect(state.hex, '#646464');
  });
}
