import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfScreen extends StatefulWidget {
  final String path;

  const PdfScreen({Key? key, required this.path}) : super(key: key);

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  bool isLoading = true;
  int totalPages = 0;
  int? currentPage = 0;
  PDFViewController? pdfViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizar PDF'),
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.path,
            autoSpacing: true,
            enableSwipe: true,
            pageSnap: true,
            swipeHorizontal: true,
            onError: (e) {
              developer.log(e);
            },
            onRender: (pages) {
              setState(() {
                totalPages = pages!;
                isLoading = false;
              });
            },
            onViewCreated: (PDFViewController vc) {
              pdfViewController = vc;
            },
            onPageChanged: (int? page, int? total) {
              developer.log('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }
}
