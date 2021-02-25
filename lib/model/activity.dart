import 'package:geofence_service/model/activity_confidence.dart';
import 'package:geofence_service/model/activity_type.dart';

/// Data class that define user activity.
class Activity {
  /// Type of activity recognized.
  ActivityType type;

  /// Confidence of activity recognized.
  ActivityConfidence confidence;

  /// Return the internal field of the class in map format.
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'confidence': confidence
    };
  }

  /// Create and Return [Activity] from [map].
  Activity.fromMap(Map<String, dynamic> map) {
    type = getActivityTypeFromString(map['type']);
    confidence = getActivityConfidenceFromString(map['confidence']);
  }

  /// Get an activity of type unknown.
  static Activity get unknown => Activity
      .fromMap({'type': 'UNKNOWN', 'confidence': 'LOW'});

  @override
  bool operator ==(Object other) =>
      other is Activity
          && runtimeType == other.runtimeType
          && type == other.type
          && confidence == other.confidence;

  @override
  int get hashCode => type.hashCode ^ confidence.hashCode;
}
