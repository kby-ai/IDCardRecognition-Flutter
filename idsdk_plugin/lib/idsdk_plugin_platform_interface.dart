import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'idsdk_plugin_method_channel.dart';

abstract class IDsdkPluginPlatform extends PlatformInterface {
  /// Constructs a IDsdkPluginPlatform.
  IDsdkPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static IDsdkPluginPlatform _instance = MethodChannelIDsdkPlugin();

  /// The default instance of [IDsdkPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelIDsdkPlugin].
  static IDsdkPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IDsdkPluginPlatform] when
  /// they register themselves.
  static set instance(IDsdkPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int?> setActivation(String license) {
    throw UnimplementedError('setActivation() has not been implemented.');
  }

  Future<int?> init() {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<dynamic> idcardRecognition(String imagePath) {
    throw UnimplementedError('idcardRecognition() has not been implemented.');
  }
}
