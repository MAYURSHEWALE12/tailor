import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/measurement.dart';
import 'api_client.dart';

class MeasurementService {
  static Future<List<Measurement>> getCustomerMeasurements(
      String customerId) async {
    final data = await ApiClient.get(
      '${ApiConfig.measurements}/customer/$customerId',
    );
    final List<dynamic> list = data is List ? data : data['data'] as List<dynamic>;
    return list.map((json) => Measurement.fromJson(json)).toList();
  }

  static Future<Measurement> createMeasurement({
    required String customerId,
    required String garmentType,
    required Map<String, dynamic> measurements,
    double? price,
    double? advance,
    DateTime? deliveryDate,
    String? notes,
    String? designImage,
  }) async {
    final body = <String, dynamic>{
      'customerId': customerId,
      'garmentType': garmentType,
      'measurements': measurements,
    };
    if (price != null) body['price'] = price;
    if (advance != null) body['advance'] = advance;
    if (deliveryDate != null) body['deliveryDate'] = deliveryDate.toIso8601String();
    if (notes != null) body['notes'] = notes;
    if (designImage != null) body['designImage'] = designImage;

    final data =
        await ApiClient.post(ApiConfig.measurements, body: body);
    return Measurement.fromJson(data);
  }

  static Future<Measurement> updateMeasurement(
    String id, {
    Map<String, dynamic>? measurements,
    double? price,
    double? advance,
    DateTime? deliveryDate,
    String? orderStatus,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (measurements != null) body['measurements'] = measurements;
    if (price != null) body['price'] = price;
    if (advance != null) body['advance'] = advance;
    if (deliveryDate != null) body['deliveryDate'] = deliveryDate.toIso8601String();
    if (orderStatus != null) body['orderStatus'] = orderStatus;
    if (notes != null) body['notes'] = notes;

    final data =
        await ApiClient.put('${ApiConfig.measurements}/$id', body: body);
    return Measurement.fromJson(data);
  }

  static Future<void> deleteMeasurement(String id) async {
    await ApiClient.delete('${ApiConfig.measurements}/$id');
  }

  static Future<Measurement> addPayment(String measurementId, {required double amount, String method = 'cash', String? notes}) async {
    final data = await ApiClient.post(
      '${ApiConfig.measurements}/$measurementId/payments',
      body: {'amount': amount, 'method': method, 'notes': notes ?? ''},
    );
    return Measurement.fromJson(data);
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    final data = await ApiClient.get('${ApiConfig.measurements}/stats/dashboard');
    return data as Map<String, dynamic>;
  }

  static Future<String> uploadImage(File imageFile) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer ${ApiClient.token}';
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data['url'] as String;
    }
    throw ApiException('Image upload failed', statusCode: response.statusCode);
  }
}
