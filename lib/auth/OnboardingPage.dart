import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';

import 'package:murafiq/core/locale/LocaleController.dart';
import 'package:murafiq/main.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Localecontroller localecontroller = Get.find();
    List images = shared!.getStringList("initImages") != null
        ? shared!.getStringList("initImages")!
        : [
            "assets/images/onboarding/pexels-photo-2570216.jpeg",
            "assets/images/onboarding/pexels-photo-3639294.jpeg",
            "assets/images/onboarding/pexels-photo-5835447.jpeg",
            "assets/images/onboarding/pexels-photo-12176473.jpeg",
            "https://images.pexels.com/photos/5647586/pexels-photo-5647586.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
          ];
    List labels = [
      "السلام عليكم",
      "اهلا بكم",
      "توصيل الى جميع انحاء قطرون",
      "تسرنا خدمتكم",
    ];
    final List<Map<String, String>> Languges = [
      {"label": "العربية", "code": "ar"},
      {"label": "الانجليزية", "code": "en"},
      {"label": "الفرنسية", "code": "fr"},
    ];

    return Scaffold(
      backgroundColor: Colors.amber,
      body: GetBuilder<CarosulController>(
          init: CarosulController(),
          builder: (controller) {
            return Container(
              color: Colors.blue,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Container(
                      color: systemColors.dark,
                      alignment: Alignment.topCenter,
                      width: Get.width,
                      height: Get.height,
                      child: CarouselSlider(
                          carouselController: controller.controller,
                          items: images
                              .map((image) => Container(
                                  width: Get.width,
                                  child: image.contains("http")
                                      ? CachedNetworkImage(
                                          imageUrl: image,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.black12,
                                          ),
                                          height: 500,
                                          width: 1000,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.blueGrey,
                                              alignment: Alignment.center,
                                            );
                                          },
                                          image,
                                          height: 500,
                                          width: 1000,
                                          fit: BoxFit.cover,
                                        )))
                              .toList(),
                          options: CarouselOptions(
                              aspectRatio: 1.5,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                              height: 500,
                              autoPlay: true,
                              onPageChanged: (index, reason) {
                                controller.current(index);
                              }))),
                  Positioned(
                      top: 370,
                      left: Get.width / 2 + 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: images.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () =>
                                controller.controller.animateToPage(entry.key),
                            child: AnimatedContainer(
                              width: entry.key == controller.currentPage
                                  ? 20
                                  : 6.0,
                              height: 5.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: entry.key == controller.currentPage
                                      ? systemColors.primary
                                      : systemColors.white),
                              duration: Duration(milliseconds: 300),
                            ),
                          );
                        }).toList(),
                      )),
                  Positioned(
                    top: 400,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Container(
                          width: Get.width,
                          height: 200,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, systemColors.dark],
                          )),
                          child: Stack(
                            children: labels.asMap().entries.map((entry) {
                              return AnimatedOpacity(
                                duration: Duration(milliseconds: 300),
                                opacity: entry.key == controller.currentPage
                                    ? 1
                                    : 0.0,
                                alwaysIncludeSemantics: true,
                                child: Text(
                                  "${labels[entry.key]}".tr,
                                  style: systemTextStyle.veryLargLight.copyWith(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                          )),
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 50),
                        height: 350,
                        width: Get.width,
                        decoration: BoxDecoration(
                            color: systemColors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20))),
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                minWidth: 250,
                                color: systemColors.primary,
                                onPressed: () {
                                  Get.toNamed("/login");
                                },
                                child: Text(
                                  "تسجيل الدخول".tr,
                                  style: systemTextStyle.veryLargLight,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 50,
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                                minWidth: 250,
                                color: systemColors.primaryGoust,
                                onPressed: () {
                                  Get.toNamed("/customer-signup");
                                },
                                child: Text(
                                  "انشاء حساب".tr,
                                  style: systemTextStyle.veryLargPrimary,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              child: MaterialButton(
                                onPressed: () {
                                  Get.toNamed("/homepage");
                                },
                                child: Text(
                                  "الدخول كزائر".tr,
                                  style: systemTextStyle.mediumPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  Positioned(
                    top: 40,
                    right: 10,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        hint: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'اللغة'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: systemColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        items: Languges.map((item) => DropdownMenuItem<String>(
                              value: item["code"],
                              child: Text(
                                item["label"]!,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            )).toList(),
                        value: controller.selectedValue,
                        onChanged: (String? value) {
                          localecontroller.chengeLang(value!);
                          controller.selectedValue = value;
                        },
                        buttonStyleData: ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            height: 50,
                            width: 120,
                            decoration: BoxDecoration(
                                color: systemColors.white,
                                borderRadius: BorderRadius.circular(10))),
                        menuItemStyleData: MenuItemStyleData(
                          height: 40,
                        ),
                        dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                                color: systemColors.white,
                                borderRadius: BorderRadius.circular(10))),
                        iconStyleData: IconStyleData(
                          icon: Icon(
                            Icons.arrow_forward_ios_outlined,
                          ),
                          iconSize: 14,
                          iconEnabledColor: systemColors.primary,
                          iconDisabledColor: Colors.grey,
                        ),
                        style: systemTextStyle.largePrimary,
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }
}

class CarosulController extends GetxController {
  GetImageFromServer() async {
    final response = await sendRequestWithHandler(
      endpoint: '/init/getImages',
      method: 'GET',
    );

    if (response != null && response['data'] != null) {
      shared!.setStringList("initImages", response['data']['images']);
    }
  }

  String? selectedValue;
  int currentPage = 0;
  CarouselSliderController controller = CarouselSliderController();

  void selectImage(int index) {
    controller.animateToPage(index);
    update();
  }

  void current(int index) {
    currentPage = index;
    update();
  }
}
