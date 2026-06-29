import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/app_localizations.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/customer_card.dart';
import '../widgets/skeleton_loader.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  bool _loading = true;
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _loading = true);
    try {
      final customers = await CustomerService.getCustomers();
      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc?.translate('failed_to_delete') ?? 'Failed to load: '}$e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _customers.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.phone.contains(query);
      }).toList();
    });
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final loc = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(loc?.translate('delete_customer') ?? 'Delete Customer'),
        content: Text(
          (loc?.translate('delete_confirm_msg') ?? 'Remove customer? This cannot be undone.')
              .replaceAll('{name}', customer.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc?.translate('cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc?.translate('delete') ?? 'Delete', style: const TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await CustomerService.deleteCustomer(customer.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc?.translate('customer_deleted') ?? 'Customer deleted'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
        _loadCustomers();
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

  Widget _buildCustomersSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: 72,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                const SkeletonLoader(height: 48, width: 48, borderRadius: 14),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SkeletonLoader(height: 16, width: 140, borderRadius: 4),
                      SizedBox(height: 8),
                      SkeletonLoader(height: 12, width: 90, borderRadius: 4),
                    ],
                  ),
                ),
                const SkeletonLoader(height: 18, width: 18, borderRadius: 9),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('customers') ?? 'Customers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: loc?.translate('search_hint') ?? 'Search by name or phone...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  filled: false,
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: _loading
          ? _buildCustomersSkeleton()
          : _filteredCustomers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.people_outline, size: 40, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? (loc?.translate('no_customers_yet') ?? 'No customers yet')
                            : (loc?.translate('no_customers_found') ?? 'No customers found'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_searchController.text.isEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          loc?.translate('tap_to_add') ?? 'Tap + to add your first customer',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCustomers,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final c = _filteredCustomers[index];
                      return CustomerCard(
                        customer: c,
                        onTap: () => Navigator.pushNamed(context, '/customer-detail', arguments: c),
                        onDelete: () => _deleteCustomer(c),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accent,
        elevation: 4,
        onPressed: () => Navigator.pushNamed(context, '/add-customer'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
