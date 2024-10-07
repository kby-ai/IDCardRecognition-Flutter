import 'dart:typed_data';

import 'idsdk_plugin_platform_interface.dart';

class IDsdkPlugin {
  Future<String?> getPlatformVersion() {
    return IDsdkPluginPlatform.instance.getPlatformVersion();
  }

  Future<int?> setActivation(String license) {
    return IDsdkPluginPlatform.instance.setActivation(license);
  }

  Future<int?> init() {
    return IDsdkPluginPlatform.instance.init();
  }

  Future<dynamic> idcardRecognition(String imagePath) {
    return IDsdkPluginPlatform.instance.idcardRecognition(imagePath);
  }
}
