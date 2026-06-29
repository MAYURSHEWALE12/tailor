import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../config/app_localizations.dart';

class MeasurementFormWidget extends StatefulWidget {
  final String garmentType;
  final Map<String, dynamic> initialValues;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const MeasurementFormWidget({
    super.key,
    required this.garmentType,
    this.initialValues = const {},
    required this.onChanged,
  });

  @override
  State<MeasurementFormWidget> createState() => _MeasurementFormWidgetState();
}

class _MeasurementFormWidgetState extends State<MeasurementFormWidget> {
  bool _useInches = true;
  late Map<String, dynamic> _values;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _values = Map.from(widget.initialValues);
    final fields =
        MeasurementFields.byGarment[widget.garmentType] ?? [];
    for (final field in fields) {
      _controllers[field] = TextEditingController(
        text: _values[field]?.toString() ?? '',
      );
      _controllers[field]!.addListener(_updateValues);
    }
  }

  @override
  void didUpdateWidget(MeasurementFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.garmentType != widget.garmentType) {
      _values = Map.from(widget.initialValues);
      for (final entry in _controllers.entries) {
        entry.value.removeListener(_updateValues);
        entry.value.dispose();
      }
      _controllers.clear();
      final fields =
          MeasurementFields.byGarment[widget.garmentType] ?? [];
      for (final field in fields) {
        _controllers[field] = TextEditingController(
          text: _values[field]?.toString() ?? '',
        );
        _controllers[field]!.addListener(_updateValues);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.removeListener(_updateValues);
      controller.dispose();
    }
    super.dispose();
  }

  void _updateValues() {
    for (final entry in _controllers.entries) {
      final text = entry.value.text.trim();
      if (text.isNotEmpty) {
        final parsed = double.tryParse(text);
        if (parsed != null) {
          _values[entry.key] = parsed;
        }
      }
    }
    widget.onChanged(Map.from(_values));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final fields =
        MeasurementFields.byGarment[widget.garmentType] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${loc?.translate(widget.garmentType) ?? GarmentType.label(widget.garmentType)} ${loc?.translate('measurements') ?? 'Measurements'}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            ToggleButtons(
              isSelected: [_useInches, !_useInches],
              onPressed: (index) => setState(() {
                _useInches = index == 0;
                for (final entry in _controllers.entries) {
                  final value = _values[entry.key];
                  if (value is num) {
                    final converted = _useInches
                        ? value / 2.54
                        : value * 2.54;
                    entry.value.text = converted.toStringAsFixed(1);
                  }
                }
              }),
              borderRadius: BorderRadius.circular(8),
              constraints: const BoxConstraints(minWidth: 48, minHeight: 32),
              textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              children: const [Text('in'), Text('cm')],
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...fields.map((field) {
          final labelKey = 'field_$field';
          final label = loc?.translate(labelKey) ?? MeasurementFields.labels[field] ?? field;
          final unit = _useInches ? '"' : 'cm';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _controllers[field],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        suffixText: unit,
                        suffixStyle: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
