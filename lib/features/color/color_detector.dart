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
  DateTime _lastProcessTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  ColorModel build() {
    // We don't start the stream immediately, it will be started by the UI
    return const ColorModel(hex: '#000000', r: 0, g: 0, b: 0, name: 'Initial');
  }

  Future<void> startDetection(CameraController controller) async {
    debugPrint('Attempting to start image stream...');
    try {
      await controller.startImageStream((image) {
        if (_isProcessing) return;
        _isProcessing = true;

        _processImage(image);

        _isProcessing = false;
      });
      debugPrint('Image stream started successfully');
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

    final now = DateTime.now();
    if (now.difference(_lastProcessTime).inMilliseconds < 500) {
      return;
    }
    _lastProcessTime = now;

    try {
      final int width = image.width;
      final int height = image.height;
      final int centerX = width ~/ 2;
      final int centerY = height ~/ 2;

      int r = 0, g = 0, b = 0;

      if (image.format.group == ImageFormatGroup.yuv420) {
        int sumR = 0, sumG = 0, sumB = 0;
        int count = 0;

        for (int dy = -10; dy < 10; dy++) {
          for (int dx = -10; dx < 10; dx++) {
            final int px = centerX + dx;
            final int py = centerY + dy;

            if (px < 0 || px >= width || py < 0 || py >= height) continue;

            final int yIndex = py * image.planes[0].bytesPerRow + px;
            final int y = image.planes[0].bytes[yIndex];

            final int uvRow = py ~/ 2;
            final int uvCol = px ~/ 2;

            final int uIndex =
                uvRow * image.planes[1].bytesPerRow +
                (uvCol * image.planes[1].bytesPerPixel!);
            final int vIndex =
                uvRow * image.planes[2].bytesPerRow +
                (uvCol * image.planes[2].bytesPerPixel!);

            final int u = image.planes[1].bytes[uIndex];
            final int v = image.planes[2].bytes[vIndex];

            // YUV to RGB conversion
            sumR += (y + 1.370705 * (v - 128)).toInt().clamp(0, 255);
            sumG += (y - 0.337633 * (u - 128) - 0.698001 * (v - 128))
                .toInt()
                .clamp(0, 255);
            sumB += (y + 1.732446 * (u - 128)).toInt().clamp(0, 255);
            count++;
          }
        }

        if (count > 0) {
          r = sumR ~/ count;
          g = sumG ~/ count;
          b = sumB ~/ count;
        }
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        int sumR = 0, sumG = 0, sumB = 0;
        int count = 0;

        for (int dy = -10; dy < 10; dy++) {
          for (int dx = -10; dx < 10; dx++) {
            final int px = centerX + dx;
            final int py = centerY + dy;

            if (px < 0 || px >= width || py < 0 || py >= height) continue;

            final int index = py * image.planes[0].bytesPerRow + (px * 4);
            sumB += image.planes[0].bytes[index];
            sumG += image.planes[0].bytes[index + 1];
            sumR += image.planes[0].bytes[index + 2];
            count++;
          }
        }

        if (count > 0) {
          r = sumR ~/ count;
          g = sumG ~/ count;
          b = sumB ~/ count;
        }
      } else {
        debugPrint('Unsupported image format: ${image.format.group}');
        return;
      }

      final mappedMatch = ColorNames.matchColor(Color.fromARGB(255, r, g, b));
      final actualMatchedColor = mappedMatch.color;

      final hex =
          '#${actualMatchedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

      state = state.copyWith(
        hex: hex,
        r: (actualMatchedColor.r * 255.0).round().clamp(0, 255),
        g: (actualMatchedColor.g * 255.0).round().clamp(0, 255),
        b: (actualMatchedColor.b * 255.0).round().clamp(0, 255),
        name: mappedMatch.name,
      );
    } catch (e) {
      debugPrint('Error in _processImage: $e');
    }
  }
}
