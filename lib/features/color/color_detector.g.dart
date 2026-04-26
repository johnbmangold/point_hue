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
    r'190c27c7b182a69079ffd2b3de80bc0b9dff6617';

abstract class _$ColorDetectorNotifier extends $Notifier<ColorModel> {
  ColorModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ColorModel, ColorModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ColorModel, ColorModel>,
              ColorModel,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
