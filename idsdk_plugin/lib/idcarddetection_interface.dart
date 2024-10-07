import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class IDCardDetectionInterface {
  IDCardDetectionInterface();

  void onIDCardResult(results) {
    throw UnimplementedError('onIDCardResult() has not been implemented.');
  }
}

class IDCardDetectionViewController {
  final MethodChannel _channel;
  final IDCardDetectionInterface idcardDetectionInterface;

  IDCardDetectionViewController(int id, this.idcardDetectionInterface)
      : _channel = MethodChannel('idcarddetectionview_$id');

  Future<void> initHandler() async {
    _channel.setMethodCallHandler(nativeMethodCallHandler);
  }

  Future<bool?> startCamera(int cameraLens) async {
    final ret =
        _channel.invokeMethod<bool>('startCamera', {"cameraLens": cameraLens});
    return ret;
  }

  Future<bool?> stopCamera() async {
    final ret = _channel.invokeMethod<bool>('stopCamera');
    return ret;
  }

  Future<void> nativeMethodCallHandler(MethodCall methodCall) async {
    if (methodCall.method == "onIDCardResult") {
      idcardDetectionInterface.onIDCardResult(methodCall.arguments);
    }
  }
}
