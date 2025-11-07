import 'package:hive/hive.dart';

part 'stock_model.g.dart';

@HiveType(typeId: 1)
class StockModel extends HiveObject {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String exchange;

  @HiveField(3)
  final String micCode;

  @HiveField(4)
  final String currency;

  @HiveField(5)
  final double open;

  @HiveField(6)
  final double high;

  @HiveField(7)
  final double low;

  @HiveField(8)
  final double close;

  @HiveField(9)
  final double previousClose;

  @HiveField(10)
  final double change;

  @HiveField(11)
  final double percentChange;

  @HiveField(12)
  final bool isMarketOpen;

  @HiveField(13)
  final double volume;

  @HiveField(14)
  final double averageVolume;

  @HiveField(15)
  final String datetime;

  @HiveField(16)
  final String? fiftyTwoWeekHigh;

  @HiveField(17)
  final String? fiftyTwoWeekLow;

  @HiveField(18)
  final String? marketCap;

  StockModel({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.micCode,
    required this.currency,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.previousClose,
    required this.change,
    required this.percentChange,
    required this.isMarketOpen,
    required this.volume,
    required this.averageVolume,
    required this.datetime,
    this.fiftyTwoWeekHigh,
    this.fiftyTwoWeekLow,
    this.marketCap,
  });

  factory StockModel.fromSearchJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'] ?? '',
      name: json['instrument_name'] ?? json['name'] ?? '',
      exchange: json['exchange'] ?? '',
      micCode: json['mic_code'] ?? '',
      currency: json['currency'] ?? '',
      open: 0.0,
      high: 0.0,
      low: 0.0,
      close: 0.0,
      previousClose: 0.0,
      change: 0.0,
      percentChange: 0.0,
      isMarketOpen: false,
      volume: 0.0,
      averageVolume: 0.0,
      datetime: '',
      fiftyTwoWeekHigh: null,
      fiftyTwoWeekLow: null,
      marketCap: null,
    );
  }

  factory StockModel.fromQuoteJson(Map<String, dynamic> json) {
    double parse(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return StockModel(
      symbol: json['symbol']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      exchange: json['exchange']?.toString() ?? '',
      micCode: json['mic_code']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      open: parse(json['open']),
      high: parse(json['high']),
      low: parse(json['low']),
      close: parse(json['close']),
      previousClose: parse(json['previous_close']),
      change: parse(json['change']),
      percentChange: parse(json['percent_change']),
      isMarketOpen:
          json['is_market_open'] == true || json['is_market_open'] == 'true',
      volume: parse(json['volume']),
      averageVolume: parse(json['average_volume']),
      datetime: json['datetime']?.toString() ?? '',
      fiftyTwoWeekHigh: json['fifty_two_week']?['high']?.toString(),
      fiftyTwoWeekLow: json['fifty_two_week']?['low']?.toString(),
      marketCap: json['market_cap']?.toString(),
    );
  }

  StockModel copyWithQuote(StockModel q) {
    return StockModel(
      symbol: symbol,
      name: name,
      exchange: exchange,
      micCode: micCode,
      currency: currency,
      open: q.open,
      high: q.high,
      low: q.low,
      close: q.close,
      previousClose: q.previousClose,
      change: q.change,
      percentChange: q.percentChange,
      isMarketOpen: q.isMarketOpen,
      volume: q.volume,
      averageVolume: q.averageVolume,
      datetime: q.datetime,
      fiftyTwoWeekHigh: q.fiftyTwoWeekHigh,
      fiftyTwoWeekLow: q.fiftyTwoWeekLow,
      marketCap: q.marketCap,
    );
  }

  double get currentPrice {
    if (close > 0) return close;
    if (open > 0) return open;
    return 0.0;
  }

  bool get hasValidPrice => currentPrice > 0;

  String get formattedVolume {
    if (volume == 0.0) return 'N/A';
    if (volume >= 1e9) return '${(volume / 1e9).toStringAsFixed(2)}B';
    if (volume >= 1e6) return '${(volume / 1e6).toStringAsFixed(2)}M';
    if (volume >= 1e3) return '${(volume / 1e3).toStringAsFixed(2)}K';
    return volume.toStringAsFixed(0);
  }

  String get formattedAverageVolume {
    if (averageVolume == 0.0) return 'N/A';
    if (averageVolume >= 1e9) {
      return '${(averageVolume / 1e9).toStringAsFixed(2)}B';
    }
    if (averageVolume >= 1e6) {
      return '${(averageVolume / 1e6).toStringAsFixed(2)}M';
    }
    if (averageVolume >= 1e3) {
      return '${(averageVolume / 1e3).toStringAsFixed(2)}K';
    }
    return averageVolume.toStringAsFixed(0);
  }

  String get formattedMarketCap {
    if (marketCap == null || marketCap!.isEmpty) return 'N/A';
    final double? value = double.tryParse(marketCap!);
    if (value == null) return marketCap!;

    if (value >= 1e12) return '\$${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '\$${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e6) return '\$${(value / 1e6).toStringAsFixed(2)}M';
    if (value >= 1e3) return '\$${(value / 1e3).toStringAsFixed(2)}K';
    return '\$${value.toStringAsFixed(0)}';
  }

  String get formattedDateTime {
    if (datetime.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(datetime);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';

      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return datetime;
    }
  }

  String get marketStatus => isMarketOpen ? 'Market Open' : 'Market Closed';
}
