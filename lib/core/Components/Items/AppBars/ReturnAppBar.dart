import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/utils/systemVarible.dart';

class Returnappbar extends StatelessWidget implements PreferredSizeWidget {
  final height;
  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  Returnappbar({
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    // TODO: implement navigation to chat screen
                    scaffoldKey.currentState!.openEndDrawer();
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: systemColors.primary,
                  )),
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

class ReturnLabelappbar extends StatelessWidget implements PreferredSizeWidget {
  final height;
  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final String Label;
  ReturnLabelappbar({
    super.key,
    this.height,
    required this.Label,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                color: systemColors.white,
                child: IconButton(
                    onPressed: () {
                      // TODO: implement navigation to chat screen
                      Get.back();
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: systemColors.primary,
                    )),
              ),
              Expanded(
                child: Container(
                  child: Center(
                    child: Text(
                      Label,
                      style: systemTextStyle.mediumPrimary,
                    ),
                  ),
                ),
              ),
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

class Labelappbar extends StatelessWidget implements PreferredSizeWidget {
  final height;
  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final String Label;
  Labelappbar({
    super.key,
    this.height,
    required this.Label,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  child: Center(
                    child: Text(
                      Label,
                      style: systemTextStyle.mediumPrimary,
                    ),
                  ),
                ),
              ),
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
