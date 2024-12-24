import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  static final _storage = GetStorage();
  static const _rejectedTripsKey = 'rejected_trips';

  // إضافة رحلة إلى قائمة الرحلات المرفوضة
  static void addRejectedTrip(String tripId) {
    final rejectedTrips = getRejectedTrips();
    rejectedTrips.add(tripId);
    _storage.write(_rejectedTripsKey, rejectedTrips.toList());
  }

  // الحصول على قائمة الرحلات المرفوضة
  static Set<String> getRejectedTrips() {
    final List<dynamic>? rejectedTrips = _storage.read(_rejectedTripsKey);
    return rejectedTrips?.map((e) => e.toString()).toSet() ?? {};
  }

  // مسح قائمة الرحلات المرفوضة
  static void clearRejectedTrips() {
    _storage.remove(_rejectedTripsKey);
  }
}
