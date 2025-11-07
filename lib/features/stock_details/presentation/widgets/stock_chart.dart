import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../search_stocks/data/models/stock_model.dart';
import '../../data/services/time_series_service.dart';

enum TimePeriod { oneDay, fiveDays, oneMonth, oneYear }

class StockChart extends StatefulWidget {
  final StockModel stock;

  const StockChart({super.key, required this.stock});

  @override
  State<StockChart> createState() => _StockChartState();
}

class _StockChartState extends State<StockChart> {
  TimePeriod selectedPeriod = TimePeriod.oneDay;
  final TimeSeriesService _service = TimeSeriesService();
  List<TimeSeriesPoint>? timeSeriesData;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final config = _getConfigForPeriod(selectedPeriod);
      final data = await _service.getTimeSeries(
        widget.stock.symbol,
        interval: config['interval']!,
        outputsize: int.parse(config['outputsize']!),
      );

      setState(() {
        timeSeriesData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print('Error loading chart data: $e');
    }
  }

  Map<String, String> _getConfigForPeriod(TimePeriod period) {
    switch (period) {
      case TimePeriod.oneDay:
        return {'interval': '5min', 'outputsize': '78'};
      case TimePeriod.fiveDays:
        return {'interval': '1h', 'outputsize': '120'};
      case TimePeriod.oneMonth:
        return {'interval': '1day', 'outputsize': '30'};
      case TimePeriod.oneYear:
        return {'interval': '1week', 'outputsize': '52'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Column(
        children: [
          _buildTimePeriodButtons(theme),
          SizedBox(height: 12.h),
          Expanded(
            child: isLoading
                ? _buildLoadingState(theme)
                : error != null
                    ? _buildErrorState(theme)
                    : timeSeriesData == null || timeSeriesData!.isEmpty
                        ? _buildNoDataPlaceholder(context)
                        : _buildChart(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodButtons(ThemeData theme) {
    return Row(
      children: [
        _buildPeriodButton('1D', TimePeriod.oneDay, theme),
        SizedBox(width: 6.w),
        _buildPeriodButton('5D', TimePeriod.fiveDays, theme),
        SizedBox(width: 6.w),
        _buildPeriodButton('1M', TimePeriod.oneMonth, theme),
        SizedBox(width: 6.w),
        _buildPeriodButton('1Y', TimePeriod.oneYear, theme),
      ],
    );
  }

  Widget _buildPeriodButton(String label, TimePeriod period, ThemeData theme) {
    final isSelected = selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPeriod = period;
          });
          _loadChartData();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorManager.primary
                : theme.colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : theme.hintColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 11.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: CircularProgressIndicator(
        color: ColorManager.primary,
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
          SizedBox(height: 8.h),
          Text(
            'Failed to load chart',
            style: TextStyle(color: theme.hintColor, fontSize: 14.sp),
          ),
          SizedBox(height: 4.h),
          TextButton(
            onPressed: _loadChartData,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(ThemeData theme) {
    final spots = timeSeriesData!
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.close))
        .toList();

    final prices = timeSeriesData!.map((e) => e.close).toList();
    final yMax = prices.reduce((a, b) => a > b ? a : b);
    final yMin = prices.reduce((a, b) => a < b ? a : b);
    final range = yMax - yMin;
    final safeInterval = range == 0 ? 1.0 : range / 5;

    final isPositive =
        timeSeriesData!.first.close <= timeSeriesData!.last.close;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: safeInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.dividerColor.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: spots.length > 5 ? spots.length / 4 : 1,
              reservedSize: 28.h,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= timeSeriesData!.length) {
                  return const SizedBox.shrink();
                }

                final point = timeSeriesData![index];
                String label = _formatDateLabel(point.datetime);

                return Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: safeInterval,
              reservedSize: 42.w,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: EdgeInsets.only(right: 4.w),
                  child: Text(
                    '\$${value.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        minY: yMin - (safeInterval * 0.2),
        maxY: yMax + (safeInterval * 0.2),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            curveSmoothness: 0.35,
            color: isPositive ? ColorManager.positive : ColorManager.negative,
            barWidth: 2.5,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isPositive ? ColorManager.positive : ColorManager.negative)
                      .withOpacity(0.15),
                  (isPositive ? ColorManager.positive : ColorManager.negative)
                      .withOpacity(0.0),
                ],
              ),
            ),
            spots: spots,
            dotData: FlDotData(
              show: spots.length < 30,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: isPositive
                      ? ColorManager.positive
                      : ColorManager.negative,
                  strokeWidth: 1.5,
                  strokeColor: theme.colorScheme.surface,
                );
              },
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipRoundedRadius: 8.r,
            tooltipPadding:
                EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            getTooltipColor: (touchedSpot) => theme.colorScheme.surface,
            tooltipBorder: BorderSide(
              color: theme.dividerColor.withOpacity(0.3),
              width: 1,
            ),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < timeSeriesData!.length) {
                  final point = timeSeriesData![index];
                  return LineTooltipItem(
                    '\$${spot.y.toStringAsFixed(2)}\n${_formatTooltipDate(point.datetime)}',
                    TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                      height: 1.3,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          getTouchLineStart: (data, index) => 0,
          getTouchLineEnd: (data, index) => 0,
        ),
      ),
    );
  }

  String _formatDateLabel(DateTime date) {
    switch (selectedPeriod) {
      case TimePeriod.oneDay:
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      case TimePeriod.fiveDays:
        return '${date.day}/${date.month}';
      case TimePeriod.oneMonth:
        return '${date.day}/${date.month}';
      case TimePeriod.oneYear:
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return months[date.month - 1];
    }
  }

  String _formatTooltipDate(DateTime date) {
    switch (selectedPeriod) {
      case TimePeriod.oneDay:
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      case TimePeriod.fiveDays:
      case TimePeriod.oneMonth:
        return '${date.day}/${date.month}/${date.year}';
      case TimePeriod.oneYear:
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return '${months[date.month - 1]} ${date.year}';
    }
  }

  Widget _buildNoDataPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48.sp,
              color: theme.hintColor,
            ),
            SizedBox(height: 8.h),
            Text(
              'No chart data available',
              style: TextStyle(
                color: theme.hintColor,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
