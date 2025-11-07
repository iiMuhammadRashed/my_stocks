import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/price_alerts/data/stock_alert_model.dart';
import '../../features/search_stocks/data/repositories/stock_repository.dart';
import 'hive_alerts_service.dart';

class CachedPrice {
  final double price;
  final DateTime timestamp;

  CachedPrice(this.price, this.timestamp);

  bool get isExpired => DateTime.now().difference(timestamp).inSeconds > 45;
}

class AlertCheckerService {
  static Timer? _timer;
  static FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  static final Map<String, CachedPrice> _priceCache = {};

  static Future<void> initNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin?.initialize(initializationSettings);

    await _flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static void startAutoCheck(String userId) {
    _timer?.cancel();
    print("🔁 AlertCheckerService started... checking every 2 minutes.");
    print("📱 Starting background alert monitoring for user: $userId");

    runOnce(userId);

    _timer = Timer.periodic(const Duration(minutes: 2), (timer) async {
      await runOnce(userId);
    });
  }

  static void stopAutoCheck() {
    _timer?.cancel();
    print("🛑 AlertCheckerService stopped.");
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    required String symbol,
  }) async {
    if (_flutterLocalNotificationsPlugin == null) {
      await initNotifications();
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'stock_alerts',
      'Stock Price Alerts',
      channelDescription: 'Notifications for stock price alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin?.show(
      symbol.hashCode,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  static Future<void> runOnce(String userId) async {
    try {
      final alerts = HiveAlertsService.getAllAlerts();
      print(
          "🔎 [${DateTime.now().toString().substring(11, 19)}] Checking ${alerts.length} alerts for user: $userId");

      if (alerts.isEmpty) {
        print("ℹ️ No alerts found in Hive.");
        return;
      }

      final repo = StockRepository(userId: userId);

      for (final alert in alerts) {
        await _checkSingleAlert(alert, repo);
      }

      print(
          "🔎 Alert check completed at ${DateTime.now().toString().substring(11, 19)}");
    } catch (e, st) {
      print("❌ Error in runOnce: $e\n$st");
    }
  }

  static Future<void> _checkSingleAlert(
      StockAlertModel alert, StockRepository repo) async {
    try {
      print("-" * 50);
      print("📊 Checking: ${alert.symbol}");
      print("   Active: ${alert.active}");
      print("   High Alert: ${alert.highPrice ?? 'None'}");
      print("   Low Alert: ${alert.lowPrice ?? 'None'}");
      print("   Last Price: ${alert.lastPrice ?? 'None'}");

      if (!alert.active) {
        print("⏸️ Skipping ${alert.symbol} (inactive)");
        return;
      }

      double? currentPrice;
      final cachedPrice = _priceCache[alert.symbol];

      if (cachedPrice != null && !cachedPrice.isExpired) {
        currentPrice = cachedPrice.price;
        print(
            "💾 Using cached price for ${alert.symbol}: \$${currentPrice.toStringAsFixed(2)}");
      } else {
        final stock = await repo.getStockQuote(alert.symbol);
        if (stock == null) {
          print("⚠️ Failed to fetch quote for ${alert.symbol}");
          return;
        }

        currentPrice = stock.currentPrice;
        if (currentPrice <= 0) {
          print("⚠️ Invalid price for ${alert.symbol}: $currentPrice");
          return;
        }

        _priceCache[alert.symbol] = CachedPrice(currentPrice, DateTime.now());
        print(
            "💰 Fresh API price for ${alert.symbol}: \$${currentPrice.toStringAsFixed(2)}");
      }

      bool priceChanged = false;
      bool alertTriggered = false;
      String? triggerMessage;

      if (alert.lastPrice != null) {
        final priceDiff = (currentPrice - alert.lastPrice!).abs();
        priceChanged = priceDiff > 0.01;

        if (priceChanged) {
          final direction =
              currentPrice > alert.lastPrice! ? "📈 UP" : "📉 DOWN";
          final change =
              ((currentPrice - alert.lastPrice!) / alert.lastPrice! * 100);
          print(
              "🔄 Price Changed! $direction by ${change.toStringAsFixed(2)}%");
        } else {
          print("⚪ No significant price change");
        }
      } else {
        priceChanged = true;
        print("🆕 First time checking ${alert.symbol}");
      }

      if (alert.highPrice != null && currentPrice >= alert.highPrice!) {
        alertTriggered = true;
        triggerMessage =
            "🚀 ${alert.symbol} REACHED HIGH ALERT!\nPrice: \$${currentPrice.toStringAsFixed(2)} (Alert: \$${alert.highPrice!.toStringAsFixed(2)})";
        print("🚨 HIGH ALERT TRIGGERED for ${alert.symbol}!");
      }

      if (alert.lowPrice != null && currentPrice <= alert.lowPrice!) {
        alertTriggered = true;
        triggerMessage =
            "📉 ${alert.symbol} REACHED LOW ALERT!\nPrice: \$${currentPrice.toStringAsFixed(2)} (Alert: \$${alert.lowPrice!.toStringAsFixed(2)})";
        print("🚨 LOW ALERT TRIGGERED for ${alert.symbol}!");
      }

      if (alertTriggered && triggerMessage != null) {
        await showNotification(
          title: "Stock Alert: ${alert.symbol}",
          body: triggerMessage,
          symbol: alert.symbol,
        );
        print("📱 Notification sent: $triggerMessage");
      }

      if (priceChanged || alertTriggered) {
        final statusMessage = alertTriggered
            ? triggerMessage!
            : "💹 ${alert.symbol}: \$${currentPrice.toStringAsFixed(2)} ${priceChanged ? '(Price Changed)' : '(No Change)'}";

        if (!alertTriggered) {
          await showNotification(
            title: "Stock Update: ${alert.symbol}",
            body: statusMessage,
            symbol: "${alert.symbol}_update",
          );
        }
      }

      alert.lastPrice = currentPrice;
      await HiveAlertsService.saveAlert(alert);

      if (!alertTriggered) {
        print("✅ ${alert.symbol}: Within normal range");
      }
    } catch (e, st) {
      print("⚠️ Error checking ${alert.symbol}: $e\n$st");
    }
  }
}
