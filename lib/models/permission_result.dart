/// Define the type of permission request result.
enum PermissionResult {
  GRANTED,
  DENIED,
  PERMANENTLY_DENIED
}

/// Return the permission result from [value].
PermissionResult getPermissionResultFromString(String value) {
  return PermissionResult.values.firstWhere((e) {
    return e.toString() == 'PermissionResult.$value';
  }, orElse: () => PermissionResult.PERMANENTLY_DENIED);
}
