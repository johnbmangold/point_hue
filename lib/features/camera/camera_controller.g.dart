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
    extends $AsyncNotifierProvider<CameraNotifier, CameraController?> {
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

String _$cameraNotifierHash() => r'5ee5c48db2f1b1d0a21b58e10aad96b422c53a35';

abstract class _$CameraNotifier extends $AsyncNotifier<CameraController?> {
  FutureOr<CameraController?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CameraController?>, CameraController?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CameraController?>, CameraController?>,
              AsyncValue<CameraController?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
