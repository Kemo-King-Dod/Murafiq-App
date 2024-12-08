import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/utils/systemVarible.dart';

class DriverHistoryCard extends StatelessWidget {
  final Map card;
  DriverHistoryCard({Key? key, required this.card});
  @override
  Widget build(BuildContext context) {
    String name = "احمد ابراهيم";
    // TODO: implement build
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      width: Get.width - 40,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(color: systemColors.white, boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 5,
          offset: Offset(0, 2),
          spreadRadius: 1,
        )
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            softWrap: true,
            " رقم الرحلة  : \n ${card["_id"]}",
            style: systemTextStyle.mediumPrimary,
          ),
          Text(
            textDirection: TextDirection.rtl,
            softWrap: true,
            " حالة الرحلة  :  ${card["state"]}",
            style: systemTextStyle.mediumPrimary,
          ),
          Text(
            "اسم الراكب : ${card["MurafiqName"]}",
            style: systemTextStyle.mediumPrimary,
          ),
          Text(
            " رقم رقم الراكب : ${card["MurafiqNum"]}",
            style: systemTextStyle.mediumPrimary,
          ),
          Text(
            " سعر الرحلة  : ${card["price"]} د.ل",
            style: systemTextStyle.mediumPrimary,
          ),
          Text(
            "  مستحقات الشركة  : ${card["companyDous"]} د.ل",
            style: systemTextStyle.mediumPrimary,
          ),
        ],
      ),
    );
  }
}
