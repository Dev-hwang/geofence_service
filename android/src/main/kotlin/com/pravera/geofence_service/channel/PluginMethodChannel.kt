package com.pravera.geofence_service.channel

import android.Manifest
import android.app.Activity
import com.pravera.geofence_service.Constant
import com.pravera.geofence_service.errors.ErrorCodes
import com.pravera.geofence_service.permission.PermissionManager
import com.pravera.geofence_service.foreground_service.ForegroundServiceManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class PluginMethodChannel(
		private val permissionManager: PermissionManager,
		private val foregroundServiceManager: ForegroundServiceManager) {

	companion object {
		const val TAG = "PluginMethodChannel"
	}

	private var activity: Activity? = null

	private lateinit var activityRecognitionChannel: MethodChannel
	private val activityRecognitionMethodCallHandler = MethodChannel.MethodCallHandler { call, result ->
		if (activity == null) {
			error(result, ErrorCodes.ACTIVITY_NOT_REGISTERED)
			return@MethodCallHandler
		}
		
		when (call.method) {
			"checkActivityRecognitionPermission" -> {
				val pResult = permissionManager.checkPermission(
						activity!!, Manifest.permission.ACTIVITY_RECOGNITION)
				result.success(pResult.toString())
			}
			"requestActivityRecognitionPermission" -> {
				permissionManager.requestPermission(
						activity!!,
						permission = Manifest.permission.ACTIVITY_RECOGNITION,
						requestCode = Constant.ACTIVITY_RECOGNITION_PERMISSION_REQ_CODE,
						resultCallback = { result.success(it.toString()) },
						errorCallback = { error(result, it) }
				)
			}
			else -> result.notImplemented()
		}
	}

	private lateinit var foregroundServiceChannel: MethodChannel
	private val foregroundServiceMethodCallHandler = MethodChannel.MethodCallHandler { call, result ->
		if (activity == null) {
			error(result, ErrorCodes.ACTIVITY_NOT_REGISTERED)
			return@MethodCallHandler
		}

		when (call.method) {
			"startForegroundService" -> foregroundServiceManager.startService(activity!!, call)
			"stopForegroundService" -> foregroundServiceManager.stopService(activity!!)
			"minimizeApp" -> foregroundServiceManager.minimizeApp(activity!!)
			else -> result.notImplemented()
		}
	}

	fun setActivity(activity: Activity?) {
		this.activity = activity
	}
	
  fun startListening(messenger: BinaryMessenger) {
		activityRecognitionChannel = MethodChannel(messenger,
				"geofence_service/activity_recognition")
		activityRecognitionChannel.setMethodCallHandler(activityRecognitionMethodCallHandler)

		foregroundServiceChannel = MethodChannel(messenger,
				"geofence_service/foreground_service")
		foregroundServiceChannel.setMethodCallHandler(foregroundServiceMethodCallHandler)
  }

  fun stopListening() {
    if (::activityRecognitionChannel.isInitialized)
			activityRecognitionChannel.setMethodCallHandler(null)
		
		if (::foregroundServiceChannel.isInitialized)
			foregroundServiceChannel.setMethodCallHandler(null)
  }

	private fun error(result: MethodChannel.Result, code: ErrorCodes) {
		result.error(code.toString(), null, null)
	}
}
