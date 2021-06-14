package com.pravera.geofence_service.service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.location.LocationManager

class LocationProviderIntentReceiver: BroadcastReceiver() {
	override fun onReceive(context: Context, intent: Intent) {
		if (intent.action != LocationManager.PROVIDERS_CHANGED_ACTION) return

		intent.setClass(context, LocationProviderIntentService::class.java)
		LocationProviderIntentService.enqueueWork(context, intent)
	}
}
