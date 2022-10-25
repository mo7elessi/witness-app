import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MySizes {
  static const double widgetSideSpace = 16.0;
  static const double verticalSpace = 8.0;
  static const double horizontalSpace = 8.0;
  static const double title = 16.0;
  static const double subtitle = 14.0;
  static const double details = 12.0;
  static const double elevation = 8.0;
  static const double sheetRadius = 10.0;
  static const double radius = 4.0;
  static const double borderWidth = .3;
  static const double buttonHeight = 55.0;
  static const double imageHeight = 100.0;
  static const double imageWidth = 100.0;
  static const double imageRadius = 100.0;
  static const double videoItemHeight = 110.0;
}

class MyColors {
  static const Color primaryColor = Color(0xFFFF1100);
  static const Color scaffoldBackgroundColor = Color(0xFFFAF9F9);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color iconsColor = Color(0xFF8F8F8F);
  static const Color borderColor = Color(0xFFC0C0C0);
}

final OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(MySizes.radius),
    borderSide: const BorderSide(
      width: MySizes.borderWidth,
      color: MyColors.borderColor,
    ));

class Themes {
  static ThemeData theme = ThemeData(
  fontFamily: "Lato-Regular",
    primaryColor: MyColors.primaryColor,
    primarySwatch: Colors.red,
    scaffoldBackgroundColor: MyColors.scaffoldBackgroundColor,
    backgroundColor: MyColors.backgroundColor,
    iconTheme: const IconThemeData(
      color: MyColors.iconsColor,
    ),
    appBarTheme: const AppBarTheme(
      elevation: MySizes.elevation,
      color: MyColors.primaryColor,
      backwardsCompatibility: false,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: MyColors.primaryColor,
      ),
      titleTextStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: MyColors.backgroundColor,
      filled: true,
      prefixStyle: const TextStyle(color: MyColors.primaryColor),
      enabledBorder: outlineInputBorder,
      errorBorder: outlineInputBorder,
      focusedErrorBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: MySizes.elevation,
    ),
  );
}
