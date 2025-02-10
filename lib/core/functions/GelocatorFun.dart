import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:murafiq/core/constant/citiesBoundries.dart';
import 'package:murafiq/core/functions/is_point_inside_polygon.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/models/trip.dart';

class LocationService {
  static AlertDialog dialog(String title, String message) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
    );
  }

  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // التحقق من تفعيل خدمة الموقع
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        Get.snackbar(
          'خطأ',
          'الرجاء تفعيل خدمة الموقع',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }

      // التحقق من الأذونات
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
          Get.dialog(dialog('خطأ', 'لم يتم السماح بالوصول إلى الموقع'));
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        Get.dialog(dialog('خطأ', 'يرجى تفعيل إذن الموقع من إعدادات التطبيق'));
        return null;
      }

      // الحصول على الموقع الحالي
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      print("Error getting location: $e");
      Get.dialog(dialog('خطأ', 'حدث خطأ أثناء الحصول على الموقع'));
      return null;
    }
  }

  static Future<bool> handleLocationPermission({bool isDriver = false}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('تنبيه', 'الرجاء تفعيل خدمة الموقع في إعدادات جهازك',
          snackPosition: SnackPosition.TOP,
          colorText: Colors.white,
          backgroundColor: Colors.indigo);
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'تنبيه',
          'لم يتم السماح بالوصول إلى الموقع',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'تنبيه',
        'يرجى تفعيل إذن الموقع من إعدادات التطبيق',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  static Future<String?> getCityName({double? lat, double? lng}) async {
    if (isPointInsidePolygons(LatLng(lat!, lng!), Qatronboundaries)) {
      return City.alQatrun.name;
    }
    if (isPointInsidePolygons(LatLng(lat, lng), Sebhaboundaries)) {
      return City.sabha.name;
    }
    if (isPointInsidePolygons(LatLng(lat, lng), QasirMasaoodboundaries)) {
      return City.qasrMasud.name;
    }
    if (isPointInsidePolygons(LatLng(lat, lng), Bakhiboundaries)) {
      return City.alBakhi.name;
    }
    if (isPointInsidePolygons(LatLng(lat, lng), Aljensiaboundaries)) {
      return City.alJinsiya.name;
    }
    return "OUT";
  }
}
