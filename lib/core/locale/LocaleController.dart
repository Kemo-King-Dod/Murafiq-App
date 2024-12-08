import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Localecontroller extends GetxController {
  Locale initialLang = shared!.getString("lang") == null
      ? Get.deviceLocale!
      : Locale(shared!.getString("lang")!);

  void chengeLang(String codeLang) async {
    systemUtils.setString("lang", codeLang);

    Locale _locale = Locale(codeLang);
    Get.updateLocale(_locale);
  }
}
