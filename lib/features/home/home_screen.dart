import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:point_hue/features/camera/camera_view.dart';
import 'package:point_hue/features/color/color_detector.dart';
import 'package:point_hue/core/router.dart';
import 'package:point_hue/core/theme.dart';
import 'package:point_hue/features/color/color_repository.dart';
import 'package:point_hue/features/color/color_model.dart';

/// Main screen with live camera preview and color
/// info overlay.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorModel = ref.watch(colorDetectorProvider);

    // Keep providers alive while on this screen.
    ref.watch(colorLibraryProvider);
    ref.watch(colorHistoryProvider);

    final libraryNotifier = ref.read(colorLibraryProvider.notifier);
    final historyNotifier = ref.read(colorHistoryProvider.notifier);
    final savedColors = ref.watch(colorLibraryProvider).value ?? [];
    final isAlreadySaved = savedColors.any((c) => c.hex == colorModel.hex);
    final overlay = Theme.of(context).extension<PointHueOverlayTheme>()!;

    return Scaffold(
      body: Stack(
        children: [
          const CameraView(),

          // Glassmorphic Top HUD bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: overlay.hudBackground,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Badge(
                          isLabelVisible: savedColors.isNotEmpty,
                          label: Text('${savedColors.length}'),
                          child: const Icon(
                            Icons.collections_bookmark,
                            color: Colors.white,
                          ),
                        ),
                        tooltip: 'Color library',
                        onPressed: () => const LibraryRoute().go(context),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colorModel.toColor(),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorModel.toColor().withValues(
                                    alpha: 0.8,
                                  ),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'PointHue',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ],
                      ),
                      // Balance the row layout.
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Info Card with slide-up entrance.
          _AnimatedColorInfoCard(
            colorModel: colorModel,
            isAlreadySaved: isAlreadySaved,
            onLock: () {
              HapticFeedback.mediumImpact();
              final wasLocked = colorModel.isLocked;
              ref.read(colorDetectorProvider.notifier).toggleLock();
              // Record to history when locking.
              if (!wasLocked) {
                historyNotifier.addRecord(colorModel);
              }
            },
            onSave: () {
              if (isAlreadySaved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  PointHueSnackBar.create(
                    context: context,
                    message: 'Already in library',
                    icon: Icons.info_outline,
                    duration: const Duration(seconds: 1),
                  ),
                );
                return;
              }
              libraryNotifier.saveColor(colorModel);
              ScaffoldMessenger.of(context).showSnackBar(
                PointHueSnackBar.create(
                  context: context,
                  message: 'Color saved to library!',
                  icon: Icons.check_circle,
                ),
              );
            },
            onCopyHex: () {
              Clipboard.setData(ClipboardData(text: colorModel.hex));
              ScaffoldMessenger.of(context).showSnackBar(
                PointHueSnackBar.create(
                  context: context,
                  message: 'Copied ${colorModel.hex}',
                  icon: Icons.copy,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Animates the [ColorInfoCard] with a slide-up
/// and fade-in entrance.
class _AnimatedColorInfoCard extends StatefulWidget {
  final ColorModel colorModel;
  final bool isAlreadySaved;
  final VoidCallback onLock;
  final VoidCallback onSave;
  final VoidCallback onCopyHex;

  const _AnimatedColorInfoCard({
    required this.colorModel,
    required this.isAlreadySaved,
    required this.onLock,
    required this.onSave,
    required this.onCopyHex,
  });

  @override
  State<_AnimatedColorInfoCard> createState() => _AnimatedColorInfoCardState();
}

class _AnimatedColorInfoCardState extends State<_AnimatedColorInfoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).viewPadding.bottom + 20,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ColorInfoCard(
            colorModel: widget.colorModel,
            isAlreadySaved: widget.isAlreadySaved,
            onLock: widget.onLock,
            onSave: widget.onSave,
            onCopyHex: widget.onCopyHex,
          ),
        ),
      ),
    );
  }
}

/// Card that displays the currently detected color
/// with glassmorphic depth, dynamic ambient glow, and streamlined actions.
class ColorInfoCard extends StatelessWidget {
  final ColorModel colorModel;
  final bool isAlreadySaved;
  final VoidCallback onLock;
  final VoidCallback onSave;
  final VoidCallback onCopyHex;

  const ColorInfoCard({
    super.key,
    required this.colorModel,
    required this.isAlreadySaved,
    required this.onLock,
    required this.onSave,
    required this.onCopyHex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overlay = theme.extension<PointHueOverlayTheme>()!;
    final currentColor = colorModel.toColor();
    final hexRaw = colorModel.hex.replaceAll('#', '');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          // Dynamic ambient color backlight glow
          BoxShadow(
            color: currentColor.withValues(alpha: 0.35),
            blurRadius: 30,
            spreadRadius: -2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: overlay.overlayCardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: overlay.overlayCardBorder, width: 0.75),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Tappable color swatch with Hero transition to details
                      Semantics(
                        button: true,
                        label:
                            'Inspect detected color: '
                            '${colorModel.name}, '
                            '${colorModel.hex}',
                        child: InkWell(
                          onTap: () =>
                              ColorDetailRoute(hex: hexRaw).go(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Hero(
                            tag: 'color-${colorModel.hex}',
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: currentColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: currentColor.withValues(alpha: 0.45),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: colorModel.contrastForeground
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Color name + lock badge.
                            Row(
                              children: [
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () => ColorDetailRoute(
                                      hex: hexRaw,
                                    ).go(context),
                                    child: Text(
                                      colorModel.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.2,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                if (colorModel.isLocked) ...[
                                  const SizedBox(width: 6),
                                  _LockedBadge(overlay: overlay, theme: theme),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            // Hex value — tappable to copy.
                            Semantics(
                              button: true,
                              label:
                                  'Copy hex code '
                                  '${colorModel.hex}',
                              child: InkWell(
                                onTap: onCopyHex,
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        colorModel.hex,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'monospace',
                                            ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.copy,
                                        size: 14,
                                        color: theme.textTheme.bodySmall?.color,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Inspect / Details Action
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        tooltip: 'View color details & palette',
                        onPressed: () =>
                            ColorDetailRoute(hex: hexRaw).go(context),
                      ),
                      // Lock toggle.
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: IconButton(
                          key: ValueKey(colorModel.isLocked),
                          icon: Icon(
                            colorModel.isLocked ? Icons.lock : Icons.lock_open,
                            color: colorModel.isLocked
                                ? theme.colorScheme.primary
                                : null,
                          ),
                          tooltip: colorModel.isLocked
                              ? 'Unlock color detection'
                              : 'Lock current color',
                          onPressed: onLock,
                        ),
                      ),
                      // Save button with state feedback.
                      IconButton(
                        icon: Icon(
                          isAlreadySaved
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          color: isAlreadySaved
                              ? theme.colorScheme.primary
                              : null,
                        ),
                        tooltip: isAlreadySaved
                            ? 'Already saved'
                            : 'Save to library',
                        onPressed: onSave,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Animated RGB values with visual channel level meters
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _AnimatedRgbItem(
                          label: 'R',
                          value: colorModel.r,
                          color: const Color(0xFFEF5350),
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: theme.dividerColor.withValues(alpha: 0.5),
                        ),
                        _AnimatedRgbItem(
                          label: 'G',
                          value: colorModel.g,
                          color: const Color(0xFF66BB6A),
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: theme.dividerColor.withValues(alpha: 0.5),
                        ),
                        _AnimatedRgbItem(
                          label: 'B',
                          value: colorModel.b,
                          color: const Color(0xFF42A5F5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small pill badge indicating the color is locked.
class _LockedBadge extends StatelessWidget {
  final PointHueOverlayTheme overlay;
  final ThemeData theme;

  const _LockedBadge({required this.overlay, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: overlay.lockedBadge,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        'LOCKED',
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Displays a single R/G/B channel with an animated
/// counter transition and visual level indicator.
class _AnimatedRgbItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _AnimatedRgbItem({
    required this.label,
    required this.value,
    this.color = const Color(0xFF8F00FF),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: value, end: value),
          duration: const Duration(milliseconds: 300),
          builder: (context, animatedValue, child) {
            return Text(
              animatedValue.toString(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            );
          },
        ),
      ],
    );
  }
}
