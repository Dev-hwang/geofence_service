package com.pravera.geofence_service.permission

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.pravera.geofence_service.Constant
import com.pravera.geofence_service.errors.ErrorCodes
import io.flutter.plugin.common.PluginRegistry

class PermissionManager: PluginRegistry.RequestPermissionsResultListener {
	companion object {
		const val TAG = "PermissionManager"
	}

	private var activity: Activity? = null
	private var errorCallback: ((ErrorCodes) -> Unit)? = null
	private var resultCallback: ((PermissionResult) -> Unit)? = null

  fun checkPermission(activity: Activity, permission: String): PermissionResult {
		// if your device is below Android 10, the system automatically grant permission.
		if (permission == Manifest.permission.ACTIVITY_RECOGNITION
				&& Build.VERSION.SDK_INT < Build.VERSION_CODES.Q)
			return PermissionResult.GRANTED

		if (ContextCompat.checkSelfPermission(activity,
						permission) == PackageManager.PERMISSION_GRANTED) {
			return PermissionResult.GRANTED
		} else {
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
				val prevPermissionResult = getPreviousPermissionResult(activity, permission)
//				Log.d(TAG, "prevPermissionResult: $prevPermissionResult")

				if (prevPermissionResult != null
						&& prevPermissionResult == PermissionResult.PERMANENTLY_DENIED
						&& !activity.shouldShowRequestPermissionRationale(permission))
					return PermissionResult.PERMANENTLY_DENIED
			}

			return PermissionResult.DENIED
		}
  }

  fun requestPermission(
			activity: Activity,
			permission: String, 
			requestCode: Int, 
			resultCallback: ((PermissionResult) -> Unit), 
			errorCallback: ((ErrorCodes) -> Unit)) {
		// if your device is under Android 10, the system automatically grant permission.
		if (permission == Manifest.permission.ACTIVITY_RECOGNITION 
				&& Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
			resultCallback(PermissionResult.GRANTED)
			return
		}

		this.activity = activity
		this.errorCallback = errorCallback
		this.resultCallback = resultCallback

		ActivityCompat.requestPermissions(activity, arrayOf(permission), requestCode)
  }

	private fun savePermissionResult(
			activity: Activity?, permission: String, result: PermissionResult) {
    val prefs = activity?.getSharedPreferences(
				Constant.PERMISSION_RESULT_PREFS_NAME, Context.MODE_PRIVATE) ?: return

		with (prefs.edit()) {
			putString(permission, result.toString())
			commit()
		}
	}

	private fun getPreviousPermissionResult(
			activity: Activity?, permission: String): PermissionResult? {
		val prefs = activity?.getSharedPreferences(
				Constant.PERMISSION_RESULT_PREFS_NAME, Context.MODE_PRIVATE) ?: return null

		val value = prefs.getString(permission, null) ?: return null
		return PermissionResult.valueOf(value)
	}

  override fun onRequestPermissionsResult(
			requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
		if (grantResults.isEmpty()) {
			errorCallback?.invoke(ErrorCodes.PERMISSION_REQUEST_CANCELLED)
			return false
		}

		val pIndex: Int
		val pString: String
		var pResult: PermissionResult = PermissionResult.DENIED

		when (requestCode) {
			Constant.ACTIVITY_RECOGNITION_PERMISSION_REQ_CODE -> {
				pString = Manifest.permission.ACTIVITY_RECOGNITION
				pIndex = permissions.indexOf(pString)

				if (pIndex >= 0 && (grantResults[pIndex] == PackageManager.PERMISSION_GRANTED)) {
					pResult = PermissionResult.GRANTED
				} else {
					if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
							&& activity?.shouldShowRequestPermissionRationale(pString) == false)
						pResult = PermissionResult.PERMANENTLY_DENIED
				}
			}
			else -> return false
		}
		
		savePermissionResult(activity, pString, pResult)
		resultCallback?.invoke(pResult)

    return true
  }
}
