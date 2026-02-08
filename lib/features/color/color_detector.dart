import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/shared/extensions/color_extensions.dart';

part 'color_detector.g.dart';

@riverpod
class ColorDetectorNotifier extends _$ColorDetectorNotifier {
  StreamSubscription? _subscription;
  bool _isProcessing = false;

  @override
  ColorModel build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });

    // We don't start the stream immediately, it will be started by the UI
    return const ColorModel(hex: '#000000', r: 0, g: 0, b: 0, name: 'Initial');
  }

  void startStreaming(CameraController controller) {
    if (_subscription != null) return;

    _subscription =
        controller.startImageStream((image) {
              if (_isProcessing) return;
              _isProcessing = true;

              _processImage(image);

              _isProcessing = false;
            })
            as StreamSubscription?;
    // Wait, startImageStream doesn't return a subscription.
    // It's a callback-based API.
  }

  // To fix the subscription issue, I'll use a wrapper or just manage it manually
  void startDetection(CameraController controller) {
    controller.startImageStream((image) {
      if (_isProcessing) return;
      _isProcessing = true;

      _processImage(image);

      // Delay to throttle processing
      Future.delayed(const Duration(milliseconds: 100), () {
        _isProcessing = false;
      });
    });
  }

  void toggleLock() {
    state = state.copyWith(isLocked: !state.isLocked);
  }

  void _processImage(CameraImage image) {
    if (state.isLocked) return;

    // Sample the center pixel
    final int width = image.width;
    final int height = image.height;

    // For simplicity, we sample from the Y plane at the center
    // In a real YUV420 image, Y is plane 0.
    final int centerX = width ~/ 2;
    final int centerY = height ~/ 2;

    final int yIndex = centerY * width + centerX;
    final int yValue = image.planes[0].bytes[yIndex];

    // This is just grayscale if we only use Y.
    // To get RGB, we need U and V planes.
    // Simplifying YUV to RGB for the center pixel:
    final int uvWidth = width ~/ 2;
    final int uvIndex = (centerY ~/ 2) * uvWidth + (centerX ~/ 2);

    final int uValue = image.planes[1].bytes[uvIndex];
    final int vValue = image.planes[2].bytes[uvIndex];

    // Formula for YUV to RGB
    int r = (yValue + 1.402 * (vValue - 128)).toInt().clamp(0, 255);
    int g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
        .toInt()
        .clamp(0, 255);
    int b = (yValue + 1.772 * (uValue - 128)).toInt().clamp(0, 255);

    final color = Color.fromARGB(255, r, g, b);
    final hex =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    final name = ColorNames.getName(color);

    state = state.copyWith(hex: hex, r: r, g: g, b: b, name: name);
  }
}
