import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'idsdk_plugin_platform_interface.dart';

/// An implementation of [IDsdkPluginPlatform] that uses method channels.
class MethodChannelIDsdkPlugin extends IDsdkPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('idsdk_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<int?> setActivation(String license) async {
    final ret = await methodChannel
        .invokeMethod<int>('setActivation', {"license": license});
    return ret;
  }

  @override
  Future<int?> init() async {
    final ret = await methodChannel.invokeMethod<int>('init');
    return ret;
  }

  @override
  Future<dynamic> idcardRecognition(String imagePath) async {
    final ret = await methodChannel
        .invokeMethod<dynamic>('idcardRecognition', {"imagePath": imagePath});
    return ret;
  }
}
