## Flutter wrapper
##
## This file contains ProGuard rules for the Flutter framework.
## You can add your own rules here to keep classes or members from being obfuscated or removed.

# Standard Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.shcworks.point_hue.** { *; }

# Keep certain Flutter engine classes
-keep class io.flutter.embedding.engine.FlutterJNI {
    native <methods>;
}

# Preserve GSON/Serialization if used (common in many plugins)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.stream.** { *; }

# Fix for Play Core missing classes
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
