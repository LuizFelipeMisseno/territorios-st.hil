import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatefulWidget {
  final Uint8List pdf;
  final String cartao;
  const PdfViewerPage({super.key, required this.pdf, required this.cartao});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: SfPdfViewer.memory(
        widget.pdf,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Printing.sharePdf(bytes: widget.pdf, filename: 'cartao-${widget.cartao}.pdf');
        },
        child: const Icon(Icons.share),
      ),
    );
  }
}
