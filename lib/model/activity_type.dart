/// Define the type of activity.
enum ActivityType {
  IN_VEHICLE,
  ON_BICYCLE,
  ON_FOOT,
  RUNNING,
  STILL,
  TILTING,
  WALKING,
  UNKNOWN
}

/// Return the activity type from [value].
ActivityType getActivityTypeFromString(String value) {
  return ActivityType.values.firstWhere((e) {
    return e.toString() == 'ActivityType.$value';
  }, orElse: () => ActivityType.UNKNOWN);
}
