import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/app_localizations.dart';
import '../providers/shop_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstinController = TextEditingController();
  final _termsController = TextEditingController();
  
  File? _logoFile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      _shopNameController.text = shopProvider.shopName;
      _ownerNameController.text = shopProvider.ownerName;
      _phoneController.text = shopProvider.phone;
      _addressController.text = shopProvider.address;
      _gstinController.text = shopProvider.gstin;
      _termsController.text = shopProvider.terms;
      
      if (shopProvider.logoPath.isNotEmpty) {
        _logoFile = File(shopProvider.logoPath);
      }
      
      setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512);
    if (picked != null) {
      setState(() => _logoFile = File(picked.path));
    }
  }

  void _showImageSourceDialog() {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(loc?.translate('take_photo') ?? 'Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(loc?.translate('choose_from_gallery') ?? 'Choose from Gallery'),
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
    if (!_formKey.currentState!.validate()) return;

    final loc = AppLocalizations.of(context);
    setState(() => _loading = true);

    try {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      await shopProvider.updateShopInfo(
        shopName: _shopNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        gstin: _gstinController.text.trim(),
        logoPath: _logoFile?.path ?? '',
        terms: _termsController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc?.translate('settings_saved') ?? 'Settings saved successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('shop_settings') ?? 'Shop Settings'),
      ),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Shop Logo Selector
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: CircleAvatar(
                              radius: 56,
                              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                              backgroundImage: _logoFile != null ? FileImage(_logoFile!) : null,
                              child: _logoFile == null
                                  ? Icon(Icons.storefront, size: 56, color: AppTheme.primary)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc?.translate('select_logo') ?? 'Select Shop Logo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info Form Cards
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Shop Name
                          TextFormField(
                            controller: _shopNameController,
                            decoration: InputDecoration(
                              labelText: loc?.translate('shop_name') ?? 'Shop Name',
                              prefixIcon: const Icon(Icons.store),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Shop name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Owner Name
                          TextFormField(
                            controller: _ownerNameController,
                            decoration: InputDecoration(
                              labelText: loc?.translate('owner_name') ?? 'Owner Name',
                              prefixIcon: const Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Contact Phone
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: loc?.translate('shop_phone') ?? 'Shop Phone',
                              prefixIcon: const Icon(Icons.phone),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Address
                          TextFormField(
                            controller: _addressController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: loc?.translate('shop_address') ?? 'Shop Address',
                              prefixIcon: const Icon(Icons.location_on),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // GSTIN / Tax ID
                          TextFormField(
                            controller: _gstinController,
                            decoration: InputDecoration(
                              labelText: loc?.translate('gstin') ?? 'GSTIN / Tax ID',
                              prefixIcon: const Icon(Icons.receipt_long),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Billing Terms & Conditions
                          TextFormField(
                            controller: _termsController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: loc?.translate('terms_conditions') ?? 'Terms & Conditions',
                              prefixIcon: const Icon(Icons.gavel),
                              hintText: 'e.g. No cash refund, Deliveries valid up to 30 days',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        child: Text(loc?.translate('save_settings') ?? 'Save Settings'),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
    );
  }
}
