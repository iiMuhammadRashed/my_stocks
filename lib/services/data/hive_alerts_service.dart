import 'package:hive/hive.dart';
import '../../features/price_alerts/data/stock_alert_model.dart';

class HiveAlertsService {
  static const String _boxName = 'stock_alerts';

  static late Box<StockAlertModel> _box;
  static Future<void> init({String? storagePath}) async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(StockAlertModelAdapter());
    }

    if (storagePath != null) {
      Hive.init(storagePath);
    }

    _box = await Hive.openBox<StockAlertModel>(_boxName);
  }

  static Future<void> saveAlert(StockAlertModel alert) async {
    await _box.put(alert.symbol, alert);

    await _box.flush();
    final saved = _box.get(alert.symbol);
    print(
        "Hive: saved alert for ${alert.symbol} -> high: ${saved?.highPrice}, low: ${saved?.lowPrice}, lastPrice: ${saved?.lastPrice}");
  }

  static StockAlertModel? getAlertForSymbol(String symbol) {
    return _box.get(symbol);
  }

  static List<StockAlertModel> getAllAlerts() {
    return _box.values.toList();
  }

  static Future<void> deleteAlert(String symbol) async {
    await _box.delete(symbol);
    print("Hive: deleted alert for $symbol");
  }
}
