import 'dart:async';
import 'dart:developer' as developer;
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/shared/extensions/color_extensions.dart';

part 'color_detector.g.dart';

/// Result of processing a single camera frame in
/// an isolate.
@visibleForTesting
class DetectionResult {
  final int r;
  final int g;
  final int b;

  const DetectionResult({required this.r, required this.g, required this.b});
}

/// Parameters passed to the background isolate for
/// image processing.
@visibleForTesting
class ImageParams {
  final int width;
  final int height;
  final ImageFormatGroup formatGroup;
  final List<PlaneData> planes;

  const ImageParams({
    required this.width,
    required this.height,
    required this.formatGroup,
    required this.planes,
  });
}

/// Serialisable representation of a camera image plane.
@visibleForTesting
class PlaneData {
  final Uint8List bytes;
  final int bytesPerRow;
  final int? bytesPerPixel;

  const PlaneData({
    required this.bytes,
    required this.bytesPerRow,
    this.bytesPerPixel,
  });
}

@riverpod
class ColorDetectorNotifier extends _$ColorDetectorNotifier {
  DateTime _lastProcessTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  ColorModel build() {
    return const ColorModel(hex: '#000000', r: 0, g: 0, b: 0, name: 'Initial');
  }

  /// Begins streaming camera frames and processing
  /// center-pixel color from each frame.
  Future<void> startDetection(CameraController controller) async {
    developer.log(
      'Attempting to start image stream...',
      name: 'point_hue.color_detector',
    );
    try {
      await controller.startImageStream((image) {
        _processImage(image);
      });
      developer.log(
        'Image stream started successfully',
        name: 'point_hue.color_detector',
      );
    } catch (e, s) {
      developer.log(
        'Error starting image stream',
        name: 'point_hue.color_detector',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Toggles the lock on the current detected color.
  void toggleLock() {
    state = state.copyWith(isLocked: !state.isLocked);
    developer.log(
      'Color lock state changed: ${state.isLocked}',
      name: 'point_hue.color_detector',
    );
  }

  Future<void> _processImage(CameraImage image) async {
    if (state.isLocked) return;

    final now = DateTime.now();
    final elapsed = now.difference(_lastProcessTime).inMilliseconds;
    if (elapsed < 500) return;
    _lastProcessTime = now;

    try {
      // Copy plane data so we can send to an isolate.
      final planes = image.planes.map((p) {
        return PlaneData(
          bytes: Uint8List.fromList(p.bytes),
          bytesPerRow: p.bytesPerRow,
          bytesPerPixel: p.bytesPerPixel,
        );
      }).toList();

      final params = ImageParams(
        width: image.width,
        height: image.height,
        formatGroup: image.format.group,
        planes: planes,
      );

      final result = await Isolate.run(() => extractColor(params));

      if (result == null) return;

      final rawColor = Color.fromARGB(255, result.r, result.g, result.b);

      final match = ColorNames.matchColor(rawColor);

      final hex =
          '#${result.r.toRadixString(16).padLeft(2, '0')}'
                  '${result.g.toRadixString(16).padLeft(2, '0')}'
                  '${result.b.toRadixString(16).padLeft(2, '0')}'
              .toUpperCase();

      state = state.copyWith(
        hex: hex,
        r: result.r,
        g: result.g,
        b: result.b,
        name: match.name,
      );
    } catch (e, s) {
      developer.log(
        'Error in _processImage',
        name: 'point_hue.color_detector',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Pure function that runs in a background isolate.
  /// Extracts the average RGB from the center of the
  /// image.
  @visibleForTesting
  static DetectionResult? extractColor(ImageParams params) {
    final int width = params.width;
    final int height = params.height;
    final int centerX = width ~/ 2;
    final int centerY = height ~/ 2;

    int r = 0, g = 0, b = 0;

    if (params.formatGroup == ImageFormatGroup.yuv420) {
      final result = _processYuv420(
        params.planes,
        width,
        height,
        centerX,
        centerY,
      );
      if (result == null) return null;
      r = result.r;
      g = result.g;
      b = result.b;
    } else if (params.formatGroup == ImageFormatGroup.bgra8888) {
      final result = _processBgra8888(
        params.planes,
        width,
        height,
        centerX,
        centerY,
      );
      if (result == null) return null;
      r = result.r;
      g = result.g;
      b = result.b;
    } else {
      return null;
    }

    return DetectionResult(r: r, g: g, b: b);
  }

  /// Processes YUV420 image data using BT.709 conversion
  /// coefficients for modern device cameras.
  static DetectionResult? _processYuv420(
    List<PlaneData> planes,
    int width,
    int height,
    int centerX,
    int centerY,
  ) {
    if (planes.length < 3) return null;

    final yPlane = planes[0];
    final uPlane = planes[1];
    final vPlane = planes[2];

    // Guard against null bytesPerPixel.
    final uBpp = uPlane.bytesPerPixel ?? 1;
    final vBpp = vPlane.bytesPerPixel ?? 1;

    int sumR = 0, sumG = 0, sumB = 0;
    int count = 0;

    for (int dy = -10; dy < 10; dy++) {
      for (int dx = -10; dx < 10; dx++) {
        final int px = centerX + dx;
        final int py = centerY + dy;

        if (px < 0 || px >= width || py < 0 || py >= height) {
          continue;
        }

        final int yIdx = py * yPlane.bytesPerRow + px;
        if (yIdx < 0 || yIdx >= yPlane.bytes.length) {
          continue;
        }
        final int y = yPlane.bytes[yIdx];

        final int uvRow = py ~/ 2;
        final int uvCol = px ~/ 2;

        final int uIdx = uvRow * uPlane.bytesPerRow + (uvCol * uBpp);
        final int vIdx = uvRow * vPlane.bytesPerRow + (uvCol * vBpp);

        if (uIdx < 0 ||
            uIdx >= uPlane.bytes.length ||
            vIdx < 0 ||
            vIdx >= vPlane.bytes.length) {
          continue;
        }

        final int u = uPlane.bytes[uIdx];
        final int v = vPlane.bytes[vIdx];

        // BT.709 YUV → RGB conversion
        sumR += (y + 1.5748 * (v - 128)).toInt().clamp(0, 255);
        sumG += (y - 0.1873 * (u - 128) - 0.4681 * (v - 128)).toInt().clamp(
          0,
          255,
        );
        sumB += (y + 1.8556 * (u - 128)).toInt().clamp(0, 255);
        count++;
      }
    }

    if (count == 0) return null;

    return DetectionResult(
      r: sumR ~/ count,
      g: sumG ~/ count,
      b: sumB ~/ count,
    );
  }

  /// Processes BGRA8888 image data (iOS).
  static DetectionResult? _processBgra8888(
    List<PlaneData> planes,
    int width,
    int height,
    int centerX,
    int centerY,
  ) {
    if (planes.isEmpty) return null;

    final plane = planes[0];
    int sumR = 0, sumG = 0, sumB = 0;
    int count = 0;

    for (int dy = -10; dy < 10; dy++) {
      for (int dx = -10; dx < 10; dx++) {
        final int px = centerX + dx;
        final int py = centerY + dy;

        if (px < 0 || px >= width || py < 0 || py >= height) {
          continue;
        }

        final int idx = py * plane.bytesPerRow + (px * 4);

        if (idx < 0 || idx + 2 >= plane.bytes.length) {
          continue;
        }

        sumB += plane.bytes[idx];
        sumG += plane.bytes[idx + 1];
        sumR += plane.bytes[idx + 2];
        count++;
      }
    }

    if (count == 0) return null;

    return DetectionResult(
      r: sumR ~/ count,
      g: sumG ~/ count,
      b: sumB ~/ count,
    );
  }
}
