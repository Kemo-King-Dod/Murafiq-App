import 'package:flutter/material.dart';
import 'systemVarible.dart';

class AppTextStyles {
  static const String fontFamily = 'Tajawal';

  // Heading Styles
  static TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
    color: systemColors.dark,
  );

  static TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
    color: systemColors.dark,
  );

  static TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
    color: systemColors.dark,
  );

  // Body Text Styles
  static TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    color: systemColors.dark,
  );

  static TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: fontFamily,
    color: systemColors.dark,
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontFamily: fontFamily,
    color: systemColors.darkGoust,
  );

  // Button Styles
  static TextStyle buttonLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
    color: systemColors.white,
  );

  static TextStyle buttonMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
    color: systemColors.white,
  );

  // Caption and Label Styles
  static TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    fontFamily: fontFamily,
    color: systemColors.darkGoust,
  );

  static TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    color: systemColors.dark,
  );
}
