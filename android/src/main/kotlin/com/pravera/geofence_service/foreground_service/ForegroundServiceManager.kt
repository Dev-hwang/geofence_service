package com.pravera.geofence_service.foreground_service

import android.app.Activity
import android.content.Intent
import android.os.Build
import io.flutter.plugin.common.MethodCall

class ForegroundServiceManager {
	fun startService(activity: Activity, call: MethodCall) {
		val intent = Intent(activity, ForegroundService::class.java).apply {
			putExtra("notificationChannelId",
					call.argument<String>("notificationChannelId"))
			putExtra("notificationChannelName",
					call.argument<String>("notificationChannelName"))
			putExtra("notificationContentTitle",
					call.argument<String>("notificationContentTitle"))
			putExtra("notificationContentText",
					call.argument<String>("notificationContentText"))
		}

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
			activity.startForegroundService(intent)
		else
			activity.startService(intent)
	}
	
	fun stopService(activity: Activity) {
		val intent = Intent(activity, ForegroundService::class.java)
		activity.stopService(intent)
	}

	fun minimizeApp(activity: Activity) {
		activity.moveTaskToBack(true)
	}
}
