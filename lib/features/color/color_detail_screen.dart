import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/core/theme.dart';
import 'package:point_hue/features/color/color_repository.dart';

/// Screen displaying deep details about a single color,
/// including color spaces, harmonies, and accessibility scores.
class ColorDetailScreen extends ConsumerWidget {
  final String hex;

  const ColorDetailScreen({super.key, required this.hex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ColorModel> allColors = [
      ...ref.watch(colorLibraryProvider).value ?? [],
      ...ref.watch(colorHistoryProvider).value ?? [],
    ];

    final colorModel = allColors.firstWhere(
      (c) => c.hex.replaceAll('#', '').toLowerCase() == hex.toLowerCase(),
      orElse: () => ColorModel(hex: '#$hex', r: 0, g: 0, b: 0, name: 'Unknown'),
    );

    final color = colorModel.toColor();
    final contrastWithWhite = _calculateContrast(color, Colors.white);
    final contrastWithBlack = _calculateContrast(color, Colors.black);

    final theme = Theme.of(context);
    final isLight =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light;
    final textColor = isLight ? Colors.black87 : Colors.white;
    final overlay = theme.extension<PointHueOverlayTheme>()!;

    final savedColors = ref.watch(colorLibraryProvider).value ?? [];
    final isSaved = savedColors.any((c) => c.hex == colorModel.hex);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: textColor,
            ),
            tooltip: isSaved ? 'Remove from library' : 'Save to library',
            onPressed: () {
              if (isSaved) {
                ref
                    .read(colorLibraryProvider.notifier)
                    .removeColor(colorModel.hex);
                _showExportSnackbar(context, 'Removed from library');
              } else {
                ref.read(colorLibraryProvider.notifier).saveColor(colorModel);
                _showExportSnackbar(context, 'Saved to library!');
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: textColor),
            tooltip: 'Copy color summary',
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text:
                      '${colorModel.name} (${colorModel.hex}) - ${colorModel.rgbString}',
                ),
              );
              _showExportSnackbar(context, 'Summary copied to clipboard');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tall Immersive Hero Header
            Hero(
              tag: 'color-${colorModel.hex}',
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isLight ? Colors.black12 : Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              colorModel.hex,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            colorModel.name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Color Values Section
                  _InfoCard(
                    title: 'Values',
                    icon: Icons.numbers,
                    theme: theme,
                    children: [
                      _ValueRow(
                        label: 'HEX',
                        value: colorModel.hex,
                        theme: theme,
                        onTapCopy: () {
                          Clipboard.setData(
                            ClipboardData(text: colorModel.hex),
                          );
                          _showExportSnackbar(
                            context,
                            'Copied ${colorModel.hex}',
                          );
                        },
                      ),
                      _ValueRow(
                        label: 'RGB',
                        value: colorModel.rgbString,
                        theme: theme,
                        onTapCopy: () {
                          Clipboard.setData(
                            ClipboardData(text: colorModel.rgbString),
                          );
                          _showExportSnackbar(
                            context,
                            'Copied ${colorModel.rgbString}',
                          );
                        },
                      ),
                      _ValueRow(
                        label: 'HSL',
                        value: colorModel.hslString,
                        theme: theme,
                        onTapCopy: () {
                          Clipboard.setData(
                            ClipboardData(text: colorModel.hslString),
                          );
                          _showExportSnackbar(
                            context,
                            'Copied ${colorModel.hslString}',
                          );
                        },
                      ),
                      _ValueRow(
                        label: 'HSV',
                        value: colorModel.hsvString,
                        theme: theme,
                        onTapCopy: () {
                          Clipboard.setData(
                            ClipboardData(text: colorModel.hsvString),
                          );
                          _showExportSnackbar(
                            context,
                            'Copied ${colorModel.hsvString}',
                          );
                        },
                      ),
                      _ValueRow(
                        label: 'CMYK',
                        value: colorModel.cmykString,
                        isLast: true,
                        theme: theme,
                        onTapCopy: () {
                          Clipboard.setData(
                            ClipboardData(text: colorModel.cmykString),
                          );
                          _showExportSnackbar(
                            context,
                            'Copied ${colorModel.cmykString}',
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Color Harmonies & Palettes Section
                  _InfoCard(
                    title: 'Harmonies & Palette',
                    icon: Icons.palette,
                    theme: theme,
                    children: [
                      Text(
                        'Complementary',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _HarmonySwatch(
                            color: color,
                            label: 'Base',
                            onTap: () => _copyHex(context, color),
                          ),
                          const SizedBox(width: 12),
                          _HarmonySwatch(
                            color: colorModel.complementary,
                            label: 'Opposite',
                            onTap: () =>
                                _copyHex(context, colorModel.complementary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Analogous',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final harmonyColor in colorModel.analogous) ...[
                            _HarmonySwatch(
                              color: harmonyColor,
                              onTap: () => _copyHex(context, harmonyColor),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Monochromatic Shades',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final shade in colorModel.shades) ...[
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _copyHex(context, shade),
                                child: Container(
                                  height: 44,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: shade,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: theme.dividerColor.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Accessibility (WCAG 2.1) Section
                  _InfoCard(
                    title: 'Accessibility (WCAG 2.1)',
                    icon: Icons.accessibility_new,
                    theme: theme,
                    children: [
                      _ContrastRow(
                        label: 'White Text',
                        ratio: contrastWithWhite,
                        theme: theme,
                        overlay: overlay,
                      ),
                      _ContrastRow(
                        label: 'Black Text',
                        ratio: contrastWithBlack,
                        isLast: true,
                        theme: theme,
                        overlay: overlay,
                      ),
                      const SizedBox(height: 12),
                      // Visual Contrast Preview Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'White text sample on background',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Black text sample on background',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Export Options
                  _InfoCard(
                    title: 'Export',
                    icon: Icons.ios_share,
                    theme: theme,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ExportChip(
                            label: 'Copy CSS',
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text:
                                      'color: rgb(${colorModel.r}, ${colorModel.g}, ${colorModel.b});',
                                ),
                              );
                              _showExportSnackbar(context, 'CSS Copied');
                            },
                          ),
                          _ExportChip(
                            label: 'Copy Swift',
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text:
                                      'Color(red: ${colorModel.r}/255, green: ${colorModel.g}/255, blue: ${colorModel.b}/255)',
                                ),
                              );
                              _showExportSnackbar(context, 'Swift Copied');
                            },
                          ),
                          _ExportChip(
                            label: 'Copy Flutter',
                            onTap: () {
                              final hexString = colorModel.hex
                                  .replaceAll('#', '0xFF')
                                  .toUpperCase();
                              Clipboard.setData(
                                ClipboardData(text: 'Color($hexString)'),
                              );
                              _showExportSnackbar(context, 'Flutter Copied');
                            },
                          ),
                          _ExportChip(
                            label: 'Copy Compose',
                            onTap: () {
                              final hexString = colorModel.hex
                                  .replaceAll('#', '0xFF')
                                  .toUpperCase();
                              Clipboard.setData(
                                ClipboardData(text: 'Color($hexString)'),
                              );
                              _showExportSnackbar(context, 'Compose Copied');
                            },
                          ),
                          _ExportChip(
                            label: 'Copy Tailwind',
                            onTap: () {
                              final nameSlug = colorModel.name
                                  .toLowerCase()
                                  .replaceAll(' ', '-');
                              Clipboard.setData(
                                ClipboardData(
                                  text: "'$nameSlug': '${colorModel.hex}',",
                                ),
                              );
                              _showExportSnackbar(context, 'Tailwind Copied');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyHex(BuildContext context, Color c) {
    final hexCode =
        '#${(c.r * 255).round().toRadixString(16).padLeft(2, '0')}'
                '${(c.g * 255).round().toRadixString(16).padLeft(2, '0')}'
                '${(c.b * 255).round().toRadixString(16).padLeft(2, '0')}'
            .toUpperCase();
    Clipboard.setData(ClipboardData(text: hexCode));
    _showExportSnackbar(context, 'Copied $hexCode');
  }

  double _calculateContrast(Color c1, Color c2) {
    final l1 = c1.computeLuminance();
    final l2 = c2.computeLuminance();
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  void _showExportSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      PointHueSnackBar.create(
        context: context,
        message: message,
        icon: Icons.content_copy,
      ),
    );
  }
}

class _HarmonySwatch extends StatelessWidget {
  final Color color;
  final String? label;
  final VoidCallback onTap;

  const _HarmonySwatch({required this.color, this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hexString =
        '#${(color.r * 255).round().toRadixString(16).padLeft(2, '0')}'
                '${(color.g * 255).round().toRadixString(16).padLeft(2, '0')}'
                '${(color.b * 255).round().toRadixString(16).padLeft(2, '0')}'
            .toUpperCase();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label ?? hexString,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}

/// A card container for grouping related color details.
class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeData theme;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.theme,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  final ThemeData theme;
  final VoidCallback? onTapCopy;

  const _ValueRow({
    required this.label,
    required this.value,
    this.isLast = false,
    required this.theme,
    this.onTapCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          InkWell(
            onTap: onTapCopy,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (onTapCopy != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.copy,
                      size: 13,
                      color: theme.colorScheme.outline,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContrastRow extends StatelessWidget {
  final String label;
  final double ratio;
  final bool isLast;
  final ThemeData theme;
  final PointHueOverlayTheme overlay;

  const _ContrastRow({
    required this.label,
    required this.ratio,
    this.isLast = false,
    required this.theme,
    required this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    final passesAA = ratio >= 4.5;
    final passesAAA = ratio >= 7.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const Spacer(),
          Text(
            '${ratio.toStringAsFixed(2)}:1',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label: passesAAA
                ? 'Passes WCAG AAA'
                : passesAA
                ? 'Passes WCAG AA'
                : 'Fails WCAG',
            child: _Badge(
              text: passesAAA
                  ? 'AAA'
                  : passesAA
                  ? 'AA'
                  : 'FAIL',
              color: passesAA ? overlay.successColor : theme.colorScheme.error,
              textColor: passesAA ? Colors.white : theme.colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _Badge({
    required this.text,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ExportChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ExportChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
