import 'package:hive/hive.dart';

part 'stock_alert_model.g.dart';

@HiveType(typeId: 2)
class StockAlertModel extends HiveObject {
  @HiveField(0)
  String symbol;

  @HiveField(1)
  double? highPrice;

  @HiveField(2)
  double? lowPrice;

  @HiveField(3)
  bool active;

  @HiveField(4)
  double? lastPrice;

  StockAlertModel({
    required this.symbol,
    this.highPrice,
    this.lowPrice,
    this.active = true,
    this.lastPrice,
  });
}
