import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.backgroundPrimary,
  primaryColor: AppColors.accentPrimary,
  fontFamily: "Inter",
  
  colorScheme: const ColorScheme.dark(
    primary: AppColors.accentPrimary,
    secondary: AppColors.accentSecondary,
    surface: AppColors.backgroundSecondary,
    error: Colors.red,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: AppColors.textPrimary,
    onError: Colors.white,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundPrimary,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontFamily: "Inter",
      fontWeight: FontWeight.w700,
      fontSize: 20,
    ),
  ),

  textTheme: const TextTheme(
    displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w400),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.backgroundSecondary,
    selectedItemColor: AppColors.textPrimary,
    unselectedItemColor: AppColors.textSecondary,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
);
