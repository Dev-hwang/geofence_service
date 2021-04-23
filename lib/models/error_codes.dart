import 'package:flutter/services.dart';

/// Error codes that may occur in the service.
enum ErrorCodes {
  /// Occurs when the service has already been started but the start function is called.
  ALREADY_STARTED,

  /// Occurs when location service are disabled.
  /// When this error occurs, you should notify the user and request activation.
  LOCATION_SERVICE_DISABLED,

  /// Occurs when location permission is denied.
  LOCATION_PERMISSION_DENIED,

  /// Occurs when location permission is permanently denied.
  /// In this case, the user must manually allow the permission.
  LOCATION_PERMISSION_PERMANENTLY_DENIED,

  /// Occurs when activity recognition permission is denied.
  ACTIVITY_RECOGNITION_PERMISSION_DENIED,

  /// Occurs when activity recognition permission is permanently denied.
  /// In this case, the user must manually allow the permission.
  ACTIVITY_RECOGNITION_PERMISSION_PERMANENTLY_DENIED,

  /// Occurs when a method channel is called while an activity object is not registered.
  ACTIVITY_NOT_REGISTERED,

  /// Occurs when permission is cancelled.
  PERMISSION_REQUEST_CANCELLED,

  /// Stream Error
  /// Occurs when activity updates request fails.
  ACTIVITY_UPDATES_REQUEST_FAILED,

  /// Stream Error
  /// Occurs when activity updates remove fails.
  ACTIVITY_UPDATES_REMOVE_FAILED,

  /// Stream Error
  /// Occurs when an error occurs in encoding the recognized activity data.
  ACTIVITY_DATA_ENCODING_FAILED
}

/// Returns the error codes from [value].
ErrorCodes? getErrorCodesFromString(String value) {
  final errorCodes =
      ErrorCodes.values.where((e) => e.toString() == 'ErrorCodes.$value');

  if (errorCodes.isNotEmpty) return errorCodes.first;
  return null;
}

/// Returns the error codes from [error].
ErrorCodes? getErrorCodesFromError(dynamic error) {
  if (error is ErrorCodes) {
    return error;
  } else if (error is PlatformException) {
    PlatformException pe = error;
    return getErrorCodesFromString(pe.code);
  }

  return null;
}
