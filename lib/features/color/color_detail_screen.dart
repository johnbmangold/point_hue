import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/core/theme.dart';
import 'package:point_hue/features/color/color_repository.dart';

/// Screen displaying deep details about a single color,
/// including color spaces and accessibility scores.
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
      (c) => c.hex.replaceAll('#', '') == hex,
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tall Hero Header.
            Hero(
              tag: 'color-${colorModel.hex}',
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        colorModel.name,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
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
                  _InfoCard(
                    title: 'Values',
                    icon: Icons.numbers,
                    theme: theme,
                    children: [
                      _ValueRow(
                        label: 'HEX',
                        value: colorModel.hex,
                        theme: theme,
                      ),
                      _ValueRow(
                        label: 'RGB',
                        value: colorModel.rgbString,
                        theme: theme,
                      ),
                      _ValueRow(
                        label: 'HSL',
                        value: colorModel.hslString,
                        theme: theme,
                      ),
                      _ValueRow(
                        label: 'HSV',
                        value: colorModel.hsvString,
                        isLast: true,
                        theme: theme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                    ],
                  ),
                  const SizedBox(height: 16),
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

  const _ValueRow({
    required this.label,
    required this.value,
    this.isLast = false,
    required this.theme,
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
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
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
