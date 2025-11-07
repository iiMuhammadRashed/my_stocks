import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/screens/dashboard.dart';

import '../../features/price_alerts/presentation/screens/StockAlertScreen.dart';
import '../../features/search_stocks/data/models/stock_model.dart';
import '../../features/search_stocks/presentation/screens/search_stocks_screen.dart';
import '../../features/splash/presentation/SplashScreen.dart';
import '../../features/stock_details/presentation/screens/stock_details_screen.dart';
import '../../features/error/presentation/connection_error_screen.dart';
import 'route_constants.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RouteConstants.splash,
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.dashboard,
        name: RouteConstants.dashboardName,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: RouteConstants.stockDetails,
        builder: (context, state) {
          final stock = state.extra as StockModel;
          return StockDetailsScreen(stock: stock);
        },
      ),
      GoRoute(
        path: RouteConstants.searchStocks,
        name: RouteConstants.searchStocksName,
        builder: (context, state) => const SearchStocksScreen(),
      ),
      GoRoute(
        path: RouteConstants.stockAlert,
        name: RouteConstants.stockAlertName,
        builder: (context, state) {
          final stock = state.extra as StockModel;
          return StockAlertScreen(stock: stock);
        },
      ),
      GoRoute(
        path: RouteConstants.connectionError,
        name: RouteConstants.connectionErrorName,
        builder: (context, state) => ConnectionErrorScreen(
          onRetry: () => context.go('/'),
        ),
      ),
    ],
  );
}
