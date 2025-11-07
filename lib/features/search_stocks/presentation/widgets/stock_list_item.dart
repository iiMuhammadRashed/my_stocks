import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/color_manager.dart';

class StockItem extends StatelessWidget {
  final String symbol;
  final String name;
  final double? price;
  final double? changePercent;
  final VoidCallback? onAdd;
  final bool isAdded;
  final bool isLoading;

  const StockItem({
    super.key,
    required this.symbol,
    required this.name,
    this.price,
    this.changePercent,
    required this.onAdd,
    this.isAdded = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPositive = (changePercent ?? 0) >= 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Card(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: ColorManager.primary.withOpacity(0.15),
                child: Text(
                  symbol.isNotEmpty ? symbol[0] : "?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorManager.primary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                        color: isDark
                            ? ColorManager.textPrimaryDark
                            : ColorManager.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      symbol,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13.sp,
                        color: ColorManager.primary.withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price != null ? "\$${price!.toStringAsFixed(2)}" : "--",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? ColorManager.textPrimaryDark
                          : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      changePercent != null
                          ? "${isPositive ? '+' : ''}${changePercent!.toStringAsFixed(2)}%"
                          : "--",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
              isLoading
                  ? SizedBox(
                      width: 26.sp,
                      height: 26.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ColorManager.primary,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        isAdded ? Icons.check_circle : Icons.add_circle_outline,
                        color: isAdded ? Colors.grey : ColorManager.primary,
                        size: 26.sp,
                      ),
                      onPressed: onAdd,
                      tooltip: isAdded ? "Added" : "Add to favorites",
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
