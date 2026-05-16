import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:point_hue/features/color/color_detector.dart';

import 'color_detector_test.mocks.dart';

@GenerateMocks([CameraController])
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

  test('initializes with default black color', () {
    container.listen(colorDetectorProvider, (_, _) {});
    final state = container.read(colorDetectorProvider);
    expect(state.hex, '#000000');
    expect(state.name, 'Initial');
  });

  test('startDetection starts image stream', () async {
    container.listen(colorDetectorProvider, (_, _) {});
    final notifier = container.read(colorDetectorProvider.notifier);

    when(mockController.startImageStream(any)).thenAnswer((_) async {});

    await notifier.startDetection(mockController);

    verify(mockController.startImageStream(any)).called(1);
  });

  test('toggleLock toggles the locked state', () {
    container.listen(colorDetectorProvider, (_, _) {});
    final notifier = container.read(colorDetectorProvider.notifier);

    expect(container.read(colorDetectorProvider).isLocked, false);

    notifier.toggleLock();
    expect(container.read(colorDetectorProvider).isLocked, true);

    notifier.toggleLock();
    expect(container.read(colorDetectorProvider).isLocked, false);
  });

  group('extractColor (static)', () {
    test('YUV420 neutral gray', () {
      const imageSize = 40;

      final yBytes = Uint8List(imageSize * imageSize);
      yBytes.fillRange(0, yBytes.length, 100);

      final uvSize = imageSize ~/ 2;
      final uBytes = Uint8List(uvSize * uvSize);
      uBytes.fillRange(0, uBytes.length, 128);

      final vBytes = Uint8List(uvSize * uvSize);
      vBytes.fillRange(0, vBytes.length, 128);

      final params = ImageParams(
        width: imageSize,
        height: imageSize,
        formatGroup: ImageFormatGroup.yuv420,
        planes: [
          PlaneData(bytes: yBytes, bytesPerRow: imageSize),
          PlaneData(bytes: uBytes, bytesPerRow: uvSize, bytesPerPixel: 1),
          PlaneData(bytes: vBytes, bytesPerRow: uvSize, bytesPerPixel: 1),
        ],
      );

      final result = ColorDetectorNotifier.extractColor(params);

      expect(result, isNotNull);
      // Y=100, U=128, V=128 → neutral gray ≈ 100
      expect(result!.r, inInclusiveRange(98, 102));
      expect(result.g, inInclusiveRange(98, 102));
      expect(result.b, inInclusiveRange(98, 102));
    });

    test('BGRA8888 solid red', () {
      const imageSize = 40;

      final bgraBytes = Uint8List(imageSize * imageSize * 4);
      for (int i = 0; i < bgraBytes.length; i += 4) {
        bgraBytes[i] = 0; // B
        bgraBytes[i + 1] = 0; // G
        bgraBytes[i + 2] = 255; // R
        bgraBytes[i + 3] = 255; // A
      }

      final params = ImageParams(
        width: imageSize,
        height: imageSize,
        formatGroup: ImageFormatGroup.bgra8888,
        planes: [PlaneData(bytes: bgraBytes, bytesPerRow: imageSize * 4)],
      );

      final result = ColorDetectorNotifier.extractColor(params);

      expect(result, isNotNull);
      expect(result!.r, 255);
      expect(result.g, 0);
      expect(result.b, 0);
    });

    test('returns null for unsupported format', () {
      final params = ImageParams(
        width: 10,
        height: 10,
        formatGroup: ImageFormatGroup.nv21,
        planes: [],
      );

      final result = ColorDetectorNotifier.extractColor(params);
      expect(result, isNull);
    });

    test('handles empty planes gracefully', () {
      final params = ImageParams(
        width: 10,
        height: 10,
        formatGroup: ImageFormatGroup.yuv420,
        planes: [],
      );

      final result = ColorDetectorNotifier.extractColor(params);
      expect(result, isNull);
    });

    test('handles null bytesPerPixel', () {
      const imageSize = 40;

      final yBytes = Uint8List(imageSize * imageSize);
      yBytes.fillRange(0, yBytes.length, 200);

      final uvSize = imageSize ~/ 2;
      final uBytes = Uint8List(uvSize * uvSize);
      uBytes.fillRange(0, uBytes.length, 128);

      final vBytes = Uint8List(uvSize * uvSize);
      vBytes.fillRange(0, vBytes.length, 128);

      final params = ImageParams(
        width: imageSize,
        height: imageSize,
        formatGroup: ImageFormatGroup.yuv420,
        planes: [
          PlaneData(bytes: yBytes, bytesPerRow: imageSize),
          PlaneData(
            bytes: uBytes,
            bytesPerRow: uvSize,
            // bytesPerPixel left null
          ),
          PlaneData(
            bytes: vBytes,
            bytesPerRow: uvSize,
            // bytesPerPixel left null
          ),
        ],
      );

      // Should not throw — defaults to 1
      final result = ColorDetectorNotifier.extractColor(params);
      expect(result, isNotNull);
      expect(result!.r, inInclusiveRange(195, 205));
    });
  });
}
