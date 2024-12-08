import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:murafiq/core/utils/systemVarible.dart';

class normalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final height;
  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  normalAppBar({
    super.key,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize:
          const Size.fromHeight(70.0), // ارتفاع الـ Container الذي يمثل AppBar
      child: SafeArea(
        child: Container(
          height: 100,
          padding: EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 5),
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              border: Border(
                  bottom: BorderSide(color: Color(0xFFF5F6F8), width: 2))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                  },
                  icon: Badge(
                    isLabelVisible:
                        true, // _________________تحديد ظهور الاشعار الجديد
                    backgroundColor: systemColors.error,
                    child: Icon(
                      Iconsax.sms_bold,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  )),
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        // TODO: implement navigation to chat screen
                        scaffoldKey.currentState!.openEndDrawer();
                      },
                      icon: Icon(
                        Iconsax.menu_1_bold,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(height ?? kToolbarHeight);

  // TODO: implement preferredSize
}
