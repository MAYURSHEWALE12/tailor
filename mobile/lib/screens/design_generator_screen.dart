import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/customer.dart';
import '../models/measurement.dart';

class DesignGeneratorScreen extends StatefulWidget {
  const DesignGeneratorScreen({super.key});

  @override
  State<DesignGeneratorScreen> createState() => _DesignGeneratorScreenState();
}

class _DesignGeneratorScreenState extends State<DesignGeneratorScreen> {
  Customer? _customer;
  Measurement? _measurement;
  String _selectedStyle = StyleOptions.styles.first;
  String _selectedColor = StyleOptions.colors.values.first;
  String _prompt = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_customer == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _customer = args?['customer'] as Customer?;
      _measurement = args?['measurement'] as Measurement?;
      _generatePrompt();
    }
  }

  void _generatePrompt() {
    final m = _measurement;
    if (m == null) {
      setState(() => _prompt = 'Please select a measurement first.');
      return;
    }

    final colorName = StyleOptions.colors.entries
        .firstWhere(
          (e) => e.value == _selectedColor,
          orElse: () => const MapEntry('Navy Blue', '#1A3A5C'),
        )
        .key;

    final meas = m.measurements;
    final fields =
        MeasurementFields.byGarment[m.garmentType] ?? [];

    final lines = <String>[
      'Professional ${_selectedStyle.toLowerCase()} ${m.garmentType} design for men',
      'Color: $colorName',
      'Style: $_selectedStyle fit with clean elegant finish',
      'Measurements:',
    ];

    for (final f in fields) {
      if (meas[f] != null && meas[f] != '') {
        final label = MeasurementFields.labels[f] ?? f;
        lines.add('- $label: ${meas[f]}"');
      }
    }

    lines.add(
      'High quality, photorealistic product shot on mannequin, professional studio lighting, clean white background, sharp details, fashion catalog quality, 8K, hyperrealistic',
    );

    setState(() => _prompt = lines.join('\n'));
  }

  void _copyPrompt() {
    Clipboard.setData(ClipboardData(text: _prompt));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prompt copied to clipboard!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Design Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_customer != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            AppTheme.primary.withValues(alpha: 0.1),
                        child: Text(
                          _customer!.initials,
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Design Generator',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${_customer!.name} — Generating for $_selectedStyle style',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Style Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: StyleOptions.styles.map((style) {
                          final selected = _selectedStyle == style;
                          return ChoiceChip(
                            label: Text(style),
                            selected: selected,
                            selectedColor: AppTheme.primary,
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            onSelected: (_) {
                              setState(() => _selectedStyle = style);
                              _generatePrompt();
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Color Palette',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: StyleOptions.colors.entries.map((entry) {
                          final isSelected = _selectedColor == entry.value;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedColor = entry.value);
                              _generatePrompt();
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(
                                    int.parse(
                                        entry.value.replaceFirst('#', '0xFF'))),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : Colors.grey[300]!,
                                  width: isSelected ? 3 : 1,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome,
                                color: AppTheme.accent, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Generated Prompt',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _copyPrompt,
                          icon: const Icon(Icons.copy, size: 16),
                          label: Text('Copy'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 250,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _prompt,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use With AI Tools',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Copy the prompt above and use it with your preferred AI image generator.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ToolChip(
                          name: 'DALL-E 3',
                          url: 'https://chat.openai.com',
                        ),
                        _ToolChip(
                          name: 'Midjourney',
                          url: 'https://www.midjourney.com',
                        ),
                        _ToolChip(
                          name: 'Stable Diffusion',
                          url: 'https://stability.ai',
                        ),
                        _ToolChip(
                          name: 'Leonardo AI',
                          url: 'https://leonardo.ai',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  final String name;
  final String url;

  const _ToolChip({required this.name, required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // In a real app, use url_launcher
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $name...'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.open_in_new, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
          ],
        ),
      ),
    );
  }
}
