import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/color_manager.dart';

enum SnackType { success, error }

SnackBar buildStockSnackBar(
  BuildContext context, {
  required String message,
  required SnackType type,
}) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;

  final Color bgColor = switch (type) {
    SnackType.success => ColorManager.positive.withOpacity(0.1),
    SnackType.error => ColorManager.negative.withOpacity(0.1),
  };

  final Color iconColor = switch (type) {
    SnackType.success => ColorManager.positive,
    SnackType.error => ColorManager.negative,
  };

  return SnackBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    content: Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            type == SnackType.success ? Icons.check_circle : Icons.error,
            color: iconColor,
            size: 22.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDark
                    ? ColorManager.textPrimaryDark
                    : ColorManager.textPrimaryLight,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            child: Text(
              "DISMISS",
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
