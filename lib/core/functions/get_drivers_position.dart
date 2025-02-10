import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/core/functions/errorHandler.dart';

class GetDriversPosition {
  static getDriversPOS({required LatLng pos, required bool inTrip}) async {
    final response = await sendRequestWithHandler(
        method: "post",
        endpoint: "/public/drivers-pos",
        body: {"pos": pos, "inTrip": inTrip});
    print(response.toString());
    if (response != null && response["status"] == "success") {
      return response;
    } else {
      return null;
    }
  }
}
