import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/constants.dart';
import '../models/customer.dart';
import '../models/measurement.dart';

class PdfService {
  static Future<Uint8List> generateCard({
    required Customer customer,
    required Measurement measurement,
    String? shopName,
    String? shopPhone,
    String? shopAddress,
    String? shopGstin,
    String? shopLogoPath,
    String? shopTerms,
  }) async {
    final m = measurement.measurements;
    final fields = MeasurementFields.byGarment[measurement.garmentType] ?? [];
    final filteredFields = fields.where((f) => m[f] != null && m[f] != '').toList();

    final dateStr = DateFormat('dd/MM/yyyy').format(measurement.createdAt);
    final deliveryStr = measurement.deliveryDate != null
        ? DateFormat('dd MMMM yyyy').format(measurement.deliveryDate!)
        : 'Not set';
    final balance = (measurement.price ?? 0) - (measurement.advance ?? 0);
    final orderId = customer.id.hashCode.abs().toString().padLeft(4, '0');

    final font = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();

    pw.ImageProvider? logoImage;
    if (shopLogoPath != null && shopLogoPath.isNotEmpty) {
      final logoFile = File(shopLogoPath);
      if (await logoFile.exists()) {
        final logoBytes = await logoFile.readAsBytes();
        logoImage = pw.MemoryImage(logoBytes);
      }
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(0),
        build: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _buildHeader(ctx, font, fontBold, dateStr, orderId, shopName, logoImage),
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildCustomerInfo(ctx, font, fontBold, customer, deliveryStr),
                      pw.SizedBox(height: 8),
                      _buildGarmentBadge(ctx, fontBold, measurement.garmentType),
                      pw.SizedBox(height: 8),
                      pw.Expanded(child: _buildMeasurementsTable(ctx, font, fontBold, filteredFields, m)),
                      pw.SizedBox(height: 8),
                      _buildOrderDetails(ctx, font, fontBold, measurement.price, measurement.advance, balance),
                    ],
                  ),
                ),
              ),
              _buildFooter(ctx, font, fontBold, shopPhone, shopAddress, shopGstin, shopTerms),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  static pw.Widget _buildHeader(
    pw.Context ctx,
    pw.Font font,
    pw.Font fontBold,
    String date,
    String orderId,
    String? shopName,
    pw.ImageProvider? logoImage,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF1A3A5C),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              if (logoImage != null) ...[
                pw.Container(
                  width: 28,
                  height: 28,
                  margin: const pw.EdgeInsets.only(right: 8),
                  child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                ),
              ],
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    (shopName != null && shopName.isNotEmpty) ? shopName.toUpperCase() : 'STITCHCRAFT',
                    style: pw.TextStyle(font: fontBold, fontSize: 16, color: PdfColors.white),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'शिवणकाम सोपे, मापे अचूक',
                    style: pw.TextStyle(font: font, fontSize: 9, color: PdfColor.fromInt(0xFFD4A017)),
                  ),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(date, style: pw.TextStyle(font: font, fontSize: 9, color: PdfColor.fromInt(0xFFD4A017))),
              pw.SizedBox(height: 2),
              pw.Text('#$orderId', style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColors.white)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerInfo(pw.Context ctx, pw.Font font, pw.Font fontBold, Customer customer, String delivery) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF0F5FF),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('CUSTOMER NAME', style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColor.fromInt(0xFF6C757D))),
                    pw.SizedBox(height: 2),
                    pw.Text(customer.name, style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColor.fromInt(0xFF1A3A5C))),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('PHONE', style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColor.fromInt(0xFF6C757D))),
                  pw.SizedBox(height: 2),
                  pw.Text(customer.phone, style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColor.fromInt(0xFF1A3A5C))),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text('DELIVERY DATE', style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColor.fromInt(0xFF6C757D))),
          pw.SizedBox(height: 2),
          pw.Text(delivery, style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColor.fromInt(0xFFD4A017))),
        ],
      ),
    );
  }

  static pw.Widget _buildGarmentBadge(pw.Context ctx, pw.Font fontBold, String garmentType) {
    return pw.Center(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFFFDFA0),
          border: pw.Border.all(color: PdfColor.fromInt(0xFFD4A017)),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
        ),
        child: pw.Text(
          '${GarmentType.label(garmentType).toUpperCase()} / ${_marathiLabel(garmentType)}',
          style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColor.fromInt(0xFF261A00)),
        ),
      ),
    );
  }

  static String _marathiLabel(String type) {
    switch (type) {
      case 'shirt': return 'शर्ट';
      case 'pant': return 'पँट';
      case 'kurta': return 'कुर्ता';
      case 'blouse': return 'ब्लाउज';
      case 'sadra': return 'सदरा';
      default: return type;
    }
  }

  static pw.Widget _buildMeasurementsTable(pw.Context ctx, pw.Font font, pw.Font fontBold, List<String> fields, Map<String, dynamic> m) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromInt(0xFFD4A017)),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1A3A5C),
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(7),
                topRight: pw.Radius.circular(7),
              ),
            ),
            child: pw.Row(
              children: [
                pw.SizedBox(width: 24),
                pw.Expanded(child: pw.Text('#', style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white))),
                pw.Expanded(flex: 3, child: pw.Text('Measurement', style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white))),
                pw.SizedBox(width: 60, child: pw.Text('Value', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white))),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.ListView.builder(
              itemCount: fields.length,
              itemBuilder: (ctx2, i) {
                final f = fields[i];
                final label = MeasurementFields.labels[f] ?? f;
                final value = '${m[f]}"';
                final isEven = i.isEven;
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: isEven ? PdfColor.fromInt(0xFFF0F5FF) : PdfColors.white,
                  child: pw.Row(
                    children: [
                      pw.SizedBox(width: 24, child: pw.Text('${i + 1}', style: pw.TextStyle(font: font, fontSize: 9, color: PdfColor.fromInt(0xFF6C757D)))),
                      pw.Expanded(flex: 3, child: pw.Text(label, style: pw.TextStyle(font: font, fontSize: 9))),
                      pw.SizedBox(width: 60, child: pw.Text(value, textAlign: pw.TextAlign.center, style: pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColor.fromInt(0xFF1A3A5C)))),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOrderDetails(pw.Context ctx, pw.Font font, pw.Font fontBold, double? price, double? advance, double balance) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromInt(0xFFD4A017)),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(child: _amountBox(font, fontBold, 'Total', '₹${price?.toStringAsFixed(0) ?? '0'}', PdfColors.white)),
          pw.SizedBox(width: 8),
          pw.Expanded(child: _amountBox(font, fontBold, 'Advance', '₹${advance?.toStringAsFixed(0) ?? '0'}', PdfColor.fromInt(0xFFF0F5FF))),
          pw.SizedBox(width: 8),
          pw.Expanded(child: _amountBox(font, fontBold, 'Balance', '₹${balance.toStringAsFixed(0)}', PdfColor.fromInt(0xFFFFF5E0))),
        ],
      ),
    );
  }

  static pw.Widget _amountBox(pw.Font font, pw.Font fontBold, String label, String value, PdfColor bg) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: bg,
        border: pw.Border.all(color: PdfColor.fromInt(0xFFD4A017)),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        children: [
          pw.Text(label.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 7, color: PdfColor.fromInt(0xFF6C757D))),
          pw.SizedBox(height: 2),
          pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColor.fromInt(0xFF1A3A5C))),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(
    pw.Context ctx,
    pw.Font font,
    pw.Font fontBold,
    String? shopPhone,
    String? shopAddress,
    String? shopGstin,
    String? shopTerms,
  ) {
    final List<String> details = [];
    if (shopPhone != null && shopPhone.isNotEmpty) details.add('Call: $shopPhone');
    if (shopGstin != null && shopGstin.isNotEmpty) details.add('GSTIN: $shopGstin');

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF1A3A5C),
      ),
      child: pw.Column(
        children: [
          if (shopTerms != null && shopTerms.isNotEmpty) ...[
            pw.Text(
              'Terms: $shopTerms',
              style: pw.TextStyle(font: font, fontSize: 8, color: PdfColor.fromInt(0xFFD4A017)),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 4),
          ],
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  (shopAddress != null && shopAddress.isNotEmpty) ? shopAddress : 'Powered by StitchCraft',
                  style: pw.TextStyle(font: font, fontSize: 8, color: PdfColor.fromInt(0xFF87A4CC)),
                  maxLines: 1,
                  overflow: pw.TextOverflow.clip,
                ),
              ),
              if (details.isNotEmpty) ...[
                pw.SizedBox(width: 8),
                pw.Text(
                  details.join(' | '),
                  style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColor.fromInt(0xFF87A4CC)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> sharePdf({
    required Customer customer,
    required Measurement measurement,
    String? shopName,
    String? shopPhone,
    String? shopAddress,
    String? shopGstin,
    String? shopLogoPath,
    String? shopTerms,
  }) async {
    final pdfBytes = await generateCard(
      customer: customer,
      measurement: measurement,
      shopName: shopName,
      shopPhone: shopPhone,
      shopAddress: shopAddress,
      shopGstin: shopGstin,
      shopLogoPath: shopLogoPath,
      shopTerms: shopTerms,
    );
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/${customer.name}_${measurement.garmentType}_card.pdf',
    );
    await file.writeAsBytes(pdfBytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Measurement Card - ${customer.name}',
    );
  }
}
