// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ColorLibraryNotifier)
final colorLibraryProvider = ColorLibraryNotifierProvider._();

final class ColorLibraryNotifierProvider
    extends $AsyncNotifierProvider<ColorLibraryNotifier, List<ColorModel>> {
  ColorLibraryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'colorLibraryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$colorLibraryNotifierHash();

  @$internal
  @override
  ColorLibraryNotifier create() => ColorLibraryNotifier();
}

String _$colorLibraryNotifierHash() =>
    r'1908ffdcac875d2c63562344e989c1b1635be635';

abstract class _$ColorLibraryNotifier extends $AsyncNotifier<List<ColorModel>> {
  FutureOr<List<ColorModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ColorModel>>, List<ColorModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ColorModel>>, List<ColorModel>>,
              AsyncValue<List<ColorModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ColorHistoryNotifier)
final colorHistoryProvider = ColorHistoryNotifierProvider._();

final class ColorHistoryNotifierProvider
    extends $AsyncNotifierProvider<ColorHistoryNotifier, List<ColorModel>> {
  ColorHistoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'colorHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$colorHistoryNotifierHash();

  @$internal
  @override
  ColorHistoryNotifier create() => ColorHistoryNotifier();
}

String _$colorHistoryNotifierHash() =>
    r'8f333ec391522384ad8e9cbf85790eabacd2855e';

abstract class _$ColorHistoryNotifier extends $AsyncNotifier<List<ColorModel>> {
  FutureOr<List<ColorModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ColorModel>>, List<ColorModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ColorModel>>, List<ColorModel>>,
              AsyncValue<List<ColorModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
