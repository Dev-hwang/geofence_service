package com.pravera.geofence_service.service

import android.content.Context
import android.content.Intent
import androidx.core.app.JobIntentService
import com.pravera.geofence_service.Constants
import com.pravera.geofence_service.utils.LocationServiceUtils

class LocationProviderIntentService: JobIntentService() {
	companion object {
		fun enqueueWork(context: Context, intent: Intent) {
			enqueueWork(context, LocationProviderIntentService::class.java,
					Constants.LOCATION_PROVIDER_INTENT_SERVICE_JOB_ID, intent)
		}
	}

	override fun onHandleWork(intent: Intent) {
		LocationServiceUtils.checkLocationServiceEnabled(applicationContext) {
			val prefs = getSharedPreferences(Constants.LOCATION_SERVICE_STATUS_PREFS_NAME,
					Context.MODE_PRIVATE) ?: return@checkLocationServiceEnabled

			if (prefs.getBoolean(Constants.LOCATION_SERVICE_STATUS_PREFS_KEY, true) == it)
				return@checkLocationServiceEnabled

			with(prefs.edit()) {
				putBoolean(Constants.LOCATION_SERVICE_STATUS_PREFS_KEY, it)
				commit()
			}
		}
	}
}
