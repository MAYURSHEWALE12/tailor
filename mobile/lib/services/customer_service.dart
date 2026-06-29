import '../config/api_config.dart';
import '../models/customer.dart';
import 'api_client.dart';

class CustomerService {
  static Future<List<Customer>> getCustomers({String? query}) async {
    final params = <String, String>{};
    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }
    final data = await ApiClient.get(
      ApiConfig.customers,
      queryParams: params.isNotEmpty ? params : null,
    );
    final List<dynamic> list = data is List ? data : data['data'] as List<dynamic>;
    return list.map((json) => Customer.fromJson(json)).toList();
  }

  static Future<Customer> getCustomer(String id) async {
    final data = await ApiClient.get('${ApiConfig.customers}/$id');
    return Customer.fromJson(data);
  }

  static Future<Customer> createCustomer({
    required String name,
    required String phone,
    String? address,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'phone': phone,
    };
    if (address != null) body['address'] = address;
    if (notes != null) body['notes'] = notes;

    final data = await ApiClient.post(ApiConfig.customers, body: body);
    return Customer.fromJson(data);
  }

  static Future<Customer> updateCustomer(
    String id, {
    String? name,
    String? phone,
    String? address,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (address != null) body['address'] = address;
    if (notes != null) body['notes'] = notes;

    final data =
        await ApiClient.put('${ApiConfig.customers}/$id', body: body);
    return Customer.fromJson(data);
  }

  static Future<void> deleteCustomer(String id) async {
    await ApiClient.delete('${ApiConfig.customers}/$id');
  }
}
