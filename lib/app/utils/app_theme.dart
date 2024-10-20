import 'package:flutter/material.dart';
import 'package:lelang_fb/core/constants/color.dart';  

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,  
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'MotivaSans',
        ),
      ),
      fontFamily: 'MotivaSans',
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: 'MotivaSans', color: Colors.black),
        displayMedium: TextStyle(fontFamily: 'MotivaSans', color: Colors.black),
        displaySmall: TextStyle(fontFamily: 'MotivaSans', color: Colors.black),
        headlineLarge: TextStyle(fontFamily: 'MotivaSans', color: Colors.black),
        headlineMedium: TextStyle(fontFamily: 'MotivaSans', color: Colors.black),
        headlineSmall: TextStyle(fontFamily: 'MotivaSans', color: Colors.black),
        titleLarge: TextStyle(fontFamily: 'MotivaSans', color: Colors.black),
        titleMedium: TextStyle(fontFamily: 'MotivaSans', color: Colors.black),
        titleSmall: TextStyle(fontFamily: 'MotivaSans', color: Colors.black),
        bodyLarge: TextStyle(fontFamily: 'MotivaSans', color: Colors.black),
        bodyMedium: TextStyle(fontFamily: 'MotivaSans', color: Colors.black),
        bodySmall: TextStyle(fontFamily: 'MotivaSans', color: Colors.black),
        labelLarge: TextStyle(fontFamily: 'MotivaSans', color: Colors.black),
        labelMedium: TextStyle(fontFamily: 'MotivaSans', color: Colors.black),
        labelSmall: TextStyle(fontFamily: 'MotivaSans', color: Colors.black),
      ),
      colorScheme: ColorScheme.light(
        primary: AppColors.hijauTua,
        secondary: AppColors.hijauMuda,
        background: Colors.white,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: Colors.black,
        onSurface: Colors.black,

      ),

    );
  }

}
