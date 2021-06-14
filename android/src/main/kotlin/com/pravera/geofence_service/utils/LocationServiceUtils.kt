package com.pravera.geofence_service.utils

import android.content.Context
import android.location.LocationManager
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.LocationSettingsRequest

class LocationServiceUtils {
	companion object {
		private fun isGooglePlayServicesAvailable(context: Context): Boolean {
			val googleApiAvailability: GoogleApiAvailability = GoogleApiAvailability.getInstance()
			val resultCode: Int = googleApiAvailability.isGooglePlayServicesAvailable(context)
			return resultCode == ConnectionResult.SUCCESS
		}

		fun checkLocationServiceEnabled(context: Context, listener: ((Boolean) -> Unit)) {
			if (isGooglePlayServicesAvailable(context)) {
				LocationServices.getSettingsClient(context)
						.checkLocationSettings(LocationSettingsRequest.Builder().build())
						.addOnCompleteListener {
							if (!it.isSuccessful) listener(false)

							val states = it.result.locationSettingsStates
							if (states != null)
								listener(states.isGpsUsable || states.isNetworkLocationUsable)
							else
								listener(false)
						}
			} else {
				val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
				val isGpsProviderEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
				val isNetProviderEnabled = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
				listener(isGpsProviderEnabled || isNetProviderEnabled)
			}
		}
	}
}
