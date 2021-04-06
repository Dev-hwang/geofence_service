import 'package:flutter/services.dart';

/// Define the error codes that may occur in the service.
enum ErrorCodes {
  /// Occur when the service has already been started and the start function is called.
  ALREADY_STARTED,

  /// Occur when location service are disabled.
  /// When this error occur, you should notify the user and request activation.
  LOCATION_SERVICE_DISABLED,

  /// Occur when location permission is denied.
  LOCATION_PERMISSION_DENIED,

  /// Occur when location permission is permanently denied.
  /// In this case, the user must manually set the permission.
  LOCATION_PERMISSION_PERMANENTLY_DENIED,

  /// Occur when activity recognition permission is denied.
  ACTIVITY_RECOGNITION_PERMISSION_DENIED,

  /// Occur when activity recognition permission is permanently denied.
  /// In this case, the user must manually set the permission.
  ACTIVITY_RECOGNITION_PERMISSION_PERMANENTLY_DENIED,

  /// Occur when a channel is called when an activity object is not registered in the android platform.
  ACTIVITY_NOT_REGISTERED,

  /// Occur when permission is cancelled.
  PERMISSION_REQUEST_CANCELLED,

  /// Stream Error
  /// Occur when activity updates request fails.
  ACTIVITY_UPDATES_REQUEST_FAILED,

  /// Stream Error
  /// Occur when activity updates remove fails.
  ACTIVITY_UPDATES_REMOVE_FAILED,

  /// Stream Error
  /// Occur when an error occurs in encoding the recognized activity data.
  ACTIVITY_DATA_ENCODING_FAILED
}

/// Return the error codes from [value].
ErrorCodes? getErrorCodesFromString(String value) {
  final errorCodes = ErrorCodes.values
      .where((e) => e.toString() == 'ErrorCodes.$value');

  if (errorCodes.isNotEmpty)
    return errorCodes.first;

  return null;
}

/// Return the error codes from [error].
ErrorCodes? getErrorCodesFromError(dynamic error) {
  if (error is ErrorCodes) {
    return error;
  } else if (error is PlatformException) {
    PlatformException pe = error;
    return getErrorCodesFromString(pe.code);
  }

  return null;
}
