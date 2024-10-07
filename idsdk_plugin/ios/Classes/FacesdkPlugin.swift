import Flutter
import UIKit

public class IDsdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "idsdk_plugin", binaryMessenger: registrar.messenger())
    let instance = IDsdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    registrar.register(FaceDetectionViewFactory(registrar: registrar), withId: "idcarddetectionview")
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments
    let myArgs = args as? [String: Any]
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "setActivation":
      let license = myArgs?["license"] as! String
      print("args: ", license)
      var ret = IDSDK.setActivation(license)
      result(ret)
    case "init":
      var ret = IDSDK.initSDK()
      result(ret)
    case "idcardRecognition":
      let imagePath = myArgs?["imagePath"] as! String
      var faceBoxesMap = NSMutableArray()
      guard let image = UIImage(contentsOfFile: imagePath)?.fixOrientation() as? UIImage else {
        result(faceBoxesMap)
        return
      }

      result(null)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

