// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:murafiq/Pages/DriverPages/DriverHomePage.dart';
// import 'package:murafiq/core/utils/systemVarible.dart';

// Widget UserOrNot() => Container(
//       child: Column(
//         children: [
//           Container(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(100),
//               child: Image.asset(
//                 "assets/images/logo/logo.png",
//                 height: 150,
//                 width: 150,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           Container(
//             width: 200,
//             padding: EdgeInsets.symmetric(horizontal: 5),
//             child: MaterialButton(
//               onPressed: () {
//                 Get.to(() => Driverhomepage());
//               },
//               child: Text(
//                 "تسجيل الدخول ",
//                 style: systemTextStyle.smallLight,
//               ),
//               color: systemColors.primary,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5)),
//             ),
//           )
//         ],
//       ),
//     );
