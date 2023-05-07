import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:test_generator/pages/pdfexport/pdf/pdfexport.dart';
import 'package:test_generator/models/invoice.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PinchPage extends StatefulWidget {
  final Invoice invoice;
  const PinchPage({Key? key, required this.invoice}) : super(key: key);
  @override
  State<PinchPage> createState() => _PinchPageState();
}

enum DocShown { sample, tutorial, hello, password }

class _PinchPageState extends State<PinchPage> {
  static const int _initialPage = 1;
  DocShown _showing = DocShown.sample;
  late PdfControllerPinch _pdfControllerPinch;
  @override
  void initState() {
    _pdfControllerPinch = PdfControllerPinch(
      document: PdfDocument.openData(makePdf(widget.invoice)),
    );
    super.initState();
  }

  @override
  void dispose() {
    _pdfControllerPinch.dispose();
    super.dispose();
  }

  bool isMobile() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Pdfx example'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: () {
              _pdfControllerPinch.previousPage(
                curve: Curves.ease,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
          PdfPageNumber(
            controller: _pdfControllerPinch,
            builder: (_, loadingState, page, pagesCount) => Container(
              alignment: Alignment.center,
              child: Text(
                '$page/${pagesCount ?? 0}',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: () {
              _pdfControllerPinch.nextPage(
                curve: Curves.ease,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              try {
                final da = await makePdf(widget.invoice);
                final filePath = await FilePicker.platform.getDirectoryPath();
                File a = File('');
                if (filePath != null) {
                  final t = DateTime.now();
                  final file = File(
                      '$filePath/test_${t.hour.toString()}.${t.minute.toString()}_${t.day.toString()}.${t.month.toString()}.pdf');
                  a = await file.writeAsBytes(da);
                }
                if (a.existsSync()) {
                  if (isMobile()) {
                    Fluttertoast.showToast(
                      msg: "Сохранено",
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 1,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        duration: Duration(milliseconds: 1000),
                        content: Center(
                            child: Text(
                          "Сохранено",
                          style: TextStyle(color: Theme.of(context).hintColor),
                        )),
                      ),
                    );
                  }
                }
              } catch (ex) {}
            },
          ),
        ],
      ),
      body: PdfViewPinch(
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          pageLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          errorBuilder: (_, error) => Center(child: Text(error.toString())),
        ),
        controller: _pdfControllerPinch,
      ),
    );
  }
}
