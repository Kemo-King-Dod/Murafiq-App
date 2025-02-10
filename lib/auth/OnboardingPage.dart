import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/constant/AppRoutes.dart';
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
            // "https://images.pexels.com/photos/5647586/pexels-photo-5647586.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
          ];
    List labels = [
      "السلام عليكم".tr,
      "اهلا بكم".tr,
      "توصيل الى جميع انحاء قطرون".tr,
      "تسرنا خدمتكم".tr,
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
                                          height: Get.height / 2,
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
                              height: Get.height / 1.5,
                              autoPlay: true,
                              onPageChanged: (index, reason) {
                                controller.current(index);
                              }))),
                  Positioned(
                      top: Get.height / 2 + 40,
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
                    top: Get.height / 2,
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
                        padding:
                            EdgeInsets.symmetric(vertical: Get.height * 0.04),
                        height: Get.height / 2.5,
                        width: Get.width,
                        decoration: BoxDecoration(
                            color: systemColors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30)),
                            boxShadow: [
                              BoxShadow(
                                color: systemColors.dark.withValues(alpha: 0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, -3),
                              )
                            ]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 20,
                          children: [
                            Container(
                              height: 55,
                              width: Get.width * 0.8,
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                elevation: 2,
                                color: systemColors.primary,
                                onPressed: () {
                                  Get.toNamed(Approutes.loginPage);
                                },
                                child: Text(
                                  "تسجيل الدخول".tr,
                                  style: systemTextStyle.veryLargLight.copyWith(
                                    fontSize: 20,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 55,
                              width: Get.width * 0.8,
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                      color: systemColors.primary,
                                      width: 2,
                                    )),
                                elevation: 0,
                                color: systemColors.primaryGoust,
                                onPressed: () {
                                  Get.toNamed(Approutes.customerSignupPage);
                                },
                                child: Text(
                                  "انشاء حساب".tr,
                                  style:
                                      systemTextStyle.veryLargPrimary.copyWith(
                                    fontSize: 20,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                            // TextButton(
                            //   onPressed: () {
                            //     Get.toNamed(Approutes.userHomePage);
                            //   },
                            //   child: Text(
                            //     "الدخول كزائر".tr,
                            //     style: systemTextStyle.mediumPrimary.copyWith(
                            //       decoration: TextDecoration.underline,
                            //       decorationColor:
                            //           systemColors.primary.withValues(alpha:0.5),
                            //       fontSize: 16,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      )),
                  Positioned(
                    top: 40,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: systemColors.dark.withValues(alpha: 0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
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
                          items:
                              Languges.map((item) => DropdownMenuItem<String>(
                                    value: item["code"],
                                    child: Text(
                                      item["label"]!,
                                      style: const TextStyle(
                                        fontSize: 16,
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
                              height: 45,
                              width: 120,
                              decoration: BoxDecoration(
                                  color: systemColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: systemColors.primary
                                        .withValues(alpha: 0.3),
                                    width: 1,
                                  ))),
                          menuItemStyleData: MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                  color: systemColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: systemColors.primary
                                        .withValues(alpha: 0.3),
                                    width: 1,
                                  ))),
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
