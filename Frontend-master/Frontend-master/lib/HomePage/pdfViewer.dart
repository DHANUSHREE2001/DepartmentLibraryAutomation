

import 'dart:io';
import 'dart:typed_data';

// import 'package:http/http.dart' as http;
// import 'dart:typed_data';
// import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdfviewer_web/pdfviewer_web.dart';


class PdfViewer extends StatefulWidget {
  String name;
  String link;
  PdfViewer( {required this.name,required this.link});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}


class _PdfViewerState extends State<PdfViewer> {
  // late Uri url;
  // Uint8List? _documentBytes;
  // bool _isLoading = true;
  // late PDFDocument _pdf;
  // void _loadFile() async {
  //   _pdf = await PDFDocument.fromURL(widget.link);
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }
  // void getReq()async {
  //   url = Uri.parse(widget.link);
  //   var response = await http.post(url);
  //
  //   _documentBytes = response.bodyBytes;
  //   // final HttpClientRequest request = await client.getUrl(url);
  //   // final HttpClientResponse response = await request.close();
  //   // _documentBytes = await consolidateHttpClientResponseBytes(response);
  //   setState(() {});
  //   print(_documentBytes);
  // }

// void getReq()async{
//   _documentBytes = await widget.link.readAsBytes();
// }
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  @override
  void initState() {
    print('Inside ${widget.link}');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.bookmark,
              color: Colors.white,
            ),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.link,
        key: _pdfViewerKey,
      ),
    );
  }
}
