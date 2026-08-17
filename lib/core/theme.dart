import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Overlay theme extension for camera-overlay UI
/// elements that need consistent tokens across
/// light and dark modes.
@immutable
class PointHueOverlayTheme extends ThemeExtension<PointHueOverlayTheme> {
  const PointHueOverlayTheme({
    required this.overlayIcon,
    required this.overlayText,
    required this.reticle,
    required this.activeIndicator,
    required this.successColor,
    required this.overlayCardBackground,
    required this.overlayCardBorder,
    required this.lockedBadge,
  });

  /// Color for icons rendered on top of the camera
  /// preview.
  final Color overlayIcon;

  /// Color for text rendered on top of the camera
  /// preview.
  final Color overlayText;

  /// Color of the center crosshair reticle.
  final Color reticle;

  /// Color indicating an active/on state
  /// (e.g. flash on).
  final Color activeIndicator;

  /// Semantic success color for pass badges and
  /// confirmations.
  final Color successColor;

  /// Background for cards overlaid on the camera.
  final Color overlayCardBackground;

  /// Border color for overlay card elements.
  final Color overlayCardBorder;

  /// Badge background when a color is locked.
  final Color lockedBadge;

  @override
  ThemeExtension<PointHueOverlayTheme> copyWith({
    Color? overlayIcon,
    Color? overlayText,
    Color? reticle,
    Color? activeIndicator,
    Color? successColor,
    Color? overlayCardBackground,
    Color? overlayCardBorder,
    Color? lockedBadge,
  }) {
    return PointHueOverlayTheme(
      overlayIcon: overlayIcon ?? this.overlayIcon,
      overlayText: overlayText ?? this.overlayText,
      reticle: reticle ?? this.reticle,
      activeIndicator: activeIndicator ?? this.activeIndicator,
      successColor: successColor ?? this.successColor,
      overlayCardBackground:
          overlayCardBackground ?? this.overlayCardBackground,
      overlayCardBorder: overlayCardBorder ?? this.overlayCardBorder,
      lockedBadge: lockedBadge ?? this.lockedBadge,
    );
  }

  @override
  ThemeExtension<PointHueOverlayTheme> lerp(
    covariant ThemeExtension<PointHueOverlayTheme>? other,
    double t,
  ) {
    if (other is! PointHueOverlayTheme) return this;
    return PointHueOverlayTheme(
      overlayIcon: Color.lerp(overlayIcon, other.overlayIcon, t)!,
      overlayText: Color.lerp(overlayText, other.overlayText, t)!,
      reticle: Color.lerp(reticle, other.reticle, t)!,
      activeIndicator: Color.lerp(activeIndicator, other.activeIndicator, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      overlayCardBackground: Color.lerp(
        overlayCardBackground,
        other.overlayCardBackground,
        t,
      )!,
      overlayCardBorder: Color.lerp(
        overlayCardBorder,
        other.overlayCardBorder,
        t,
      )!,
      lockedBadge: Color.lerp(lockedBadge, other.lockedBadge, t)!,
    );
  }
}

/// Centralized theme definitions for PointHue.
class PointHueTheme {
  // Brand Colors
  static const Color darkCharcoal = Color(0xFF121212);
  static const Color galleryWhite = Color(0xFFF5F5F5);
  static const Color electricViolet = Color(0xFF8F00FF);
  static const Color vibrantCyan = Color(0xFF00E5FF);

  static const _lightOverlay = PointHueOverlayTheme(
    overlayIcon: Colors.white,
    overlayText: Colors.white,
    reticle: Colors.white,
    activeIndicator: Color(0xFFFDD835),
    successColor: Color(0xFF43A047),
    overlayCardBackground: Color(0xE6FFFFFF),
    overlayCardBorder: Color(0x33000000),
    lockedBadge: Color(0xFFE8EAF6),
  );

  static const _darkOverlay = PointHueOverlayTheme(
    overlayIcon: Colors.white,
    overlayText: Colors.white,
    reticle: Colors.white,
    activeIndicator: Color(0xFFFDD835),
    successColor: Color(0xFF66BB6A),
    overlayCardBackground: Color(0xE61E1E1E),
    overlayCardBorder: Color(0x33FFFFFF),
    lockedBadge: Color(0xFF311B92),
  );

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: electricViolet,
      primary: electricViolet,
      secondary: vibrantCyan,
      surface: galleryWhite,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: galleryWhite,
    fontFamily: GoogleFonts.outfit().fontFamily,
    extensions: const <ThemeExtension<dynamic>>[_lightOverlay],
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: vibrantCyan,
      primary: vibrantCyan,
      secondary: electricViolet,
      surface: darkCharcoal,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: darkCharcoal,
    fontFamily: GoogleFonts.outfit().fontFamily,
    extensions: const <ThemeExtension<dynamic>>[_darkOverlay],
  );
}

/// Shared snackbar factory for consistent feedback
/// across the app.
class PointHueSnackBar {
  /// Creates a standard floating snackbar with an
  /// optional leading icon.
  static SnackBar create({
    required BuildContext context,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    final theme = Theme.of(context);
    return SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: theme.colorScheme.onInverseSurface, size: 20),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(message)),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: duration,
      action: action,
    );
  }
}
