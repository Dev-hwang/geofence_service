import 'dart:math';
import 'package:vector_math/vector_math.dart';

class LocationUtils {
  static double distanceBetween(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    final dLat = _toRadians(endLat - startLat);
    final dLon = _toRadians(endLon - startLon);

    final a = pow(sin(dLat / 2), 2) +
        pow(sin(dLon / 2), 2) *
            cos(_toRadians(startLat)) *
            cos(_toRadians(endLat));
    final c = 2 * asin(sqrt(a));

    return 6378137.0 * c;
  }

  static double bearingBetween(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    final startLatRadians = radians(startLat);
    final startLonRadians = radians(startLon);
    final endLatRadians = radians(endLat);
    final endLonRadians = radians(endLon);

    var y = sin(endLonRadians - startLonRadians) * cos(endLatRadians);
    var x = cos(startLatRadians) * sin(endLatRadians) -
        sin(startLatRadians) *
            cos(endLatRadians) *
            cos(endLonRadians - startLonRadians);

    return degrees(atan2(y, x));
  }

  static _toRadians(double degree) => degree * pi / 180;
}
