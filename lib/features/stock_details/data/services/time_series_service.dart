import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class TimeSeriesService {
  final String apiKey = ApiConstants.apiKey;

  Future<List<TimeSeriesPoint>> getTimeSeries(
    String symbol, {
    String interval = '1day',
    int outputsize = 30,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.timeSeriesEndpoint}'
      '?symbol=$symbol'
      '&interval=$interval'
      '&outputsize=$outputsize'
      '&apikey=$apiKey',
    );

    print('📊 Fetching time series: $url');

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['status'] == 'error') {
        throw Exception(data['message'] ?? 'Failed to fetch time series');
      }

      if (data['values'] == null || data['values'].isEmpty) {
        throw Exception('No time series data available');
      }

      final List<dynamic> values = data['values'];
      return values.map((e) => TimeSeriesPoint.fromJson(e)).toList();
    } catch (e) {
      print('❌ Time series error: $e');
      rethrow;
    }
  }
}

class TimeSeriesPoint {
  final DateTime datetime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  TimeSeriesPoint({
    required this.datetime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) {
    double parse(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return TimeSeriesPoint(
      datetime: DateTime.parse(json['datetime']),
      open: parse(json['open']),
      high: parse(json['high']),
      low: parse(json['low']),
      close: parse(json['close']),
      volume: parse(json['volume']),
    );
  }
}
