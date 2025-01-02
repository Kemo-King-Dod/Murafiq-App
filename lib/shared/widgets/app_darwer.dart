import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:murafiq/auth/auth_controller.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/driver/private/screens/driver_notifications_page.dart';
import 'package:murafiq/driver/private/screens/driver_profile_page.dart';
import 'package:murafiq/driver/private/screens/driver_trip_history_page.dart';
import 'package:murafiq/driver/private/screens/driver_wallet_page.dart';
import 'package:murafiq/driver/public/controllers/driver_profile_controller.dart';
import 'package:murafiq/main.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDarwer {
  static Widget buildDrawer({UserType? userType}) {
    final AuthController authController = Get.find<AuthController>();
    return Drawer(
      backgroundColor: systemColors.white,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                color: systemColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person,
                                size: 40, color: Colors.blue),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shared!.getString("user_name").toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                shared!.getString("user_phone").toString(),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                children: [
                  _buildDrawerItem(
                    icon: Icons.person_outline,
                    title: 'الملف الشخصي',
                    iconColor: Colors.blue[700],
                    onTap: () {
                      Get.back();
                      Get.to(() => DriverProfilePage(userType: userType));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.history_rounded,
                    title: 'السجل',
                    iconColor: Colors.purple[400],
                    onTap: () {
                      Get.back();
                      Get.to(() => DriverTripHistoryPage(userType: userType!));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'المحفظة',
                    iconColor: Colors.green[600],
                    onTap: () {
                      Get.back();
                      Get.to(() => DriverWalletPage(
                            userType: userType!,
                          ));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications_rounded,
                    title: 'الإشعارات',
                    iconColor: Colors.orange[600],
                    onTap: () {
                      Get.back();
                      Get.to(() => DriverNotificationsPage());
                    },
                  ),
                  const Divider(height: 40),
                  _buildDrawerItem(
                    icon: FontAwesomeIcons.whatsapp,
                    iconColor: const Color(0xFF25D366),
                    title: 'المساعدة والدعم',
                    onTap: () {
                      Get.back();
                      _launchURL('whatsapp');
                    },
                  ),
                  _buildDrawerItem(
                    icon: FontAwesomeIcons.facebook,
                    iconColor: const Color(0xFF1877F2),
                    title: 'صفحتنا على فيسبوك',
                    onTap: () {
                      _launchURL('facebook');
                      Get.back();
                    },
                  ),
                  const Divider(height: 40),
                  _buildDrawerItem(
                    icon: Icons.logout_rounded,
                    title: 'تسجيل الخروج',
                    iconColor: Colors.red[600],
                    textColor: Colors.red[600],
                    onTap: () {
                      Get.back();
                      authController.logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.grey[600])!.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.grey[600],
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  static Future<void> _launchURL(String type) async {
    if (type == 'whatsapp') {
      final respons = await sendRequestWithHandler(
        endpoint: '/public/get-whatsapp-url',
        method: 'GET',
        loadingMessage: "جاري التحميل",
      );

      final urls = respons['data']['whatsappUrl'].toString();
      final urls2 = respons['data']['whatsappUrl2'].toString();

      const phoneNumber = '0927775066';
      try {
        // تجربة فتح الواتساب مباشرة
        var url = Uri.parse(urls);

        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true,
              enableDomStorage: true,
            ),
          );
        } else {
          // محاولة ثانية باستخدام رابط API
          url = Uri.parse(urls2);
          if (await canLaunchUrl(url)) {
            await launchUrl(
              url,
              mode: LaunchMode.platformDefault,
              webViewConfiguration: const WebViewConfiguration(
                enableJavaScript: true,
                enableDomStorage: true,
              ),
            );
          } else {
            Get.snackbar(
              'خطأ',
              'الرجاء التأكد من تثبيت تطبيق الواتساب',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      } catch (e) {
        print("WhatsApp Error: $e");
        Get.snackbar(
          'خطأ',
          'حدث خطأ أثناء فتح الواتساب',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      final respons = await sendRequestWithHandler(
        endpoint: '/public/get-facebook-url',
        method: 'GET',
        loadingMessage: "جاري التحميل",
      );

      try {
        final Uri url = Uri.parse(respons['data']['facebookUrl'].toString());
        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true,
              enableDomStorage: true,
            ),
          );
        } else {
          Get.snackbar(
            'خطأ',
            'لا يمكن فتح الرابط',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print("URL Error: $e");
        Get.snackbar(
          'خطأ',
          'حدث خطأ أثناء فتح الرابط',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
