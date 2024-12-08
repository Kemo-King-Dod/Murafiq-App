import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class systemTextStyle {
  static String fontName = "Tajawal";

  // ___________________________ light ________________________________
  static TextStyle veryLargLight =
      TextStyle(fontSize: 28, color: Color(0xFFFFFFFF), fontFamily: fontName);
  static TextStyle largeLight =
      TextStyle(fontSize: 24, color: Color(0xFFFFFFFF), fontFamily: fontName);
  static TextStyle mediumLight =
      TextStyle(fontSize: 18, color: Color(0xFFFFFFFF), fontFamily: fontName);
  static TextStyle smallLight =
      TextStyle(fontSize: 16, color: Color(0xFFFFFFFF), fontFamily: fontName);
  static TextStyle verySmallLight =
      TextStyle(fontSize: 14, color: Color(0xFFFFFFFF), fontFamily: fontName);

  // ___________________________ primary ________________________________
  static TextStyle veryLargPrimary = TextStyle(
      fontSize: 28, color: systemColors.primary, fontFamily: fontName);
  static TextStyle largePrimary = TextStyle(
      fontSize: 24, color: systemColors.primary, fontFamily: fontName);
  static TextStyle mediumPrimary = TextStyle(
      fontSize: 18, color: systemColors.primary, fontFamily: fontName);
  static TextStyle smallPrimary = TextStyle(
      fontSize: 16, color: systemColors.primary, fontFamily: fontName);
  static TextStyle verySmallPrimary = TextStyle(
      fontSize: 14, color: systemColors.primary, fontFamily: fontName);

  // ___________________________ dark ________________________________
  static TextStyle veryLargDark =
      TextStyle(fontSize: 28, color: Color(0xFF000000), fontFamily: fontName);
  static TextStyle largeDark =
      TextStyle(fontSize: 24, color: Color(0xFF000000), fontFamily: fontName);
  static TextStyle mediumDark =
      TextStyle(fontSize: 18, color: Color(0xFF000000), fontFamily: fontName);
  static TextStyle smallDark =
      TextStyle(fontSize: 16, color: Color(0xFF000000), fontFamily: fontName);
  static TextStyle verySmallDark =
      TextStyle(fontSize: 14, color: Color(0xFF000000), fontFamily: fontName);
  // ___________________________ dark ________________________________
  static TextStyle veryLargSucsse = TextStyle(
      fontSize: 28, color: systemColors.sucsses, fontFamily: fontName);
  static TextStyle largeSucsse = TextStyle(
      fontSize: 24, color: systemColors.sucsses, fontFamily: fontName);
  static TextStyle mediumSucsse = TextStyle(
      fontSize: 18, color: systemColors.sucsses, fontFamily: fontName);
  static TextStyle smallSucsse = TextStyle(
      fontSize: 16, color: systemColors.sucsses, fontFamily: fontName);
  static TextStyle verySmallSucsse = TextStyle(
      fontSize: 14, color: systemColors.sucsses, fontFamily: fontName);

  // __________________________Goust__________________________________

  static TextStyle meduimGoustLabel = TextStyle(
    fontFamily: fontName,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: systemColors.darkGoust,
  );
  static TextStyle veryLargeGoustLabel = TextStyle(
    fontFamily: fontName,
    fontSize: 30,
    fontWeight: FontWeight.w400,
    color: systemColors.darkGoust,
  );

  static TextStyle largeGoustLabel = TextStyle(
    fontFamily: fontName,
    fontSize: 24,
    color: systemColors.darkGoust,
  );

  static TextStyle smallGoustLabel = TextStyle(
    fontFamily: fontName,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: systemColors.darkGoust,
  );
  static TextStyle verysmallGoustLabel = TextStyle(
    fontFamily: fontName,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: systemColors.darkGoust,
  );
}

class systemColors {
  static Color primary = Color(0xFF0045a4);
  static Color primaryGoust = Color.fromARGB(255, 219, 234, 255);
  static Color white = Color(0xFFFFFFFF);
  static Color dark = Color(0xFF000000);
  static Color sucsses = CupertinoColors.systemGreen;
  static Color error = CupertinoColors.systemRed;
  static const Color darkGoust = Color.fromARGB(164, 70, 80, 108);
  static const Color lightGoust = Color.fromARGB(121, 159, 183, 255);
}

class systemUtils {
  static loadingPop(String title) {
    Get.dialog(
        barrierDismissible: false,
        PopScope(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              contentPadding: EdgeInsets.all(20),
              backgroundColor: systemColors.white,
              content: SizedBox(
                height: 150,
                width: 150,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: SpinKitWave(
                        itemCount: 4,
                        color: systemColors
                            .primary, // يمكنك تغيير اللون حسب تفضيلك
                        size: 40.0,
                        duration: Duration(
                          seconds: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      title.tr,
                      style: systemTextStyle.mediumDark,
                    )
                  ],
                ),
              ),
            ),
          ),
          canPop: true,
        ));
  }

  static loadingNotPop(String title) {
    Get.dialog(
        barrierDismissible: false,
        PopScope(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              contentPadding: EdgeInsets.all(20),
              backgroundColor: systemColors.white,
              content: SizedBox(
                height: 150,
                width: 150,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: SpinKitWave(
                        itemCount: 4,
                        color: systemColors
                            .primary, // يمكنك تغيير اللون حسب تفضيلك
                        size: 40.0,
                        duration: Duration(
                          seconds: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      title.tr,
                      style: systemTextStyle.mediumDark,
                    )
                  ],
                ),
              ),
            ),
          ),
          canPop: false,
        ));
  }

  static blockingNotPop(String title) {
    Get.dialog(
        barrierDismissible: false,
        PopScope(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              contentPadding: EdgeInsets.all(20),
              backgroundColor: systemColors.white,
              content: SizedBox(
                height: 150,
                width: 150,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Center(
                        child: Text(
                            "للأسف لقد تم حظرك من استخدام التطبيق \n عليك مراجعة مكتبة البيرق او الاتصال بالرقم ${0927775066}")),
                    SizedBox(height: 20),
                    Text(
                      title.tr,
                      style: systemTextStyle.mediumDark,
                    )
                  ],
                ),
              ),
            ),
          ),
          canPop: false,
        ));
  }

  static isToken() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String? isToken = sharedPref.getString('token');
    bool istoken = isToken != null || isToken != "" ? true : false;
    return istoken;
  }

  static getToken() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String? isToken = await sharedPref.getString('token');
    return isToken != null || isToken != "" ? isToken : false;
  }

  static getValue(String key) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String? value = await sharedPref.getString('${key}');
    if (value == null) {
      return "";
    }
    return;
  }

  static setToken(String token) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setString('token', token);
  }

  static setUserType(String type) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setString('userType', type);
  }

  static setUserid(String id) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setString('userId', id);
  }

  static signinagain() async {
    await Get.dialog(
        barrierDismissible: false,
        PopScope(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              contentPadding: EdgeInsets.all(20),
              backgroundColor: systemColors.white,
              content: Wrap(children: [
                Container(
                  height: 170,
                  child: Text(
                    "تم رفض الطلب الرجاء تسجيل الدخول  ",
                    style: systemTextStyle.largeDark,
                  ),
                ),
                Container(
                  width: 150,
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: MaterialButton(
                    onPressed: () {
                      logout();
                    },
                    child: Text(
                      "تم",
                      style: systemTextStyle.largeLight,
                    ),
                    color: systemColors.primary,
                  ),
                )
              ]),
            ),
          ),
          canPop: false,
        ));
    logout();
  }

  static logout() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await sharedPref.remove("token");
    await sharedPref.remove("userType");
    await sharedPref.remove("userId");
  }

  static setString(String key, String value) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setString(key, value);
  }

  static getString(
    String key,
  ) async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String? value = await sharedPref.getString(key);
    return value;
  }
}

class systemFunc {
  static Timer? _timer;
  static Timer? _timer2;

  static void startInterval(Duration time, Function again) {
    _timer?.cancel(); // تأكد من إيقاف التايمر السابق إذا كان موجودًا
    _timer = Timer.periodic(time, (Timer timer) async {
      await again();
    });
  }

  static void startInterval2(Duration time, Function again) {
    _timer2?.cancel(); // تأكد من إيقاف التايمر السابق إذا كان موجودًا
    _timer2 = Timer.periodic(time, (Timer timer) async {
      await again();
    });
  }

  static void stopInterval() {
    _timer?.cancel(); // إيقاف التايمر
    _timer2?.cancel(); // إيقاف التايمر
    _timer = null;
    _timer2 = null;
    print("is stop");
  }
}

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // تهيئة الإشعارات مع استخدام onDidReceiveNotificationResponse
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          onSelectNotification, // تحديد دالة التفاعل عند الضغط على الإشعار
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotification, // تحديد دالة للتفاعل مع الإشعار في الخلفية
    );

    // إنشاء قناة للإشعارات
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'messages_channel',
      'New Messages',
      description: 'This channel is used for new message notifications.',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // التفاعل مع الإشعار عند الضغط عليه
  static Future<void> onSelectNotification(
      NotificationResponse response) async {
    // هنا يمكنك معالجة الاستجابة عند الضغط على الإشعار
    print("Notification clicked with payload: ${response.payload}");
    String? payload = response.payload;
    // يمكن إضافة منطق للتنقل إلى شاشة معينة بناءً على الـ payload أو الـ id
    if (response.payload != null) {
      print('Payload: ${response.payload}');
      // إذا كانت البيانات تحتوي على معرّف أو تفاصيل معينة، يمكنك التنقل إلى الشاشة المناسبة
      if (payload != null) {
        if (payload == "notification") {}
      }
    }
  }

  // التفاعل مع الإشعار في الخلفية
  static Future<void> onBackgroundNotification(
      NotificationResponse response) async {
    // التعامل مع الإشعار عند الضغط عليه بينما التطبيق في الخلفية
    print("Background Notification clicked with payload: ${response.payload}");
    // هنا يمكنك معالجة الاستجابة عند الضغط على الإشعار
    String? payload = response.payload;
    // يمكن إضافة منطق للتنقل إلى شاشة معينة بناءً على الـ payload أو الـ id
    if (response.payload != null) {
      print('Payload: ${response.payload}');
      // إذا كانت البيانات تحتوي على معرّف أو تفاصيل معينة، يمكنك التنقل إلى الشاشة المناسبة
      if (payload != null) {
        if (payload == "notification") {}
      }
    }
  }

  // إرسال إشعار محلي
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'messages_channel', // معرف فريد للقناة
      'New Messages',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload, // إرسال البيانات مع الإشعار
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}


// class LocalNotificationService {
//   static final FlutterLocalNotificationsPlugin
//       _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   // تهيئة الإشعارات المحلية
// static Future<void> initialize() async {
//   const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

//   const initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//   );

//   await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onSelectNotification: onSelectNotification, // تحديد دالة التفاعل مع الضغط على الإشعار
//     );

//   // إنشاء القناة إذا لم تكن موجودة
//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'messages_channel', // معرف فريد للقناة
//     'New Messages',
//     description: 'This channel is used for new message notifications.',
//     importance: Importance.high,
//   );

//   await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//       AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
// }


//   // إرسال إشعار محلي
//   static Future<void> showNotification({
//     required int id,
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     print("hellow notification");
//     const androidDetails = AndroidNotificationDetails(
//       'messages_channel', // معرف فريد للقناة
//       'New Messages',
//       importance: Importance.high,
//       priority: Priority.high,
//       ticker: 'ticker',
//     );
//     const notificationDetails = NotificationDetails(
//       android: androidDetails,
//     );

//     try {
//       await _flutterLocalNotificationsPlugin.show(
//         id,
//         title,
//         body,
//         notificationDetails,
//         payload: payload,
//       );
//     } catch (e) {
//       print('Error showing notification: $e');
//     }
//   }

//   // التفاعل مع الإشعار عند الضغط عليه
//   static Future<void> onSelectNotification(String? payload) async {
//     // تنفيذ ما ترغب به عند الضغط على الإشعار
//     print("Notification Payload: $payload");
//   }
// }
