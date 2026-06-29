import '../config/api_config.dart';
import 'api_client.dart';

class ReportService {
  static Future<Map<String, dynamic>> getRevenueReport({
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    final data = await ApiClient.get(
      '${ApiConfig.baseUrl}/reports/revenue',
      queryParams: params.isNotEmpty ? params : null,
    );
    return data as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getOrderStatusReport() async {
    final data = await ApiClient.get('${ApiConfig.baseUrl}/reports/order-status');
    return data as List<dynamic>;
  }

  static Future<List<dynamic>> getGarmentWiseReport({
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    final data = await ApiClient.get(
      '${ApiConfig.baseUrl}/reports/garment-wise',
      queryParams: params.isNotEmpty ? params : null,
    );
    return data as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getPendingDues() async {
    final data = await ApiClient.get('${ApiConfig.baseUrl}/reports/pending-dues');
    return data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getDeliverySchedule(int days) async {
    final data = await ApiClient.get(
      '${ApiConfig.baseUrl}/reports/delivery-schedule',
      queryParams: {'days': days.toString()},
    );
    return data as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getTopCustomers() async {
    final data = await ApiClient.get('${ApiConfig.baseUrl}/reports/top-customers');
    return data as List<dynamic>;
  }
}
