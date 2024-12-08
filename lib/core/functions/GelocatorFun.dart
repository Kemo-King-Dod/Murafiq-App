import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/utils/systemVarible.dart';

class Gelocatorfun {
  static Future<Position> getCurrentPosition() async {
    

    bool LocationEnabled;
    LocationPermission permission;

    LocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (!LocationEnabled) {
      return Future.error('الرجاء تفعيل الموقع');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      // Get the current location
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.

        return Future.error('الرجاء السماح بالوصول الى الموقع');
      }
    } else if (permission == LocationPermission.deniedForever) {
      return Future.error('الرجاء اعادة تثبيت التطبيق');
    }

    return await Geolocator.getCurrentPosition();
  }
}
