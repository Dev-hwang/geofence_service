package com.pravera.geofence_service

import android.app.Activity
import com.pravera.geofence_service.errors.ErrorCodes
import com.pravera.geofence_service.service.LocationProviderStatusWatcher

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/** LocationServiceStatusStreamHandlerImpl */
class LocationServiceStatusStreamHandlerImpl: EventChannel.StreamHandler {
	private lateinit var locationProviderStatusWatcher: LocationProviderStatusWatcher
	private lateinit var eventChannel: EventChannel

	private var activity: Activity? = null

	fun startListening(messenger: BinaryMessenger) {
		locationProviderStatusWatcher = LocationProviderStatusWatcher()
		eventChannel = EventChannel(messenger, "geofence_service/location_service_status")
		eventChannel.setStreamHandler(this)
	}

	fun stopListening() {
		if (::eventChannel.isInitialized)
			eventChannel.setStreamHandler(null)
	}

	fun setActivity(activity: Activity?) {
		this.activity = activity
	}

	@Suppress("SameParameterValue")
	private fun handleError(events: EventChannel.EventSink?, errorCode: ErrorCodes) {
		events?.error(errorCode.toString(), null, null)
	}

	override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
		if (activity == null) return
		locationProviderStatusWatcher.start(activity!!, listener = { events?.success(it) })
	}

	override fun onCancel(arguments: Any?) {
		if (activity == null) return
		locationProviderStatusWatcher.stop(activity!!)
	}
}
