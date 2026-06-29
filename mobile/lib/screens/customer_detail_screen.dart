import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../config/api_config.dart';
import '../config/app_localizations.dart';
import '../models/customer.dart';
import '../models/measurement.dart';
import '../services/measurement_service.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/glass_card.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  Customer? _customer;
  List<Measurement> _measurements = [];
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_customer == null) {
      _customer = ModalRoute.of(context)?.settings.arguments as Customer?;
      if (_customer != null) {
        _loadMeasurements();
      }
    }
  }

  Future<void> _loadMeasurements() async {
    if (_customer == null) return;
    setState(() => _loading = true);
    try {
      final measurements =
          await MeasurementService.getCustomerMeasurements(_customer!.id);
      setState(() {
        _measurements = measurements;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load measurements: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  void _shareWhatsApp() {
    if (_customer == null) return;
    final url =
        'https://wa.me/91${_customer!.phone}?text=${Uri.encodeComponent("Hello ${_customer!.name}, this is from StitchCraft.")}';
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _updateOrderStatus(
      Measurement measurement, String status) async {
    try {
      await MeasurementService.updateMeasurement(
        measurement.id,
        orderStatus: status,
      );
      await _loadMeasurements();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${OrderStatus.label(status)}'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  Future<void> _deleteMeasurement(Measurement measurement) async {
    final loc = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc?.translate('delete_measurement') ?? 'Delete Measurement'),
        content: Text(
            loc?.translate('delete_measurement_confirm') ?? 'Are you sure? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc?.translate('cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc?.translate('delete') ?? 'Delete',
                style: const TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await MeasurementService.deleteMeasurement(measurement.id);
        await _loadMeasurements();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc?.translate('delete_confirm_msg') ?? 'Measurement deleted'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${loc?.translate('failed_to_delete') ?? 'Failed to delete: '}$e'),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      }
    }
  }

  Future<void> _addPayment(Measurement measurement) async {
    final amountCtl = TextEditingController();
    final notesCtl = TextEditingController();
    String method = 'cash';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Add Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: method,
                decoration: const InputDecoration(
                  labelText: 'Method',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'online', child: Text('Online')),
                  DropdownMenuItem(value: 'upi', child: Text('UPI')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setDlgState(() => method = v ?? 'cash'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtl,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtl.text.trim());
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Enter a valid amount')),
                  );
                  return;
                }
                Navigator.pop(ctx, true);
                try {
                  await MeasurementService.addPayment(
                    measurement.id,
                    amount: amount,
                    method: method,
                    notes: notesCtl.text.trim().isNotEmpty ? notesCtl.text.trim() : null,
                  );
                  await _loadMeasurements();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment added'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add payment: $e'),
                        backgroundColor: AppTheme.danger,
                      ),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warning;
      case 'cutting':
        return Colors.blue;
      case 'stitching':
        return Colors.purple;
      case 'ready':
        return AppTheme.success;
      case 'delivered':
        return AppTheme.textSecondary;
      default:
        return AppTheme.textSecondary;
    }
  }

  Widget _buildMeasurementCardSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoader(height: 20, width: 100, borderRadius: 4),
              SkeletonLoader(height: 20, width: 70, borderRadius: 10),
            ],
          ),
          const SizedBox(height: 8),
          const SkeletonLoader(height: 14, width: 150, borderRadius: 4),
          const SizedBox(height: 12),
          const SkeletonLoader(height: 120, width: double.infinity, borderRadius: 12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoader(height: 16, width: 60, borderRadius: 4),
              SkeletonLoader(height: 14, width: 80, borderRadius: 4),
              SkeletonLoader(height: 14, width: 80, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              SkeletonLoader(height: 28, width: 70, borderRadius: 8),
              SizedBox(width: 8),
              SkeletonLoader(height: 28, width: 50, borderRadius: 8),
              SizedBox(width: 8),
              SkeletonLoader(height: 28, width: 70, borderRadius: 8),
              SizedBox(width: 8),
              SkeletonLoader(height: 28, width: 60, borderRadius: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(height: 100, width: double.infinity, borderRadius: 16),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoader(height: 20, width: 140, borderRadius: 6),
              SkeletonLoader(height: 36, width: 80, borderRadius: 18),
            ],
          ),
          const SizedBox(height: 12),
          _buildMeasurementCardSkeleton(),
          const SizedBox(height: 12),
          _buildMeasurementCardSkeleton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (_customer == null) {
      return Scaffold(
        appBar: AppBar(title: Text(loc?.translate('customer_details') ?? 'Customer Detail')),
        body: Center(child: Text(loc?.translate('no_customer_data') ?? 'No customer data')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_customer!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareWhatsApp,
            tooltip: 'Share via WhatsApp',
          ),
        ],
      ),
      body: _loading
          ? _buildDetailSkeleton()
          : RefreshIndicator(
              onRefresh: _loadMeasurements,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            child: Text(
                              _customer!.initials,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _customer!.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.phone_outlined,
                                        size: 14,
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _customer!.phone,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_customer!.address != null &&
                                    _customer!.address!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    _customer!.address!,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc?.translate('measurements') ?? 'Measurements',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              '/add-measurement',
                              arguments: _customer,
                            );
                            _loadMeasurements();
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(loc?.translate('add') ?? 'Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_measurements.isEmpty)
                      GlassCard(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            loc?.translate('no_measurements') ?? 'No measurements yet',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._measurements.map(
                        (m) => GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.content_cut,
                                            size: 20,
                                            color: AppTheme.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          loc?.translate(m.garmentType) ?? GarmentType.label(m.garmentType),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _statusColor(m.orderStatus)
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        loc?.translate(m.orderStatus).toUpperCase() ?? OrderStatus.label(m.orderStatus).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              _statusColor(m.orderStatus),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat('dd MMM yyyy, hh:mm a')
                                      .format(m.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                  ),
                                ),
                                if (m.designImage != null && m.designImage!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (ctx) => Dialog(
                                        child: InteractiveViewer(
                                          child: Image.network(
                                            ApiConfig.getImageUrl(m.designImage!),
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        ApiConfig.getImageUrl(m.designImage!),
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                      ),
                                    ),
                                  ),
                                ],
                                if (m.price != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '₹${m.price!.toStringAsFixed(0)}',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                                        ),
                                      ),
                                      Text(
                                        '${loc?.translate('paid') ?? 'Paid'}: ₹${m.totalPaid.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.success),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${loc?.translate('balance') ?? 'Bal'}: ₹${m.balance.toStringAsFixed(0)}',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: m.balance > 0 ? AppTheme.danger : AppTheme.success),
                                      ),
                                    ],
                                  ),
                                ],

                                // Payment History
                                if (m.payments.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(loc?.translate('payments') ?? 'Payments', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
                                        const SizedBox(height: 4),
                                        ...m.payments.map((p) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Row(
                                            children: [
                                              Text(DateFormat('dd/MM').format(p.date), style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
                                              const SizedBox(width: 8),
                                              Text(p.method, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
                                              const Spacer(),
                                              Text('+₹${p.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.success)),
                                            ],
                                          ),
                                        )),
                                      ],
                                    ),
                                  ),
                                ],

                                Container(
                                  margin: const EdgeInsets.only(top: 14),
                                  padding: const EdgeInsets.only(top: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : Colors.black.withValues(alpha: 0.05),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        child: _ActionButton(
                                          label: loc?.translate('payment') ?? 'Payment',
                                          icon: Icons.payments_outlined,
                                          color: AppTheme.success,
                                          onTap: () => _addPayment(m),
                                        ),
                                      ),
                                      Expanded(
                                        child: _ActionButton(
                                          label: loc?.translate('pdf') ?? 'PDF',
                                          icon: Icons.picture_as_pdf,
                                          color: AppTheme.danger,
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/measurement-card',
                                              arguments: {
                                                'customer': _customer,
                                                'measurement': m,
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: _ActionButton(
                                          label: loc?.translate('design') ?? 'Design',
                                          icon: Icons.auto_awesome,
                                          color: AppTheme.accent,
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/design-generator',
                                              arguments: {
                                                'customer': _customer,
                                                'measurement': m,
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: PopupMenuButton<String>(
                                          onSelected: (status) =>
                                              _updateOrderStatus(m, status),
                                          itemBuilder: (context) =>
                                              OrderStatus.all
                                                  .where(
                                                      (s) => s != m.orderStatus)
                                                  .map(
                                                    (s) => PopupMenuItem(
                                                      value: s,
                                                      child: Text(
                                                          '${loc?.translate('set_as') ?? 'Set as'} ${loc?.translate(s) ?? OrderStatus.label(s)}'),
                                                    ),
                                                  )
                                                  .toList(),
                                          child: _ActionButton(
                                            label: loc?.translate('status') ?? 'Status',
                                            icon: Icons.swap_horiz,
                                            color: AppTheme.primaryLight,
                                            onTap: null,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: _ActionButton(
                                          label: loc?.translate('delete') ?? 'Delete',
                                          icon: Icons.delete_outline,
                                          color: AppTheme.danger,
                                          onTap: () =>
                                              _deleteMeasurement(m),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 104),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
