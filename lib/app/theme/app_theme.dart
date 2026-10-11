import 'package:flutter/material.dart';
import 'package:ricardo/gen/fonts.gen.dart';
import '../utils/app_colors.dart';

class AppThemeData {
  static ThemeData get lightThemeData {
    return ThemeData(
      fontFamily: FontFamily.poppins,
      scaffoldBackgroundColor: Colors.white,
      brightness: Brightness.light,
        colorSchemeSeed: AppColors.primaryColor,
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.bgColor,
        ),


      bottomSheetTheme: BottomSheetThemeData(
      ),
    );
  }

  static ThemeData get darkThemeData {
    return ThemeData(
      fontFamily: FontFamily.poppins,
      colorSchemeSeed: AppColors.primaryColor,
      brightness: Brightness.dark,
    );
  }
}