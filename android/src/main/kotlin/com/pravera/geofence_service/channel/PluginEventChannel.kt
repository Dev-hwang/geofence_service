package com.pravera.geofence_service.channel

import android.app.Activity
import com.pravera.geofence_service.activity_recognition.ActivityRecognitionManager
import com.pravera.geofence_service.errors.ErrorCodes
import com.pravera.geofence_service.permission.PermissionManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

class PluginEventChannel(
		private val permissionManager: PermissionManager,
		private val activityRecognitionManager: ActivityRecognitionManager) {

	companion object {
		const val TAG = "PluginEventChannel"
	}

	private var activity: Activity? = null

  private lateinit var activityRecognitionChannel: EventChannel
	private val activityRecognitionStreamHandler = object : EventChannel.StreamHandler {
		override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
			activityRecognitionManager.startService(
					activity!!,
					updatesCallback = { events?.success(it) },
					successCallback = { },
					errorCallback = { error(events, it) }
			)
		}

		override fun onCancel(arguments: Any?) {
			activityRecognitionManager.stopService(
					activity!!,
					successCallback = { },
					errorCallback = { }
			)
		}
	}

	fun setActivity(activity: Activity?) {
		this.activity = activity
	}  
	
  fun startListening(messenger: BinaryMessenger) {
		activityRecognitionChannel = EventChannel(messenger, 
				"geofence_service/activity_recognition_updates")
		activityRecognitionChannel.setStreamHandler(activityRecognitionStreamHandler)
  }

  fun stopListening() {
    if (::activityRecognitionChannel.isInitialized)
			activityRecognitionChannel.setStreamHandler(null)
  }

	private fun error(events: EventChannel.EventSink?, code: ErrorCodes) {
		events?.error(code.toString(), null, null)
	}
}
