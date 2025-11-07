import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'color_manager.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: ColorManager.backgroundLight,
    colorScheme: ColorScheme.light(
      primary: ColorManager.primary,
      surface: ColorManager.cardLight,
      onSurface: ColorManager.textPrimaryLight,
    ),
    appBarTheme: AppBarTheme(
      toolbarHeight: 48.h,
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: ColorManager.textPrimaryLight,
      ),
      iconTheme: IconThemeData(
        color: ColorManager.textPrimaryLight,
        size: 24.sp,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: ColorManager.textPrimaryLight,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        color: ColorManager.textPrimaryLight,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        color: ColorManager.textSecondaryLight,
      ),
      labelLarge: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: ColorManager.primary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorManager.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
      ),
    ),
    cardTheme: CardThemeData(
      color: ColorManager.cardLight,
      margin: EdgeInsets.all(8.w),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: ColorManager.backgroundDark,
    colorScheme: ColorScheme.dark(
      primary: ColorManager.primary,
      surface: ColorManager.cardDark,
      onSurface: ColorManager.textPrimaryDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: ColorManager.textPrimaryDark,
      ),
      iconTheme: IconThemeData(
        color: ColorManager.textPrimaryDark,
        size: 24.sp,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: ColorManager.textPrimaryDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        color: ColorManager.textPrimaryDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        color: ColorManager.textSecondaryDark,
      ),
      labelLarge: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: ColorManager.primary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorManager.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
      ),
    ),
    cardTheme: CardThemeData(
      color: ColorManager.cardDark,
      margin: EdgeInsets.all(8.w),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    ),
  );
}
