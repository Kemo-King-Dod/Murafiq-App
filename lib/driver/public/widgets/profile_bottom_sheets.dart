import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/driver/public/controllers/driver_profile_controller.dart';

class EditProfileBottomSheet extends StatelessWidget {
  final UserType userType;
  EditProfileBottomSheet({required this.userType, Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverProfileController>();

    // Pre-fill controllers
    _nameController.text = controller.driverName.value;
    _phoneController.text = controller.phoneNumber.value;
    _vehicleTypeController.text = controller.vehicleType.value;

    return Container(
      padding: EdgeInsets.all(20),
      height: Get.height * 0.7,
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'تعديل الملف الشخصي',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: systemColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildProfileImageUploader(controller),
            SizedBox(height: 15),
            _buildTextFormField(
              controller: _nameController,
              label: 'الاسم',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            // _buildTextFormField(

            //   controller: _phoneController,
            //   label: 'رقم الهاتف',
            //   icon: Icons.phone,
            //   keyboardType: TextInputType.phone,
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'الرجاء إدخال رقم الهاتف';
            //     }
            //     return null;
            //   },
            // ),
            SizedBox(height: 15),
            userType == UserType.driver
                ? _buildTextFormField(
                    controller: _vehicleTypeController,
                    label: 'نوع المركبة',
                    icon: Icons.directions_car,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال نوع المركبة';
                      }
                      return null;
                    },
                  )
                : SizedBox.shrink(),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // TODO: Implement actual profile update logic
                  final response = await sendRequestWithHandler(
                    endpoint: '/public/update-profile',
                    method: 'PATCH',
                    loadingMessage: "جاري تحديث الملف الشخصي",
                    body: {
                      'name': _nameController.text,
                      if (userType == UserType.driver)
                        'vehicle_type': _vehicleTypeController.text,
                    },
                  );
                  if (response != null &&
                      response['status'] == 'success' &&
                      response['data'] != null) {
                    Get.back();
                    Get.snackbar(
                      'نجاح',
                      'تم تحديث الملف الشخصي',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: systemColors.sucsses,
                      colorText: Colors.white,
                    );
                    controller.driverName.value = _nameController.text;
                    if (userType == UserType.driver) {
                      controller.vehicleType.value =
                          _vehicleTypeController.text;
                    }
                  }
                }
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: systemColors.primary,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'حفظ التغييرات',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageUploader(DriverProfileController controller) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 70,
            backgroundColor: systemColors.primary.withValues(alpha: 0.1),
            backgroundImage: controller.profileImageUrl.value.isNotEmpty
                ? NetworkImage(controller.profileImageUrl.value)
                : null,
            child: controller.profileImageUrl.value.isEmpty
                ? Icon(
                    Icons.person,
                    size: 70,
                    color: systemColors.primary,
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: systemColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
                onPressed: () {
                  // TODO: Implement image picker
                  Get.snackbar(
                    'قريبًا',
                    'سيتم إضافة خيار تغيير الصورة',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: systemColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: systemColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: systemColors.primary, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}

class ChangePasswordBottomSheet extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverProfileController>();
    return Container(
      padding: EdgeInsets.all(20),
      height: Get.height * 0.5,
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'تغيير كلمة المرور',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: systemColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildPasswordField(
              controller: _currentPasswordController,
              label: 'كلمة المرور الحالية',
              icon: Icons.lock_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال كلمة المرور الحالية';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'كلمة المرور الجديدة',
              icon: Icons.lock_open,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال كلمة المرور الجديدة';
                }
                if (value.length < 6) {
                  return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'تأكيد كلمة المرور الجديدة',
              icon: Icons.lock,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء تأكيد كلمة المرور الجديدة';
                }
                if (value != _newPasswordController.text) {
                  return 'كلمتا المرور غير متطابقتين';
                }
                return null;
              },
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // TODO: Implement actual password change logic
                  final response = await sendRequestWithHandler(
                    endpoint: '/public/update-password',
                    method: 'PATCH',
                    loadingMessage: "جاري تحديث كلمة المرور",
                    body: {
                      'new_password': _newPasswordController.text,
                      'confirm_password': _confirmPasswordController.text,
                      'current_password': _currentPasswordController.text,
                    },
                  );
                  print(response.toString());

                  Get.back();
                  Get.snackbar(
                    'نجاح',
                    'تم تغيير كلمة المرور بنجاح',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: systemColors.sucsses,
                    colorText: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: systemColors.primary,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'تغيير كلمة المرور',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: systemColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: systemColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: systemColors.primary, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
