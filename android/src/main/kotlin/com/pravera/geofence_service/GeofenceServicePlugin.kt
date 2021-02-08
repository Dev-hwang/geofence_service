package com.pravera.geofence_service

import androidx.annotation.NonNull
import com.pravera.geofence_service.activity_recognition.ActivityRecognitionManager
import com.pravera.geofence_service.channel.PluginEventChannel
import com.pravera.geofence_service.channel.PluginMethodChannel
import com.pravera.geofence_service.foreground_service.ForegroundServiceManager
import com.pravera.geofence_service.permission.PermissionManager

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** GeofenceServicePlugin */
class GeofenceServicePlugin: FlutterPlugin, ActivityAware {
  private lateinit var pluginMethodChannel: PluginMethodChannel
  private lateinit var pluginEventChannel: PluginEventChannel

  private val permissionManager = PermissionManager()
  private val foregroundServiceManager = ForegroundServiceManager()
  private val activityRecognitionManager = ActivityRecognitionManager()

  private var pluginBinding: ActivityPluginBinding? = null
  
  companion object {
    const val TAG = "GeofenceServicePlugin"
  }

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    pluginMethodChannel = PluginMethodChannel(permissionManager, foregroundServiceManager)
    pluginMethodChannel.startListening(binding.binaryMessenger)

    pluginEventChannel = PluginEventChannel(permissionManager, activityRecognitionManager)
    pluginEventChannel.startListening(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    if (::pluginMethodChannel.isInitialized)
      pluginMethodChannel.stopListening()
    
    if (::pluginEventChannel.isInitialized)
      pluginEventChannel.stopListening()
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    pluginMethodChannel.setActivity(binding.activity)
    pluginEventChannel.setActivity(binding.activity)

    binding.addRequestPermissionsResultListener(permissionManager)
    pluginBinding = binding
  }

  override fun onDetachedFromActivity() {
    pluginMethodChannel.setActivity(null)
    pluginEventChannel.setActivity(null)

    pluginBinding?.removeRequestPermissionsResultListener(permissionManager)
    pluginBinding = null
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }
}
