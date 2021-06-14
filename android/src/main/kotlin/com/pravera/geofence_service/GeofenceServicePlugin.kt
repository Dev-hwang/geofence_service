package com.pravera.geofence_service

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** GeofenceServicePlugin */
class GeofenceServicePlugin: FlutterPlugin, ActivityAware {
  private lateinit var methodCallHandler: MethodCallHandlerImpl
  private lateinit var locationServiceStatusStreamHandler: LocationServiceStatusStreamHandlerImpl

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodCallHandler = MethodCallHandlerImpl()
    methodCallHandler.startListening(binding.binaryMessenger)

    locationServiceStatusStreamHandler = LocationServiceStatusStreamHandlerImpl()
    locationServiceStatusStreamHandler.startListening(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    if (::methodCallHandler.isInitialized)
      methodCallHandler.stopListening()

    if (::locationServiceStatusStreamHandler.isInitialized)
      locationServiceStatusStreamHandler.stopListening()
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    methodCallHandler.setActivity(binding.activity)
    locationServiceStatusStreamHandler.setActivity(binding.activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    methodCallHandler.setActivity(null)
    locationServiceStatusStreamHandler.setActivity(null)
  }
}
