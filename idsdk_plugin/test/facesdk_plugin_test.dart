// import 'package:flutter_test/flutter_test.dart';
// import 'package:idsdk_plugin/idsdk_plugin.dart';
// import 'package:idsdk_plugin/idsdk_plugin_platform_interface.dart';
// import 'package:idsdk_plugin/idsdk_plugin_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockIDsdkPluginPlatform
//     with MockPlatformInterfaceMixin
//     implements IDsdkPluginPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final IDsdkPluginPlatform initialPlatform = IDsdkPluginPlatform.instance;

//   test('$MethodChannelIDsdkPlugin is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelIDsdkPlugin>());
//   });

//   test('getPlatformVersion', () async {
//     IDsdkPlugin IDsdkPlugin = IDsdkPlugin();
//     MockIDsdkPluginPlatform fakePlatform = MockIDsdkPluginPlatform();
//     IDsdkPluginPlatform.instance = fakePlatform;

//     expect(await IDsdkPlugin.getPlatformVersion(), '42');
//   });
// }
