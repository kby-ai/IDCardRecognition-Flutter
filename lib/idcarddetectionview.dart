import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idsdk_plugin/idcarddetection_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:idsdk_plugin/idsdk_plugin.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';

// ignore: must_be_immutable
class IDCardRecognitionView extends StatefulWidget {
  IDCardDetectionViewController? idcardDetectionViewController;

  IDCardRecognitionView({super.key});

  @override
  State<StatefulWidget> createState() => IDCardRecognitionViewState();
}

class IDCardRecognitionViewState extends State<IDCardRecognitionView> {
  dynamic _idResults;
  bool _recognized = false;
  var _documentJson;
  // ignore: prefer_typing_uninitialized_variables
  var _documentImage;
  // ignore: prefer_typing_uninitialized_variables
  var _portraitImage;
  IDCardDetectionViewController? idcardDetectionViewController;

  @override
  void initState() {
    super.initState();
  }

  Future<void> idcardRecognitionStart() async {
    final prefs = await SharedPreferences.getInstance();
    var cameraLens = prefs.getInt("camera_lens");

    setState(() {
      _idResults = null;
      _recognized = false;
    });

    await idcardDetectionViewController?.startCamera(cameraLens ?? 1);
  }

  Future<bool> onIDCardResult(results) async {
    if (_recognized == true) {
      return false;
    }

    if (!mounted) return false;

    setState(() {
      _idResults = results;
    });

    bool recognized = false;
    var documentImage = "";
    var portraitImage = "";
    var documentJson = null;
    if (results['results'] != null) {
      Map<String, dynamic> jsonData = jsonDecode(results['results'].toString());
      int quality = jsonData["Quality"];
      if (quality > 80) {
        recognized = true;
        documentImage = jsonData["Images"]["Document"];
        portraitImage = jsonData["Images"]["Portrait"];
        documentJson = jsonData;
      }
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return false;
      setState(() {
        _recognized = recognized;
      });
      if (recognized) {
        idcardDetectionViewController?.stopCamera();
        setState(() {
          _idResults = null;
          _documentImage = base64Decode(documentImage);
          _portraitImage = base64Decode(portraitImage);
          _documentJson = documentJson;
        });
      }
    });

    return recognized;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        idcardDetectionViewController?.stopCamera();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ID Card Recognition'),
          toolbarHeight: 70,
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            IDCardDetectionView(idcardRecognitionViewState: this),
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: FacePainter(idResults: _idResults),
              ),
            ),
            Visibility(
              visible: _recognized,
              child: Container(
                color: Theme.of(context).colorScheme.background,
                child: ListView(
                  children: [
                    _portraitImage != null
                        ? Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.memory(
                                  _portraitImage,
                                  width: 160,
                                  height: 160,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text('Portrait')
                            ],
                          )
                        : const SizedBox(
                            height: 1,
                          ),
                    _documentImage != null
                        ? Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.memory(
                                  _documentImage,
                                  width: 160,
                                  height: 160,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text('Document')
                            ],
                          )
                        : const SizedBox(
                            height: 1,
                          ),
                    JsonViewer(_documentJson),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IDCardDetectionView extends StatefulWidget
    implements IDCardDetectionInterface {
  IDCardRecognitionViewState idcardRecognitionViewState;

  IDCardDetectionView({super.key, required this.idcardRecognitionViewState});

  @override
  Future<void> onIDCardResult(results) async {
    await idcardRecognitionViewState.onIDCardResult(results);
  }

  @override
  State<StatefulWidget> createState() => _IDCardDetectionViewState();
}

class _IDCardDetectionViewState extends State<IDCardDetectionView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'idcarddetectionview',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      return UiKitView(
        viewType: 'idcarddetectionview',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
  }

  void _onPlatformViewCreated(int id) async {
    var cameraLens = 0;

    widget.idcardRecognitionViewState.idcardDetectionViewController =
        IDCardDetectionViewController(id, widget);

    await widget.idcardRecognitionViewState.idcardDetectionViewController
        ?.initHandler();

    await widget.idcardRecognitionViewState.idcardDetectionViewController
        ?.startCamera(cameraLens);
  }
}

class FacePainter extends CustomPainter {
  dynamic idResults;
  FacePainter({required this.idResults});

  @override
  void paint(Canvas canvas, Size size) {
    if (idResults != null) {
      var paint = Paint();
      paint.color = const Color.fromARGB(0xff, 0xff, 0, 0);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;

      if (idResults['results'] != null) {
        Map<String, dynamic> jsonData =
            jsonDecode(idResults['results'].toString());
        int x1 = jsonData["Position"]["x1"];
        int y1 = jsonData["Position"]["y1"];
        int x2 = jsonData["Position"]["x2"];
        int y2 = jsonData["Position"]["y2"];

        int frameWidth = idResults['frameWidth'];
        int frameHeight = idResults['frameHeight'];
        double xScale = frameWidth / size.width;
        double yScale = frameHeight / size.height;

        String title = "";
        Color color = const Color.fromARGB(0xff, 0, 0xff, 0);
        title = "Quality: " + jsonData["Quality"].toString();

        TextSpan span =
            TextSpan(style: TextStyle(color: color, fontSize: 20), text: title);
        TextPainter tp = TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(x1 / xScale, y1 / yScale - 30));

        paint.color = color;
        canvas.drawRect(
            Offset(x1 / xScale, y1 / yScale) &
                Size((x2 - x1) / xScale, (y2 - y1) / yScale),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
