import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/customer.dart';
import '../services/measurement_service.dart';
import '../widgets/measurement_form.dart';
import '../config/app_localizations.dart';

class AddMeasurementScreen extends StatefulWidget {
  const AddMeasurementScreen({super.key});

  @override
  State<AddMeasurementScreen> createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends State<AddMeasurementScreen> {
  Customer? _customer;
  String _garmentType = GarmentType.shirt;
  final _priceController = TextEditingController();
  final _advanceController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _deliveryDate;
  Map<String, dynamic> _measurements = {};
  bool _loading = false;

  File? _designImage;
  String? _designImageUrl;
  bool _uploading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _customer ??= ModalRoute.of(context)?.settings.arguments as Customer?;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _advanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _deliveryDate = date);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1024);
    if (picked != null) {
      setState(() => _designImage = File(picked.path));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_customer == null) return;

    setState(() => _loading = true);

    try {
      if (_designImage != null) {
        setState(() => _uploading = true);
        _designImageUrl = await MeasurementService.uploadImage(_designImage!);
        setState(() => _uploading = false);
      }

      await MeasurementService.createMeasurement(
        customerId: _customer!.id,
        garmentType: _garmentType,
        measurements: _measurements,
        price: _priceController.text.trim().isNotEmpty
            ? double.tryParse(_priceController.text.trim())
            : null,
        advance: _advanceController.text.trim().isNotEmpty
            ? double.tryParse(_advanceController.text.trim())
            : null,
        deliveryDate: _deliveryDate,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        designImage: _designImageUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Measurement added successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add measurement: $e'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (_customer == null) {
      return Scaffold(
        appBar: AppBar(title: Text(loc?.translate('add_measurement') ?? 'Add Measurement')),
        body: Center(child: Text(loc?.translate('no_customer_data') ?? 'No customer data')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(loc?.translate('add_measurement') ?? 'Add Measurement')),
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _customer!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _customer!.phone,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              loc?.translate('garment_type') ?? 'Garment Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: GarmentType.all.map((type) {
                  final selected = _garmentType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(GarmentType.label(type)),
                      selected: selected,
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) {
                        setState(() => _garmentType = type);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            MeasurementFormWidget(
              key: ValueKey(_garmentType),
              garmentType: _garmentType,
              onChanged: (values) {
                _measurements = values;
              },
            ),
            const SizedBox(height: 20),

            // Design Image
            Text(
              loc?.translate('design_image_optional') ?? 'Design Image (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65).withValues(alpha: 0.3), style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.withValues(alpha: 0.05),
                ),
                child: _designImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _designImage!,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _designImage = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Icon(Icons.image_outlined, size: 40, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)),
                          const SizedBox(height: 8),
                           Text(loc?.translate('tap_to_add_design_image') ?? 'Tap to add design image', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontWeight: FontWeight.w500)),
                          Text(loc?.translate('camera_or_gallery') ?? 'Camera or Gallery', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 12)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            const Divider(),
            const SizedBox(height: 12),
            Text(
              loc?.translate('order_details') ?? 'Order Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '${loc?.translate('price') ?? 'Price'} (₹)',
                      prefixIcon: const Icon(Icons.currency_rupee),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _advanceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '${loc?.translate('advance') ?? 'Advance'} (₹)',
                      prefixIcon: const Icon(Icons.payments_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: loc?.translate('delivery_date') ?? 'Delivery Date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon:
                      _deliveryDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () =>
                                  setState(() => _deliveryDate = null),
                            )
                          : null,
                ),
                child: Text(
                  _deliveryDate != null
                      ? DateFormat('dd MMM yyyy').format(_deliveryDate!)
                      : loc?.translate('select_delivery_date') ?? 'Select delivery date',
                  style: TextStyle(
                    color: _deliveryDate != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: loc?.translate('notes') ?? 'Notes',
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_loading || _uploading) ? null : _save,
                child: _loading || _uploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(loc?.translate('save_measurement') ?? 'Save Measurement'),
              ),
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
     ),
    );
  }
}
