package com.pravera.geofence_service.foreground_service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

open class ForegroundService: Service() {
	open var serviceId = 1000
	open var channelId = "geofence_service"
	open var channelName = "geofence_service"
	open var contentTitle = "Geofence Service"
	open var contentText = "Tap to return to the app using the service."

	override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
		val pm = applicationContext.packageManager
		val appIcon = getApplicationIcon(pm)
		val pIntent = getPendingIntent(pm)

		val bundle = intent?.extras
		channelId = bundle?.getString("notificationChannelId") ?: channelId
		channelName = bundle?.getString("notificationChannelName") ?: channelName
		contentTitle = bundle?.getString("notificationContentTitle") ?: contentTitle
		contentText = bundle?.getString("notificationContentText") ?: contentText

		val builder = NotificationCompat.Builder(this, channelId)
		builder.setOngoing(true)
		builder.setShowWhen(false)
		builder.setSmallIcon(appIcon)
		builder.setContentTitle(contentTitle)
		builder.setContentText(contentText)
		builder.setContentIntent(pIntent)
		builder.setVibrate(longArrayOf(0L))

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
			val importance = NotificationManager.IMPORTANCE_LOW
			val channel = NotificationChannel(channelId, channelName, importance)
			val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
			nm.createNotificationChannel(channel)
		}

		startForeground(serviceId, builder.build())
		return super.onStartCommand(intent, flags, startId)
	}

	override fun onBind(p0: Intent?): IBinder? {
		return null
	}

	private fun getApplicationIcon(pm: PackageManager): Int {
		return try {
			val appInfo = pm.getApplicationInfo(applicationContext.packageName, 0)
			appInfo.icon
		} catch (e: PackageManager.NameNotFoundException) {
			android.R.drawable.ic_menu_info_details
		}
	}

	private fun getPendingIntent(pm: PackageManager): PendingIntent {
		val lIntent = pm.getLaunchIntentForPackage(applicationContext.packageName)
		return PendingIntent.getActivity(this, 0, lIntent, 0)
	}
}
