// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CameraNotifier)
final cameraProvider = CameraNotifierProvider._();

final class CameraNotifierProvider
    extends $AsyncNotifierProvider<CameraNotifier, CameraState?> {
  CameraNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cameraProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cameraNotifierHash();

  @$internal
  @override
  CameraNotifier create() => CameraNotifier();
}

String _$cameraNotifierHash() => r'669a3707b8d5ce39ff36a1a13e71673456f9da0c';

abstract class _$CameraNotifier extends $AsyncNotifier<CameraState?> {
  FutureOr<CameraState?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CameraState?>, CameraState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CameraState?>, CameraState?>,
              AsyncValue<CameraState?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
