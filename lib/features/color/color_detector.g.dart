// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_detector.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ColorDetectorNotifier)
final colorDetectorProvider = ColorDetectorNotifierProvider._();

final class ColorDetectorNotifierProvider
    extends $NotifierProvider<ColorDetectorNotifier, ColorModel> {
  ColorDetectorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'colorDetectorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$colorDetectorNotifierHash();

  @$internal
  @override
  ColorDetectorNotifier create() => ColorDetectorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ColorModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ColorModel>(value),
    );
  }
}

String _$colorDetectorNotifierHash() =>
    r'35c8251daf8652901a1db0764b3cbbea826f1c41';

abstract class _$ColorDetectorNotifier extends $Notifier<ColorModel> {
  ColorModel build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ColorModel, ColorModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ColorModel, ColorModel>,
              ColorModel,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
