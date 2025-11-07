import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../search_stocks/data/models/stock_model.dart';

class StockStatsGrid extends StatelessWidget {
  final StockModel stock;

  const StockStatsGrid({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final stats = [
      {
        "label": "Open",
        "value": stock.open > 0 ? "\$${stock.open.toStringAsFixed(2)}" : "N/A"
      },
      {
        "label": "High",
        "value": stock.high > 0 ? "\$${stock.high.toStringAsFixed(2)}" : "N/A"
      },
      {
        "label": "Low",
        "value": stock.low > 0 ? "\$${stock.low.toStringAsFixed(2)}" : "N/A"
      },
      {
        "label": "Prev Close",
        "value": stock.previousClose > 0
            ? "\$${stock.previousClose.toStringAsFixed(2)}"
            : "N/A"
      },
      {"label": "Volume", "value": stock.formattedVolume},
      {"label": "Avg Volume", "value": stock.formattedAverageVolume},
      {"label": "Market Cap", "value": stock.formattedMarketCap},
      {"label": "Exchange", "value": stock.exchange},
      {"label": "Currency", "value": stock.currency},
      {"label": "52W High", "value": stock.fiftyTwoWeekHigh ?? "N/A"},
      {"label": "52W Low", "value": stock.fiftyTwoWeekLow ?? "N/A"},
      {
        "label": "MIC Code",
        "value": stock.micCode.isNotEmpty ? stock.micCode : "N/A"
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: stats.length,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 52.h,
        mainAxisSpacing: 6.h,
        crossAxisSpacing: 6.w,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stat["label"]!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    fontSize: 12.sp,
                    height: 1.0,
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Text(
                  stat["value"]!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                    height: 1.0,
                    letterSpacing: -0.2,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
