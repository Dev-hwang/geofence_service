package com.pravera.geofence_service.activity_recognition

import android.app.IntentService
import android.content.Context
import android.content.Intent
import com.google.android.gms.location.ActivityRecognitionResult
import com.google.gson.Gson
import com.pravera.geofence_service.Constant
import com.pravera.geofence_service.errors.ErrorCodes

class ActivityRecognitionIntentService: IntentService("ARIntentService") {
	companion object {
		const val TAG = "ARIntentService"
	}

	private lateinit var gson: Gson

	override fun onCreate() {
		super.onCreate()
		gson = Gson()
	}

	override fun onHandleIntent(intent: Intent?) {
		val extractedResult = ActivityRecognitionResult.extractResult(intent)
		val probableActivities = extractedResult.probableActivities
		val mostProbableActivity = probableActivities.maxBy { it.confidence } ?: return

		val activityData = ActivityData(
				ActivityRecognitionUtils.getActivityTypeFromInt(mostProbableActivity.type),
				ActivityRecognitionUtils.getActivityConfidenceFromInt(mostProbableActivity.confidence))

		var prefsKey: String
		var prefsValue: String
		try {
			prefsKey = Constant.ACTIVITY_DATA_PREFS_KEY
			prefsValue = gson.toJson(activityData)
//			Log.d(TAG, "Activity updates. ($prefsValue)")
		} catch (e: Exception) {
			prefsKey = Constant.ACTIVITY_ERROR_PREFS_KEY
			prefsValue = ErrorCodes.ACTIVITY_DATA_ENCODING_FAILED.toString()
//			Lod.d(TAG, "There was an error encoding the activity data. ${e.printStackTrace()}")
		}

		val prefs = getSharedPreferences(
				Constant.ACTIVITY_RECOGNITION_RESULT_PREFS_NAME, Context.MODE_PRIVATE) ?: return
		with (prefs.edit()) {
			putString(prefsKey, prefsValue)
			commit()
		}
	}
}
