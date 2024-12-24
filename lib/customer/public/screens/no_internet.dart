import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:murafiq/customer/public/screens/customer_home_page.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'لا يوجد اتصال بالإنترنت',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'يرجى التحقق من اتصالك بالإنترنت',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkInternetAndRedirect,
              child: Text('إعادة المحاولة'),
            )
          ],
        ),
      ),
    );
  }

  void _checkInternetAndRedirect() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      // إعادة التوجيه للصفحة الرئيسية
      Get.offAll(() => CustomerHomePage());
    }
  }
}