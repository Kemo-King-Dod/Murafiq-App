// import 'dart:convert';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:murafiq/core/utils/systemVarible.dart';

// class CustomerOrDriver extends StatelessWidget {
//   const CustomerOrDriver({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<SignUpController>(
//         init: SignUpController(),
//         builder: (controller) {
//           return Container(
//             margin: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
//             decoration: BoxDecoration(
//               color: Color.fromARGB(10, 0, 0, 0),
//               borderRadius: BorderRadius.circular(30),
//             ),
//             height: 50,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       controller.ChosseCustomer();
//                     },
//                     child: Container(
//                       alignment: Alignment.center,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         color: !controller.driverSelected
//                             ? systemColors.primary
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       child: Text(
//                         "زبون".tr,
//                         style: !controller.driverSelected
//                             ? systemTextStyle.smallLight
//                             : systemTextStyle.smallDark,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       controller.ChosseDriver();
//                     },
//                     child: Container(
//                       alignment: Alignment.center,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         color: !controller.driverSelected
//                             ? Colors.transparent
//                             : systemColors.primary,
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       child: Text(
//                         "سائق".tr,
//                         style: controller.driverSelected
//                             ? systemTextStyle.smallLight
//                             : systemTextStyle.smallDark,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         });
//   }
// }

// // class DriverCards extends StatelessWidget {
// //   final String name;
// //   final int phone;
// //   final String gender;
// //   var id;
// //   var image;
// //   DriverCards(
// //       {Key? key,
// //       required this.name,
// //       required this.phone,
// //       required this.gender,
// //       this.id,
// //       this.image})
// //       : super(key: key);
// //   @override
// //   Widget build(BuildContext context) {
// //     HomepageController homepageController = Get.find<HomepageController>();
// //     return InkWell(
// //       onTap: () {
// //         homepageController.isThereDriver.value = true;
// //         homepageController.driverId = {
// //           'id': id,
// //         };

// //         Get.to(() => HomePage());
// //       },
// //       child: Container(
// //         margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
// //         width: Get.width,
// //         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
// //         decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(10),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.black26,
// //                 blurRadius: 5,
// //                 offset: Offset(0, 2),
// //                 spreadRadius: 1,
// //               )
// //             ],
// //             color: systemColors.white),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceAround,
// //           children: [
// //             CircleAvatar(
// //               backgroundColor: Colors.transparent,
// //               child: ClipRRect(
// //                 borderRadius: BorderRadius.circular(50),
// //                 child: CachedNetworkImage(
// //                     width: 80,
// //                     imageUrl:
// //                         "https://images.pexels.com/photos/18580753/pexels-photo-18580753/free-photo-of-bearded-old-man.jpeg",
// //                     fit: BoxFit.cover,
// //                     placeholder: (context, url) => Container(
// //                           color: Colors.black12,
// //                         )),
// //               ),
// //               radius: 40,
// //             ),
// //             SizedBox(
// //               width: 10,
// //             ),
// //             Column(
// //               children: [
// //                 Text(
// //                   "${name}",
// //                   style: systemTextStyle.largeDark,
// //                 ),
// //                 Row(
// //                   children: [
// //                     Text("متاح"),
// //                     SizedBox(
// //                       width: 10,
// //                     ),
// //                     Icon(
// //                       Icons.donut_large,
// //                       color: systemColors.sucsses,
// //                     )
// //                   ],
// //                 )
// //               ],
// //             )
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// class selectedDriverCards extends StatelessWidget {
//   const selectedDriverCards({
//     Key? key,
//   }) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 20),
//       width: Get.width,
//       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 5,
//               offset: Offset(0, 2),
//               spreadRadius: 1,
//             )
//           ],
//           color: systemColors.white),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.transparent,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(50),
//               child: CachedNetworkImage(
//                   width: 80,
//                   imageUrl:
//                       "https://images.pexels.com/photos/18580753/pexels-photo-18580753/free-photo-of-bearded-old-man.jpeg",
//                   fit: BoxFit.cover,
//                   placeholder: (context, url) => Container(
//                         color: Colors.black12,
//                       )),
//             ),
//             radius: 40,
//           ),
//           SizedBox(
//             width: 10,
//           ),
//           Column(
//             children: [
//               Text(
//                 "السائق",
//                 style: systemTextStyle.mediumPrimary,
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Text(
//                 "كمال ابراهيم عبد القادر",
//                 style: systemTextStyle.mediumDark,
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }

// class HistoryCard extends StatelessWidget {
//   final Map journey;

//   const HistoryCard({super.key, required this.journey});
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Container(
//       alignment: Alignment.centerRight,
//       padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//       width: Get.width - 40,
//       margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//       decoration: BoxDecoration(color: systemColors.white, boxShadow: [
//         BoxShadow(
//           color: Colors.black26,
//           blurRadius: 5,
//           offset: Offset(0, 2),
//           spreadRadius: 1,
//         )
//       ]),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Container(
//             width: 400,
//             child: Wrap(
//               children: [
//                 Text(
//                   textAlign: TextAlign.right,
//                   softWrap: true,
//                   textDirection: TextDirection.rtl,
//                   "رقم الرحلة".tr + ": ${journey["id"]}",
//                   style: systemTextStyle.mediumPrimary,
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             "اسم السائق".tr + " : ${journey["driverName"]}",
//             style: systemTextStyle.mediumPrimary,
//           ),
//           Text(
//             "رقم السائق".tr + ": ${journey["driverNum"]}",
//             style: systemTextStyle.mediumPrimary,
//           ),
//           Text(
//             " سعر الرحلة ".tr + " ${journey["price"]} د.ل",
//             style: systemTextStyle.mediumPrimary,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class NotificationCard extends StatelessWidget {
//    NotificationCard(
//       {Key? key, required this.messageBody, required this.isRead,this.title})
//       : super(key: key);
//   final String messageBody;
//   final bool isRead;
//   String ?title;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(boxShadow: [
//         BoxShadow(
//           color: Colors.grey.withOpacity(0.1),
//           blurRadius: 5,
//           spreadRadius: 2,
//           offset: Offset(0, 3),
//         )
//       ]),
//       child: Directionality(
//         textDirection: TextDirection.rtl,
//         child: Card(
//           color: Color.fromARGB(255, 255, 255, 255),
//           child: Badge(
//             backgroundColor: isRead ? systemColors.white : systemColors.error,
//             offset: Offset(10, 10),
//             smallSize: 10,
//             alignment: Alignment.topRight,
//             child: ListTile(
//               title: Text(
//                 title??"مرحبا",
//                 style: systemTextStyle.smallPrimary,
//               ),
//               subtitle: Text(
//                 messageBody,
//                 style: systemTextStyle.verySmallDark,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
