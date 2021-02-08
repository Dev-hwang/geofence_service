package com.pravera.geofence_service.activity_recognition

import com.google.gson.annotations.SerializedName

data class ActivityData(
		@SerializedName("type") val type: String,
		@SerializedName("confidence") val confidence: String
)
