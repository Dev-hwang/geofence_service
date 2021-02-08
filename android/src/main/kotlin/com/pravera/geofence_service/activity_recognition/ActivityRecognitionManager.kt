package com.pravera.geofence_service.activity_recognition

import android.annotation.SuppressLint
import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import com.google.android.gms.location.ActivityRecognition
import com.google.android.gms.location.ActivityRecognitionClient
import com.pravera.geofence_service.Constant
import com.pravera.geofence_service.errors.ErrorCodes

class ActivityRecognitionManager: SharedPreferences.OnSharedPreferenceChangeListener {
	companion object {
		const val TAG = "ARManager"
		const val DETECTION_INTERVAL_MILLIS = 1000L
	}

	private var errorCallback: ((ErrorCodes) -> Unit)? = null
	private var successCallback: (() -> Unit)? = null
	private var updatesCallback: ((String) -> Unit)? = null

	private var pendingIntent: PendingIntent? = null
	private var serviceClient: ActivityRecognitionClient? = null

	fun startService(
			activity: Activity,
			updatesCallback: ((String) -> Unit),
			successCallback: (() -> Unit),
			errorCallback: ((ErrorCodes) -> Unit)) {

		if (serviceClient != null) {
			Log.d(TAG, "Activity updates already started.")
			stopService(activity, {}, {})
		}

		this.errorCallback = errorCallback
		this.successCallback = successCallback
		this.updatesCallback = updatesCallback

		registerSharedPreferenceChangeListener(activity)
		requestActivityUpdates(activity)
	}

	fun stopService(
			activity: Activity,
			successCallback: (() -> Unit),
			errorCallback: ((ErrorCodes) -> Unit)) {

		this.errorCallback = errorCallback
		this.successCallback = successCallback

		unregisterSharedPreferenceChangeListener(activity)
		removeActivityUpdates()

		this.errorCallback = null
		this.successCallback = null
		this.updatesCallback = null
	}

	private fun registerSharedPreferenceChangeListener(activity: Activity) {
		val prefs = activity.getSharedPreferences(
				Constant.ACTIVITY_RECOGNITION_RESULT_PREFS_NAME, Context.MODE_PRIVATE) ?: return
		prefs.registerOnSharedPreferenceChangeListener(this)
	}

	private fun unregisterSharedPreferenceChangeListener(activity: Activity) {
		val prefs = activity.getSharedPreferences(
				Constant.ACTIVITY_RECOGNITION_RESULT_PREFS_NAME, Context.MODE_PRIVATE) ?: return
		prefs.unregisterOnSharedPreferenceChangeListener(this)
	}

	@SuppressLint("MissingPermission")
	private fun requestActivityUpdates(activity: Activity) {
		pendingIntent = buildPendingIntentForService(activity)
		serviceClient = ActivityRecognition.getClient(activity)
		
		val task = serviceClient?.requestActivityUpdates(DETECTION_INTERVAL_MILLIS, pendingIntent)
		task?.addOnSuccessListener { successCallback?.invoke() }
		task?.addOnFailureListener { errorCallback?.invoke(ErrorCodes.ACTIVITY_UPDATES_REQUEST_FAILED) }
	}

	@SuppressLint("MissingPermission")
	private fun removeActivityUpdates() {
		val task = serviceClient?.removeActivityUpdates(pendingIntent)
		task?.addOnSuccessListener { successCallback?.invoke() }
		task?.addOnFailureListener { errorCallback?.invoke(ErrorCodes.ACTIVITY_UPDATES_REMOVE_FAILED) }

		pendingIntent = null
		serviceClient = null
	}

	private fun buildPendingIntentForService(activity: Activity): PendingIntent {
		val intent = Intent(activity, ActivityRecognitionIntentService::class.java)
		return PendingIntent.getService(activity, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
	}

	override fun onSharedPreferenceChanged(sharedPreferences: SharedPreferences, key: String) {
		when (key) {
			Constant.ACTIVITY_DATA_PREFS_KEY -> {
				val data = sharedPreferences.getString(key, null) ?: return
//				Log.d(TAG, "Received activity data. ($data)")
				updatesCallback?.invoke(data)
			}
			Constant.ACTIVITY_ERROR_PREFS_KEY -> {
				val error = sharedPreferences.getString(key, null) ?: return
//				Log.d(TAG, "Received error codes. ($error)")
				errorCallback?.invoke(ErrorCodes.valueOf(error))
			}
		}
	}
}
