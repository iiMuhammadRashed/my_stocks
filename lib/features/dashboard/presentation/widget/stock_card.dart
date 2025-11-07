import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/color_manager.dart';

class StockCard extends StatelessWidget {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const StockCard({
    super.key,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isPositive = change >= 0;

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 4.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price > 0 ? "\$${price.toStringAsFixed(2)}" : "Loading...",
                  style: theme.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: price > 0 ? null : Colors.grey,
                  ),
                ),
                SizedBox(height: 4.h),
                if (price > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isPositive
                            ? ColorManager.positive
                            : ColorManager.negative,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%",
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: isPositive
                              ? ColorManager.positive
                              : ColorManager.negative,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    "Pull to refresh",
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: Colors.grey,
                      fontSize: 11.sp,
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 22.sp,
              ),
              onPressed: onDelete,
              tooltip: 'Delete Stock',
            ),
          ],
        ),
      ),
    );
  }
}
