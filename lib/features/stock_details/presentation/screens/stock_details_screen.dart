import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../services/data/hive_favorites_service.dart';
import '../../../search_stocks/data/models/stock_model.dart';
import '../widgets/stock_chart.dart';
import '../widgets/stock_stats_grid.dart';
import '../widgets/stock_bottom_actions.dart';

class StockDetailsScreen extends StatefulWidget {
  final StockModel stock;

  const StockDetailsScreen({super.key, required this.stock});

  @override
  State<StockDetailsScreen> createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();

    isFavorite = HiveFavoritesService.getFavorites()
        .any((item) => item.symbol == widget.stock.symbol);
  }

  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      await HiveFavoritesService.removeFavorite(widget.stock.symbol);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${widget.stock.symbol} removed from favorites')),
      );
    } else {
      await HiveFavoritesService.addFavorite(widget.stock);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.stock.symbol} added to favorites')),
      );
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    final stock = widget.stock;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          stock.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: textColor,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "\$${stock.currentPrice.toStringAsFixed(2)}",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: stock.change >= 0
                              ? ColorManager.positive.withOpacity(0.15)
                              : ColorManager.negative.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${stock.change >= 0 ? '+' : ''}\$${stock.change.toStringAsFixed(2)} "
                          "(${stock.percentChange >= 0 ? '+' : ''}${stock.percentChange.toStringAsFixed(2)}%)",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: stock.change >= 0
                                ? ColorManager.positive
                                : ColorManager.negative,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        stock.currency,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Last updated: ${stock.formattedDateTime}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 300.h,
                child: StockChart(stock: stock),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: StockStatsGrid(stock: stock),
            ),
          ],
        ),
      ),
      bottomNavigationBar: StockBottomActions(
        onAlert: () => context.pushNamed(
          RouteConstants.stockAlertName,
          extra: stock,
        ),
      ),
    );
  }
}
