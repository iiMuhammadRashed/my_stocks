import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/color_manager.dart';

class AlertItem extends StatelessWidget {
  final String symbol;
  final String name;
  final String logo;
  final String condition;
  final bool active;
  final ValueChanged<bool> onToggle;

  const AlertItem({
    super.key,
    required this.symbol,
    required this.name,
    required this.logo,
    required this.condition,
    required this.active,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? ColorManager.cardDark : ColorManager.cardLight,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        spacing: 8.w,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 64,
            decoration: BoxDecoration(
              color: active
                  ? ColorManager.positive
                  : (isDark
                      ? ColorManager.textSecondaryDark.withOpacity(0.4)
                      : ColorManager.textSecondaryLight.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(50.r),
            child: Image.network(
              logo,
              width: 24.w,
              height: 24.w,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Column(
              spacing: 4.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: isDark
                        ? ColorManager.textPrimaryDark
                        : ColorManager.textPrimaryLight,
                  ),
                ),
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? ColorManager.textSecondaryDark
                        : ColorManager.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            spacing: 4.h,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                condition,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? ColorManager.textPrimaryDark
                      : ColorManager.textPrimaryLight,
                ),
              ),
              Switch(
                value: active,
                activeThumbColor: ColorManager.positive,
                inactiveThumbColor: Colors.grey[400],
                onChanged: onToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
