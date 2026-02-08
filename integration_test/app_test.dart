import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:point_hue/core/router.dart';
import 'package:point_hue/features/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUpAll(() {
    // Mock Camera Channel
    const MethodChannel cameraChannel = MethodChannel(
      'plugins.flutter.io/camera',
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(cameraChannel, (MethodCall methodCall) async {
          if (methodCall.method == 'availableCameras') {
            return [
              {'name': 'cam1', 'lensFacing': 'back', 'sensorOrientation': 90},
            ];
          }
          if (methodCall.method == 'create') {
            return {'cameraId': 1, 'imageFormatGroup': 'yuv420'};
          }
          if (methodCall.method == 'initialize') {
            return null;
          }
          if (methodCall.method == 'setFlashMode') {
            return null;
          }
          if (methodCall.method == 'startImageStream') {
            return null;
          }
          if (methodCall.method == 'stopImageStream') {
            return null;
          }
          return null;
        });

    // Mock Wakelock Channel
    const MethodChannel wakelockChannel = MethodChannel(
      'dev.fluttercommunity.plus/wakelock',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(wakelockChannel, (
          MethodCall methodCall,
        ) async {
          return true;
        });

    // Mock Permission Handler Channel
    const MethodChannel permissionChannel = MethodChannel(
      'flutter.baseflow.com/permissions/methods',
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (
          MethodCall methodCall,
        ) async {
          debugPrint('PermissionChannel method called: ${methodCall.method}');
          if (methodCall.method == 'requestPermissions') {
            return {
              1: 1, // PermissionStatus.granted
            };
          }
          return null;
        });
  });

  testWidgets('Full app flow', (tester) async {
    // Start app
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: goRouter)),
    );
    await tester.pumpAndSettle();

    // Verify Home Screen
    expect(find.text('PointHue'), findsOneWidget);

    // Tap Library
    await tester.tap(find.byIcon(Icons.collections_bookmark));
    await tester.pumpAndSettle();

    // Verify Library Screen
    expect(find.text('Color Library'), findsOneWidget);

    // Go back
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Verify we are back home
    expect(find.text('PointHue'), findsOneWidget);

    // Verify ColorInfoCard
    expect(find.byType(ColorInfoCard), findsOneWidget);

    // Toggle Flash (interact with camera controller)
    await tester.tap(find.byIcon(Icons.flash_on));
    await tester.pump();

    // Lock color
    await tester.tap(find.byIcon(Icons.lock_open));
    await tester.pump();

    expect(find.byIcon(Icons.lock), findsOneWidget);

    // Save color
    await tester.tap(find.byIcon(Icons.save_outlined));
    await tester.pump(); // Start animation
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // Wait for snackbar to appear

    // Verify snackbar
    expect(find.text('Color saved to library!'), findsOneWidget);

    // Verify in library
    await tester.tap(find.byIcon(Icons.collections_bookmark));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsOneWidget); // Should be in list now
  });
}
