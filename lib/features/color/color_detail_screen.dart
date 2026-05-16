import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/features/color/color_repository.dart';

/// Detail screen for a single color, showing values,
/// accessibility info, and export buttons.
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

    return Scaffold(
      appBar: AppBar(title: Text(colorModel.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Color swatch
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Center(
                child: Text(
                  colorModel.hex,
                  style: TextStyle(
                    color: colorModel.contrastForeground,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Color values
            _Section(
              title: 'Color Values',
              child: Column(
                children: [
                  _ValueRow(label: 'HEX', value: colorModel.hex),
                  _ValueRow(label: 'RGB', value: colorModel.rgbString),
                  _ValueRow(label: 'HSL', value: colorModel.hslString),
                  _ValueRow(label: 'HSV', value: colorModel.hsvString),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Accessibility
            _Section(
              title: 'Accessibility (WCAG)',
              child: Column(
                children: [
                  _ContrastItem(label: 'On White', ratio: contrastWithWhite),
                  _ContrastItem(label: 'On Black', ratio: contrastWithBlack),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Export
            _Section(
              title: 'Export',
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _ExportButton(label: 'HEX', value: colorModel.hex),
                  _ExportButton(
                    label: 'CSS',
                    value: 'color: ${colorModel.hex};',
                  ),
                  _ExportButton(label: 'RGB', value: colorModel.rgbString),
                  _ExportButton(label: 'HSL', value: colorModel.hslString),
                  _ExportButton(
                    label: 'Sass',
                    value: '\$color-name: ${colorModel.hex};',
                  ),
                  _ExportButton(
                    label: 'JSON',
                    value: '"color": "${colorModel.hex}"',
                  ),
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
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

/// Displays a labeled color value (e.g. HEX, RGB).
class _ValueRow extends StatelessWidget {
  final String label;
  final String value;

  const _ValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ContrastItem extends StatelessWidget {
  final String label;
  final double ratio;

  const _ContrastItem({required this.label, required this.ratio});

  @override
  Widget build(BuildContext context) {
    final passAA = ratio >= 4.5;
    final passAAA = ratio >= 7.0;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Row(
            children: [
              Text('${ratio.toStringAsFixed(2)}:1'),
              const SizedBox(width: 8),
              _PassBadge(label: 'AA', pass: passAA),
              const SizedBox(width: 4),
              _PassBadge(label: 'AAA', pass: passAAA),
            ],
          ),
        ],
      ),
    );
  }
}

class _PassBadge extends StatelessWidget {
  final String label;
  final bool pass;

  const _PassBadge({required this.label, required this.pass});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = pass ? Colors.green : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final String label;
  final String value;

  const _ExportButton({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied $label to clipboard'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Text(label),
    );
  }
}
