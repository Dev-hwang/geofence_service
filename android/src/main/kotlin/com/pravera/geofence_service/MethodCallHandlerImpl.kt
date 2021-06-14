package com.pravera.geofence_service

import android.app.Activity
import androidx.annotation.NonNull
import com.pravera.geofence_service.errors.ErrorCodes

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** MethodCallHandlerImpl */
class MethodCallHandlerImpl: MethodChannel.MethodCallHandler {
	private lateinit var methodChannel: MethodChannel

	private var activity: Activity? = null

	fun startListening(messenger: BinaryMessenger) {
		methodChannel = MethodChannel(messenger, "geofence_service/method")
		methodChannel.setMethodCallHandler(this)
	}

	fun stopListening() {
		if (::methodChannel.isInitialized)
			methodChannel.setMethodCallHandler(null)
	}

	fun setActivity(activity: Activity?) {
		this.activity = activity
	}

	@Suppress("SameParameterValue")
	private fun handleError(result: MethodChannel.Result, errorCode: ErrorCodes) {
		result.error(errorCode.toString(), null, null)
	}

	override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
		if (activity == null) {
			handleError(result, ErrorCodes.ACTIVITY_NOT_REGISTERED)
			return
		}

		when (call.method) {
			else -> result.notImplemented()
		}
	}
}
