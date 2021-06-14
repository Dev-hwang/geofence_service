package com.pravera.geofence_service.service

import android.app.Activity
import android.content.*
import android.location.LocationManager
import com.pravera.geofence_service.Constants

class LocationProviderStatusWatcher: SharedPreferences.OnSharedPreferenceChangeListener {
	private var listener: ((Boolean) -> Unit)? = null
	private var broadcastReceiver: LocationProviderIntentReceiver? = null

	fun start(activity: Activity, listener: ((Boolean) -> Unit)) {
		this.listener = listener
		registerSharedPreferenceChangeListener(activity)
		registerLocationProviderIntentReceiver(activity)
	}

	fun stop(activity: Activity) {
		this.listener = null
		unregisterSharedPreferenceChangeListener(activity)
		unregisterLocationProviderIntentReceiver(activity)
	}

	private fun registerLocationProviderIntentReceiver(activity: Activity) {
		broadcastReceiver = LocationProviderIntentReceiver()
		val intentFilter = IntentFilter().apply {
			addAction(LocationManager.PROVIDERS_CHANGED_ACTION)
		}
		activity.registerReceiver(broadcastReceiver, intentFilter)
	}

	private fun unregisterLocationProviderIntentReceiver(activity: Activity) {
		activity.unregisterReceiver(broadcastReceiver)
		broadcastReceiver = null
	}

	private fun registerSharedPreferenceChangeListener(activity: Activity) {
		val prefs = activity.getSharedPreferences(Constants.LOCATION_SERVICE_STATUS_PREFS_NAME,
				Context.MODE_PRIVATE) ?: return
		prefs.registerOnSharedPreferenceChangeListener(this)
		with (prefs.edit()) {
			remove(Constants.LOCATION_SERVICE_STATUS_PREFS_KEY)
			commit()
		}
	}

	private fun unregisterSharedPreferenceChangeListener(activity: Activity) {
		val prefs = activity.getSharedPreferences(Constants.LOCATION_SERVICE_STATUS_PREFS_NAME,
				Context.MODE_PRIVATE) ?: return
		prefs.unregisterOnSharedPreferenceChangeListener(this)
	}

	override fun onSharedPreferenceChanged(sharedPreferences: SharedPreferences, key: String) {
		when (key) {
			Constants.LOCATION_SERVICE_STATUS_PREFS_KEY -> {
				val data = sharedPreferences.getBoolean(key, false)
				listener?.invoke(data)
			}
		}
	}
}
