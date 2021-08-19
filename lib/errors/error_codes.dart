import 'package:flutter/services.dart';

/// Error codes that may occur in the service.
enum ErrorCodes {
  /// Occurs when the service has already been started but the start function is called.
  ALREADY_STARTED,

  /// Occurs when location services are disabled.
  /// When this error occurs, you should notify the user and request activation.
  LOCATION_SERVICES_DISABLED,

  /// Occurs when location permission is denied.
  LOCATION_PERMISSION_DENIED,

  /// Occurs when location permission is permanently denied.
  /// In this case, the user must manually allow the permission.
  LOCATION_PERMISSION_PERMANENTLY_DENIED,

  /// Occurs when activity recognition permission is denied.
  ACTIVITY_RECOGNITION_PERMISSION_DENIED,

  /// Occurs when activity recognition permission is permanently denied.
  /// In this case, the user must manually allow the permission.
  ACTIVITY_RECOGNITION_PERMISSION_PERMANENTLY_DENIED
}

/// Returns the error codes from [value].
ErrorCodes? getErrorCodesFromString(String value) {
  final errorCodes = ErrorCodes.values.where((e) =>
      e.toString() == value ||
      e.toString() == 'ErrorCodes.${value.toUpperCase()}');

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

  return getErrorCodesFromString(error.toString());
}
