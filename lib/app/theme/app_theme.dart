import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AppThemeData {
  static ThemeData get lightThemeData {
    return ThemeData(
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
      colorSchemeSeed: AppColors.primaryColor,
      brightness: Brightness.dark,
    );
  }
}