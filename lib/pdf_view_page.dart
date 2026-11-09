import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfViewPage extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewPage({super.key, required this.pdfUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEEFFD),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: const Color(0xFFDEEFFD),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: PdfViewer.uri(
        Uri.parse(pdfUrl),
        params: const PdfViewerParams(margin: 8),
      ),
    );
  }
}
