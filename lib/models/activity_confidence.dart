/// Define the confidence of activity.
enum ActivityConfidence {
  HIGH,
  MEDIUM,
  LOW
}

/// Return the activity confidence from [value].
ActivityConfidence getActivityConfidenceFromString(String value) {
  return ActivityConfidence.values.firstWhere((e) {
    return e.toString() == 'ActivityConfidence.$value';
  }, orElse: () => ActivityConfidence.LOW);
}
