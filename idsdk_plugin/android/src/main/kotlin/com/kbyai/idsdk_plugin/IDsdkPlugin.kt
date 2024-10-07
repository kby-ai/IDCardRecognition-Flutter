package com.kbyai.idsdk_plugin

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformViewRegistry
import android.util.Log
import com.kbyai.idsdk.IDSDK
import com.kbyai.idsdk_plugin.*
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import java.io.File
import java.io.ByteArrayOutputStream
import java.util.Base64
import android.app.Activity


/** IDsdkPlugin */
class IDsdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var registery: PlatformViewRegistry
  private lateinit var dartExecuter: DartExecutor
  private lateinit var context: Context
  private var activity: Activity? = null


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "idsdk_plugin")
    channel.setMethodCallHandler(this)

    context = flutterPluginBinding.applicationContext

    registery = flutterPluginBinding.getFlutterEngine().getPlatformViewsController().getRegistry();
    dartExecuter = flutterPluginBinding.getFlutterEngine().getDartExecutor();
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "setActivation") {
      val license: String? = call.argument("license")
      val ret = IDSDK.setActivation(license);
      result.success(ret)
    } else if (call.method == "init") {
      val ret = IDSDK.init(activity)
      result.success(ret)
    } else if (call.method == "idcardRecognition") {
      val imagePath: String? = call.argument("imagePath")

      var bitmap: Bitmap? = BitmapFactory.decodeFile(imagePath)
      val idResult = IDSDK.idcardRecognition(bitmap);
      val e: HashMap<String, Any> = HashMap<String, Any>();
      e.put("results", idResult)
      e.put("frameWidth", bitmap?.width ?: 0)
      e.put("frameHeight", bitmap?.height ?: 0)
      result.success(e)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(@NonNull binding: ActivityPluginBinding) {
    if (binding.getActivity() != null) {
      activity = binding.getActivity()
      registery
        .registerViewFactory(
          "idcarddetectionview", IDCardDetectionViewFactory(binding, dartExecuter)
        )
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {}

  override fun onReattachedToActivityForConfigChanges(@NonNull binding: ActivityPluginBinding) {}

  override fun onDetachedFromActivity() {}

}
