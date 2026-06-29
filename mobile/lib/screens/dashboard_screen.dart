import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/app_localizations.dart';
import '../models/customer.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../services/customer_service.dart';
import '../services/measurement_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/stats_card.dart';
import '../widgets/customer_card.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/glass_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  Map<String, dynamic> _stats = {};
  List<Customer> _recentCustomers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final stats = await MeasurementService.getDashboardStats();
      final customers = await CustomerService.getCustomers();
      setState(() {
        _stats = stats;
        _recentCustomers = customers.take(5).toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  Widget _buildDashboardSkeleton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;
    final childAspectRatio = screenWidth > 600 ? 1.6 : 1.35;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(height: 80, width: double.infinity, borderRadius: 16),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
            children: const [
              SkeletonLoader(height: 100, width: double.infinity, borderRadius: 16),
              SkeletonLoader(height: 100, width: double.infinity, borderRadius: 16),
              SkeletonLoader(height: 100, width: double.infinity, borderRadius: 16),
              SkeletonLoader(height: 100, width: double.infinity, borderRadius: 16),
            ],
          ),
          const SizedBox(height: 24),
          const SkeletonLoader(height: 20, width: 150, borderRadius: 6),
          const SizedBox(height: 12),
          const SkeletonLoader(height: 72, width: double.infinity, borderRadius: 16),
          const SizedBox(height: 10),
          const SkeletonLoader(height: 72, width: double.infinity, borderRadius: 16),
          const SizedBox(height: 10),
          const SkeletonLoader(height: 72, width: double.infinity, borderRadius: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc?.translate('dashboard') ?? 'Dashboard')),
      drawer: const AppDrawer(),
      body: _loading
          ? _buildDashboardSkeleton()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer2<AuthProvider, ShopProvider>(
                      builder: (ctx, auth, shop, _) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [const Color(0xFF1E293B), const Color(0xFF334155)]
                                  : [AppTheme.primary, AppTheme.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? Colors.black : AppTheme.primary)
                                    .withValues(alpha: 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              backgroundImage: shop.logoPath.isNotEmpty ? FileImage(File(shop.logoPath)) : null,
                              child: shop.logoPath.isEmpty
                                  ? Text(auth.user?.name.isNotEmpty == true ? auth.user!.name[0].toUpperCase() : 'T',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${loc?.translate('welcome') ?? 'Welcome'}, ${auth.user?.name ?? 'Tailor'}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                  Text(shop.shopName.isNotEmpty ? shop.shopName : 'StitchCraft', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(Icons.dashboard_outlined, color: Colors.white.withValues(alpha: 0.5), size: 28),
                          ],
                        ),
                      );
                    },
                    ),
                    const SizedBox(height: 20),
                    Builder(
                      builder: (context) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final crossAxisCount = screenWidth > 600 ? 4 : 2;
                        final childAspectRatio = screenWidth > 600 ? 1.6 : 1.35;
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: childAspectRatio,
                          children: [
                            StatsCard(
                              title: loc?.translate('total_customers') ?? 'Total Customers',
                              value: '${_stats['totalCustomers'] ?? 0}',
                              icon: Icons.people_outline,
                              color: AppTheme.primary,
                            ),
                            StatsCard(
                              title: loc?.translate('this_month') ?? 'This Month',
                              value: '${_stats['measurementsThisMonth'] ?? 0}',
                              icon: Icons.content_cut,
                              color: AppTheme.accent,
                            ),
                            StatsCard(
                              title: loc?.translate('pending') ?? 'Pending',
                              value: '${_stats['pendingOrders'] ?? 0}',
                              icon: Icons.pending_outlined,
                              color: AppTheme.warning,
                            ),
                            StatsCard(
                              title: loc?.translate('ready') ?? 'Ready',
                              value: '${_stats['readyForDelivery'] ?? 0}',
                              icon: Icons.check_circle_outline,
                              color: AppTheme.success,
                            ),
                          ],
                        );
                      }
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc?.translate('recent_customers') ?? 'Recent Customers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/customers');
                          },
                          child: Text(loc?.translate('view_all') ?? 'View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                     if (_recentCustomers.isEmpty)
                      GlassCard(
                        padding: const EdgeInsets.all(32),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.people_outline,
                                  size: 48, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Text(
                                loc?.translate('no_customers_yet') ?? 'No customers yet',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                loc?.translate('add_first_customer') ?? 'Add your first customer to get started',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._recentCustomers.map(
                        (c) => CustomerCard(
                          customer: c,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/customer-detail',
                              arguments: c,
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 104),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accent,
        onPressed: () {
          Navigator.pushNamed(context, '/add-customer');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
