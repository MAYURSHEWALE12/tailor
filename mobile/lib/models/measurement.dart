class Payment {
  final double amount;
  final DateTime date;
  final String method;
  final String? notes;

  Payment({
    required this.amount,
    required this.date,
    this.method = 'cash',
    this.notes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      method: json['method'] ?? 'cash',
      notes: json['notes'],
    );
  }
}

class Measurement {
  final String id;
  final String customer;
  final String tailor;
  final String garmentType;
  final Map<String, dynamic> measurements;
  final double? price;
  final double? advance;
  final DateTime? deliveryDate;
  final String orderStatus;
  final String? notes;
  final String? designImage;
  final List<Payment> payments;
  final DateTime createdAt;

  Measurement({
    required this.id,
    required this.customer,
    required this.tailor,
    required this.garmentType,
    required this.measurements,
    this.price,
    this.advance,
    this.deliveryDate,
    this.orderStatus = 'pending',
    this.notes,
    this.designImage,
    this.payments = const [],
    required this.createdAt,
  });

  double get totalPaid => (advance ?? 0) + payments.fold(0.0, (s, p) => s + p.amount);
  double get balance => (price ?? 0) - totalPaid;

  factory Measurement.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic v) => v is Map ? v['_id']?.toString() ?? '' : v?.toString() ?? '';
    return Measurement(
      id: json['_id']?.toString() ?? '',
      customer: extractId(json['customer']),
      tailor: extractId(json['tailor']),
      garmentType: json['garmentType'] ?? '',
      measurements:
          Map<String, dynamic>.from(json['measurements'] ?? {}),
      price: (json['price'] as num?)?.toDouble(),
      advance: (json['advancePaid'] as num?)?.toDouble(),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      orderStatus: json['orderStatus'] ?? 'pending',
      notes: json['specialInstructions'],
      designImage: json['designImage'],
      payments: (json['payments'] as List<dynamic>?)
              ?.map((p) => Payment.fromJson(p))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'garmentType': garmentType,
      'measurements': measurements,
      'price': price,
      'advance': advance,
      'deliveryDate': deliveryDate?.toIso8601String(),
      'orderStatus': orderStatus,
      'notes': notes,
      'designImage': designImage,
    };
  }
}
