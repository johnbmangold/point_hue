import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:point_hue/features/color/color_model.dart';
import 'package:point_hue/features/color/color_repository.dart';

class ColorDetailScreen extends ConsumerWidget {
  final String hex;
  const ColorDetailScreen({super.key, required this.hex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find the color in library or history
    final library = ref.watch(colorLibraryProvider).value ?? [];
    final history = ref.watch(colorHistoryProvider).value ?? [];
    final allColors = [...library, ...history];

    final colorModel = allColors.firstWhere(
      (c) => c.hex.replaceAll('#', '') == hex,
      orElse: () => ColorModel(hex: '#$hex', r: 0, g: 0, b: 0, name: 'Unknown'),
    );

    final color = colorModel.toColor();
    final contrastWithWhite = _calculateContrast(color, Colors.white);
    final contrastWithBlack = _calculateContrast(color, Colors.black);

    return Scaffold(
      appBar: AppBar(title: Text(colorModel.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: Text(
                  colorModel.hex,
                  style: TextStyle(
                    color: contrastWithWhite > contrastWithBlack
                        ? Colors.white
                        : Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
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
            _Section(
              title: 'Export',
              child: Wrap(
                spacing: 12,
                children: [
                  _ExportButton(
                    label: 'CSS',
                    value: 'color: ${colorModel.hex};',
                  ),
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

class _ContrastItem extends StatelessWidget {
  final String label;
  final double ratio;
  const _ContrastItem({required this.label, required this.ratio});

  @override
  Widget build(BuildContext context) {
    final passAA = ratio >= 4.5;
    final passAAA = ratio >= 7.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: pass
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: pass ? Colors.green : Colors.red,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Copied $label to clipboard')));
      },
      child: Text(label),
    );
  }
}
