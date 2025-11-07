import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/color_manager.dart';
import '../../../../core/theme/ThemeProvider.dart';
import '../../../../core/utils/user_manager.dart';
import '../../../../services/data/hive_favorites_service.dart';
import '../../../search_stocks/data/models/stock_model.dart';
import '../../../search_stocks/data/repositories/stock_repository.dart';
import '../widget/stock_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isRefreshing = false;
  late final StockRepository repository;

  @override
  void initState() {
    super.initState();

    final userId = UserManager.getUserId();
    repository = StockRepository(userId: userId);

    _refreshStocksData();
  }

  Future<void> _refreshStocksData() async {
    if (mounted) setState(() => isRefreshing = true);

    try {
      await repository.refreshFavorites().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⚠️ Refresh timeout after 30 seconds');
          throw TimeoutException('Refresh took too long');
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Stocks refreshed'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Failed to refresh stocks: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text("MyStocks", style: theme.appBarTheme.titleTextStyle),
        actions: [
          ValueListenableBuilder(
            valueListenable:
                Hive.box<StockModel>(HiveFavoritesService.favoritesBox)
                    .listenable(),
            builder: (context, Box<StockModel> box, _) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    '⭐ ${box.length}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                size: 24.sp,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
              tooltip: themeProvider.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable:
                Hive.box<StockModel>(HiveFavoritesService.favoritesBox)
                    .listenable(),
            builder: (context, Box<StockModel> box, _) {
              if (box.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_chart_outlined,
                          size: 80.sp, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text(
                        "No stocks added yet.",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: Colors.grey),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Tap + to add your first stock",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final stocks = box.values.toList();

              return RefreshIndicator(
                onRefresh: _refreshStocksData,
                child: ListView.separated(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: stocks.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final stock = stocks[index];
                    return StockCard(
                      symbol: stock.symbol,
                      name: stock.name,
                      price: stock.currentPrice,
                      change: stock.percentChange,
                      onTap: () => context.push(RouteConstants.stockDetails,
                          extra: stock),
                      onDelete: () async {
                        try {
                          await repository.removeFavorite(stock.symbol);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Stock deleted successfully",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          print(
                              'delete pressed============================================Failed to delete stock: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Failed to delete stock: $e",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              );
            },
          ),
          if (isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorManager.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        onPressed: () => context.push(RouteConstants.searchStocks),
        child: Icon(Icons.add, size: 28.sp, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Text(
          "${DateTime.now().year} All rights reserved",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall!.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
