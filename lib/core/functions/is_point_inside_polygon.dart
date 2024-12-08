import 'package:google_maps_flutter/google_maps_flutter.dart';

bool isPointInsidePolygons(LatLng point, Set polygonPoints) {
    List points = polygonPoints.toList();
    int i, j = points.length - 1;
    bool oddNodes = false;

    for (i = 0; i < points.length; i++) {
        if ((points[i].latitude < point.latitude && points[j].latitude >= point.latitude ||
                points[j].latitude < point.latitude && points[i].latitude >= point.latitude) &&
            (points[i].longitude <= point.longitude || points[j].longitude <= point.longitude)) {
            if (points[i].longitude + (point.latitude - points[i].latitude) /
                    (points[j].latitude - points[i].latitude) *
                    (points[j].longitude - points[i].longitude) <
                point.longitude) {
                oddNodes = !oddNodes;
            }
        }
        j = i;
    }

    return oddNodes;
}
