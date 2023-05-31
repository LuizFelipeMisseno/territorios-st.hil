import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<Uint8List> generatePdf({required Uint8List image, required String territorio, required String cartao}) async {
  final doc = pw.Document(pageMode: PdfPageMode.outlines);
  final font1 = await PdfGoogleFonts.openSansRegular();
  final font2 = await PdfGoogleFonts.openSansBold();
  final im = await flutterImageProvider(Image.memory(image).image);

  doc.addPage(
    pw.Page(
      theme: pw.ThemeData.withFont(
        base: font1,
        bold: font2,
      ),
      pageFormat: const PdfPageFormat(479, 266),
      orientation: pw.PageOrientation.landscape,
      build: (pw.Context context) => pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Container(
            height: 44,
            width: 479,
            color: PdfColor.fromHex('#12607D'),
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 20),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Congregação Santo Hilário',
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    territorio,
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.Container(
            height: 222,
            width: 155 + 324,
            child: pw.Row(
              children: [
                pw.Container(
                  height: 222,
                  width: 155,
                  color: PdfColor.fromHex('#1A8DB8'),
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Cartão $cartao',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Observações',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Container(
                          height: 140,
                          width: 135,
                          color: PdfColors.white,
                        )
                      ],
                    ),
                  ),
                ),
                pw.Container(
                  height: 222,
                  width: 324,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Image(im),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  final pdf = await doc.save();
  return pdf;
}
