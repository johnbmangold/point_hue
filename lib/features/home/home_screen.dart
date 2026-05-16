import 'package:flutter/material.dart';
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

    return Scaffold(
      body: Stack(
        children: [
          const CameraView(),

          // Header — uses SafeArea-aware positioning.
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.collections_bookmark,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 4)],
                  ),
                  tooltip: 'Color library',
                  onPressed: () => const LibraryRoute().go(context),
                ),
                Text(
                  'PointHue',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [const Shadow(blurRadius: 4)],
                  ),
                ),
                // Balance the row layout.
                const SizedBox(width: 48),
              ],
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
      bottom: MediaQuery.of(context).viewPadding.bottom + 24,
      left: 20,
      right: 20,
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
/// with lock, save, and copy controls.
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

    return Card(
      elevation: 4,
      color: overlay.overlayCardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: overlay.overlayCardBorder, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Color swatch with semantics.
                Semantics(
                  label:
                      'Detected color: '
                      '${colorModel.name}, '
                      '${colorModel.hex}',
                  child: Hero(
                    tag: 'color-${colorModel.hex}',
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colorModel.toColor(),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
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
                            child: Text(
                              colorModel.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (colorModel.isLocked) ...[
                            const SizedBox(width: 6),
                            _LockedBadge(overlay: overlay, theme: theme),
                          ],
                        ],
                      ),
                      // Hex value — tappable to copy.
                      Semantics(
                        button: true,
                        label:
                            'Copy hex code '
                            '${colorModel.hex}',
                        child: InkWell(
                          onTap: onCopyHex,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  colorModel.hex,
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(width: 4),
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
                // Lock toggle.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
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
                    isAlreadySaved ? Icons.bookmark : Icons.bookmark_outline,
                  ),
                  tooltip: isAlreadySaved ? 'Already saved' : 'Save to library',
                  onPressed: onSave,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Animated RGB values.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AnimatedRgbItem(label: 'R', value: colorModel.r),
                _AnimatedRgbItem(label: 'G', value: colorModel.g),
                _AnimatedRgbItem(label: 'B', value: colorModel.b),
              ],
            ),
          ],
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
        borderRadius: BorderRadius.circular(4),
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
/// counter transition.
class _AnimatedRgbItem extends StatelessWidget {
  final String label;
  final int value;

  const _AnimatedRgbItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: value, end: value),
          duration: const Duration(milliseconds: 300),
          builder: (context, animatedValue, child) {
            return Text(
              animatedValue.toString(),
              style: theme.textTheme.bodyLarge,
            );
          },
        ),
      ],
    );
  }
}
