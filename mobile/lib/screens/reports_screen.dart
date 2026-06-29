import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../services/report_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/loading_widget.dart';
import '../widgets/glass_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedTab = 0;
  bool _loading = true;

  Map<String, dynamic> _revenueData = {};
  List<dynamic> _orderStatusData = [];
  List<dynamic> _garmentData = [];
  Map<String, dynamic> _pendingDues = {};
  Map<String, dynamic> _deliveryData = {};
  List<dynamic> _topCustomers = [];

  DateTime? _startDate;
  DateTime? _endDate;

  final _tabs = ['Revenue', 'Status', 'Garments', 'Dues', 'Delivery', 'Top'];

  static const _statusColors = {
    'pending': AppTheme.warning,
    'cutting': Colors.blue,
    'stitching': Colors.purple,
    'ready': AppTheme.success,
    'delivered': Colors.grey,
  };

  static const _garmentLabels = {
    'shirt': 'Shirt',
    'pant': 'Pant',
    'kurta': 'Kurta',
    'blouse': 'Blouse',
    'sadra': 'Sadra',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final params = <String, String>{};
      if (_startDate != null) params['startDate'] = _startDate!.toIso8601String().split('T')[0];
      if (_endDate != null) params['endDate'] = _endDate!.toIso8601String().split('T')[0];

      final results = await Future.wait([
        ReportService.getRevenueReport(startDate: params['startDate'], endDate: params['endDate']),
        ReportService.getOrderStatusReport(),
        ReportService.getGarmentWiseReport(startDate: params['startDate'], endDate: params['endDate']),
        ReportService.getPendingDues(),
        ReportService.getDeliverySchedule(7),
        ReportService.getTopCustomers(),
      ]);

      setState(() {
        _revenueData = results[0] as Map<String, dynamic>;
        _orderStatusData = results[1] as List<dynamic>;
        _garmentData = results[2] as List<dynamic>;
        _pendingDues = results[3] as Map<String, dynamic>;
        _deliveryData = results[4] as Map<String, dynamic>;
        _topCustomers = results[5] as List<dynamic>;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reports: $e'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  String _statusLabel(String s) => s[0].toUpperCase() + s.substring(1);

  String _garmentLabel(String g) => _garmentLabels[g] ?? g;

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  Widget _buildTab() {
    switch (_selectedTab) {
      case 0:
        return _buildRevenueTab();
      case 1:
        return _buildOrderStatusTab();
      case 2:
        return _buildGarmentTab();
      case 3:
        return _buildPendingDuesTab();
      case 4:
        return _buildDeliveryTab();
      case 5:
        return _buildTopCustomersTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildRevenueTab() {
    final summary = _revenueData['summary'] as Map<String, dynamic>?;
    final daily = _revenueData['daily'] as List<dynamic>?;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (summary != null) ...[
          const SizedBox(height: 4),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _statBox('Total Revenue', '₹${_fmt(summary['totalRevenue'])}', AppTheme.primary),
                  const SizedBox(width: 8),
                  _statBox('Advance', '₹${_fmt(summary['totalAdvance'])}', AppTheme.accent),
                ],
              ),
            ),
          ),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _statBox('Pending Balance', '₹${_fmt(summary['totalBalance'])}', AppTheme.danger),
                  const SizedBox(width: 8),
                  _statBox('Orders', '${summary['orderCount'] ?? 0}', Theme.of(context).colorScheme.onSurface),
                ],
              ),
            ),
          ),
        ],
        if (daily != null && daily.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Daily Revenue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          ),
          GlassCard(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: daily.take(30).map<Widget>((d) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(d['_id'] ?? '', style: TextStyle(fontSize: 12))),
                      Expanded(child: Text('₹${_fmt(d['revenue'])}', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary))),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
        if (daily == null || daily.isEmpty) ...[
          const SizedBox(height: 32),
          Center(child: Text('No data for selected period', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65)))),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
          ],
        ),
      ),
    );
  }

  String _fmt(dynamic val) {
    if (val == null) return '0';
    final n = (val is num) ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
    return NumberFormat('#,##,##0').format(n);
  }

  Widget _buildOrderStatusTab() {
    if (_orderStatusData.isEmpty) {
      return Center(child: Text('No data', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _orderStatusData.map<Widget>((item) {
                final status = item['status'] as String;
                final count = item['count'] as int;
                final color = _statusColors[status] ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_statusLabel(status), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                      Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGarmentTab() {
    if (_garmentData.isEmpty) {
      return Center(child: Text('No data', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: const [
                    Expanded(child: Text('Garment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    SizedBox(width: 60, child: Text('Orders', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    SizedBox(width: 100, child: Text('Revenue', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  ],
                ),
                const Divider(),
                ..._garmentData.map((item) {
                  final type = item['garmentType'] as String;
                  final count = item['count'] as int;
                  final rev = (item['revenue'] as num?)?.toDouble() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(_garmentLabel(type), style: TextStyle(fontSize: 14))),
                        SizedBox(width: 60, child: Text('$count', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(width: 100, child: Text('₹${_fmt(rev)}', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingDuesTab() {
    final orders = _pendingDues['orders'] as List<dynamic>?;
    final totalDues = (_pendingDues['totalDues'] as num?)?.toDouble() ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          color: AppTheme.danger.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Total Pending Dues', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 13)),
                const SizedBox(height: 4),
                Text('₹${_fmt(totalDues)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.danger)),
              ],
            ),
          ),
        ),
        if (orders != null && orders.isNotEmpty) ...[
          const SizedBox(height: 16),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: orders.map<Widget>((o) {
                  final name = o['customerName'] ?? 'Unknown';
                  final phone = o['customerPhone'] ?? '';
                  final garment = _garmentLabel(o['garmentType'] ?? '');
                  final balance = (o['balance'] as num?)?.toDouble() ?? 0;
                  final price = (o['price'] as num?)?.toDouble() ?? 0;
                  final advance = (o['advancePaid'] as num?)?.toDouble() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                            Text('₹${_fmt(balance)}', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.danger, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('$phone · $garment · ₹${_fmt(price)} / ₹${_fmt(advance)}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
                        const Divider(height: 12),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
        if (orders == null || orders.isEmpty) ...[
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Icon(Icons.check_circle, size: 64, color: AppTheme.success),
                const SizedBox(height: 12),
                Text('All dues cleared!', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDeliveryTab() {
    final upcoming = _deliveryData['upcoming'] as List<dynamic>?;
    final overdue = _deliveryData['overdue'] as List<dynamic>?;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          color: Colors.blue.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Upcoming (7 days)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                ]),
                const SizedBox(height: 8),
                if (upcoming != null && upcoming.isNotEmpty)
                  ...upcoming.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['customer']?['name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text('${item['customer']?['phone'] ?? ''} · ${_garmentLabel(item['garmentType'] ?? '')}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
                            ],
                          ),
                        ),
                        Text(_formatDate(item['deliveryDate']), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ))
                else
                  Text('No upcoming deliveries', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          color: AppTheme.danger.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.error_outline, size: 18, color: AppTheme.danger),
                  const SizedBox(width: 8),
                  Text('Overdue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                ]),
                const SizedBox(height: 8),
                if (overdue != null && overdue.isNotEmpty)
                  ...overdue.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['customer']?['name'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text('${item['customer']?['phone'] ?? ''} · ${_garmentLabel(item['garmentType'] ?? '')}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
                            ],
                          ),
                        ),
                        Text(_formatDate(item['deliveryDate']), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.danger)),
                      ],
                    ),
                  ))
                else
                  Row(children: [
                    Icon(Icons.check_circle, size: 18, color: AppTheme.success),
                    const SizedBox(width: 8),
                    Text('No overdue deliveries', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
                  ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopCustomersTab() {
    if (_topCustomers.isEmpty) {
      return Center(child: Text('No data', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: const [
                    SizedBox(width: 28, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(child: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    SizedBox(width: 36, child: Text('Ord', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    SizedBox(width: 80, child: Text('Spent', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  ],
                ),
                const Divider(),
                ..._topCustomers.asMap().entries.map((entry) {
                  final i = entry.key;
                  final c = entry.value;
                  final name = c['customerName'] ?? 'Unknown';
                  final phone = c['customerPhone'] ?? '';
                  final orders = c['orderCount'] ?? 0;
                  final spent = (c['totalSpent'] as num?)?.toDouble() ?? 0;
                  final isEven = i.isEven;
                  return Container(
                    color: isEven ? Colors.grey.withValues(alpha: 0.05) : null,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(width: 28, child: Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65), fontSize: 13))),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                              Text(phone, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
                            ],
                          ),
                        ),
                        SizedBox(width: 36, child: Text('$orders', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        SizedBox(width: 80, child: Text('₹${_fmt(spent)}', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 13))),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
            tooltip: 'Filter by date',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: _tabs.asMap().entries.map((entry) {
                  final i = entry.key;
                  final tab = entry.value;
                  final isActive = _selectedTab == i;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(tab, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? Colors.white : null)),
                      selected: isActive,
                      selectedColor: AppTheme.primary,
                      onSelected: (_) => setState(() => _selectedTab = i),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (_startDate != null && _endDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Chip(
                    label: Text('${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}', style: TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() { _startDate = null; _endDate = null; });
                      _loadData();
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: _loading ? const LoadingWidget(message: 'Loading reports...') : RefreshIndicator(
              onRefresh: _loadData,
              child: _buildTab(),
            ),
          ),
        ],
      ),
    );
  }
}
