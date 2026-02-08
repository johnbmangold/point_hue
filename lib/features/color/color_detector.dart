import 'dart:async';
import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/shared/extensions/color_extensions.dart';

part 'color_detector.g.dart';

@riverpod
class ColorDetectorNotifier extends _$ColorDetectorNotifier {
  bool _isProcessing = false;

  @override
  ColorModel build() {
    // We don't start the stream immediately, it will be started by the UI
    return const ColorModel(hex: '#000000', r: 0, g: 0, b: 0, name: 'Initial');
  }

  Future<void> startDetection(CameraController controller) async {
    try {
      await controller.startImageStream((image) {
        if (_isProcessing) return;
        _isProcessing = true;

        _processImage(image);

        _isProcessing = false;
      });
    } catch (e) {
      debugPrint('Error starting image stream: $e');
    }
  }

  void toggleLock() {
    state = state.copyWith(isLocked: !state.isLocked);
    debugPrint('Color lock state changed: ${state.isLocked}');
  }

  void _processImage(CameraImage image) {
    if (state.isLocked) return;

    try {
      final int width = image.width;
      final int height = image.height;
      final int centerX = width ~/ 2;
      final int centerY = height ~/ 2;

      int r = 0, g = 0, b = 0;

      if (image.format.group == ImageFormatGroup.yuv420) {
        // Y Plane
        final int yIndex = centerY * image.planes[0].bytesPerRow + centerX;
        final int y = image.planes[0].bytes[yIndex];

        // U/V Plane
        final int uvRow = centerY ~/ 2;
        final int uvCol = centerX ~/ 2;

        final int uIndex =
            uvRow * image.planes[1].bytesPerRow +
            (uvCol * image.planes[1].bytesPerPixel!);
        final int vIndex =
            uvRow * image.planes[2].bytesPerRow +
            (uvCol * image.planes[2].bytesPerPixel!);

        final int u = image.planes[1].bytes[uIndex];
        final int v = image.planes[2].bytes[vIndex];

        // YUV to RGB conversion
        r = (y + 1.370705 * (v - 128)).toInt().clamp(0, 255);
        g = (y - 0.337633 * (u - 128) - 0.698001 * (v - 128)).toInt().clamp(
          0,
          255,
        );
        b = (y + 1.732446 * (u - 128)).toInt().clamp(0, 255);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        // iOS typically uses BGRA8888
        final int index = centerY * image.planes[0].bytesPerRow + (centerX * 4);
        b = image.planes[0].bytes[index];
        g = image.planes[0].bytes[index + 1];
        r = image.planes[0].bytes[index + 2];
      } else {
        // debugPrint('Unsupported image format: ${image.format.group}');
        return;
      }

      final color = Color.fromARGB(255, r, g, b);
      // Efficiently update state
      final hex =
          '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

      // Optimization: Only update name if color changes significantly or throttled?
      // For now, update everything but maybe debounced?
      // The user wants instantaneous.
      final name = ColorNames.getName(color);

      state = state.copyWith(hex: hex, r: r, g: g, b: b, name: name);
    } catch (e) {
      debugPrint('Error in _processImage: $e');
    }
  }
}
