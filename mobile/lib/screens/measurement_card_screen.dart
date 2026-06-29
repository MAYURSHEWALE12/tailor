import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../models/measurement.dart';
import '../services/pdf_service.dart';
import '../providers/shop_provider.dart';

class MeasurementCardScreen extends StatelessWidget {
  const MeasurementCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final customer = args?['customer'] as Customer?;
    final measurement = args?['measurement'] as Measurement?;
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    if (customer == null || measurement == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Measurement Card')),
        body: const Center(child: Text('No data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${customer.name} - Card'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => PdfService.sharePdf(
              customer: customer,
              measurement: measurement,
              shopName: shopProvider.shopName,
              shopPhone: shopProvider.phone,
              shopAddress: shopProvider.address,
              shopGstin: shopProvider.gstin,
              shopLogoPath: shopProvider.logoPath,
              shopTerms: shopProvider.terms,
            ),
            tooltip: 'Share PDF',
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => PdfService.generateCard(
          customer: customer,
          measurement: measurement,
          shopName: shopProvider.shopName,
          shopPhone: shopProvider.phone,
          shopAddress: shopProvider.address,
          shopGstin: shopProvider.gstin,
          shopLogoPath: shopProvider.logoPath,
          shopTerms: shopProvider.terms,
        ),
        pdfFileName: '${customer.name}_${measurement.garmentType}_card.pdf',
        canChangeOrientation: false,
        canChangePageFormat: false,
        actions: const [],
      ),
    );
  }
}
