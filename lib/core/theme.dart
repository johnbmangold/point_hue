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
    this.hudBackground = const Color(0x66000000),
    this.accentGlow = const Color(0x668F00FF),
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

  /// Background tint for floating frosted glass HUD bars.
  final Color hudBackground;

  /// Accent glow color for interactive highlights.
  final Color accentGlow;

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
    Color? hudBackground,
    Color? accentGlow,
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
      hudBackground: hudBackground ?? this.hudBackground,
      accentGlow: accentGlow ?? this.accentGlow,
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
      hudBackground: Color.lerp(hudBackground, other.hudBackground, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
    );
  }
}

/// Centralized theme definitions for PointHue.
class PointHueTheme {
  // Brand Colors
  static const Color darkCharcoal = Color(0xFF101216);
  static const Color surfaceDark = Color(0xFF181B20);
  static const Color galleryWhite = Color(0xFFF7F8FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color electricViolet = Color(0xFF8F00FF);
  static const Color vibrantCyan = Color(0xFF00E5FF);

  static const _lightOverlay = PointHueOverlayTheme(
    overlayIcon: Colors.white,
    overlayText: Colors.white,
    reticle: Colors.white,
    activeIndicator: Color(0xFFFDD835),
    successColor: Color(0xFF2E7D32),
    overlayCardBackground: Color(0xCCFFFFFF),
    overlayCardBorder: Color(0x33000000),
    lockedBadge: Color(0xFFE8EAF6),
    hudBackground: Color(0x55000000),
    accentGlow: Color(0x448F00FF),
  );

  static const _darkOverlay = PointHueOverlayTheme(
    overlayIcon: Colors.white,
    overlayText: Colors.white,
    reticle: Colors.white,
    activeIndicator: Color(0xFFFDD835),
    successColor: Color(0xFF4CAF50),
    overlayCardBackground: Color(0xCC1A1D24),
    overlayCardBorder: Color(0x22FFFFFF),
    lockedBadge: Color(0xFF311B92),
    hudBackground: Color(0x66000000),
    accentGlow: Color(0x4400E5FF),
  );

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: electricViolet,
      primary: electricViolet,
      secondary: vibrantCyan,
      surface: surfaceLight,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: galleryWhite,
    fontFamily: GoogleFonts.outfit().fontFamily,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0x15000000), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: electricViolet, width: 1.5),
      ),
    ),
    extensions: const <ThemeExtension<dynamic>>[_lightOverlay],
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: vibrantCyan,
      primary: vibrantCyan,
      secondary: electricViolet,
      surface: surfaceDark,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: darkCharcoal,
    fontFamily: GoogleFonts.outfit().fontFamily,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0x22FFFFFF), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: vibrantCyan, width: 1.5),
      ),
    ),
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
