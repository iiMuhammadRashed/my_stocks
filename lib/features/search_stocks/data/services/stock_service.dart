import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/stock_model.dart';

class StockService {
  final String apiKey = ApiConstants.apiKey;

  static const int MAX_RETRIES = 3;
  static const Duration RETRY_DELAY = Duration(seconds: 2);

  Future<T> _retryApiCall<T>(Future<T> Function() apiCall) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < MAX_RETRIES) {
      try {
        return await apiCall();
      } catch (e) {
        lastException = e as Exception;
        attempts++;

        if (attempts < MAX_RETRIES) {
          print(
              '⚠️ API call failed (attempt $attempts/$MAX_RETRIES). Error: $e. Retrying in ${RETRY_DELAY.inSeconds * attempts}s...');
          await Future.delayed(RETRY_DELAY * attempts);
        } else {
          print('❌ Final attempt failed. Error: $e');
        }
      }
    }

    print('❌ API call failed after $MAX_RETRIES attempts');
    throw lastException ??
        Exception('API call failed after $MAX_RETRIES attempts');
  }

  Future<List<StockModel>> searchStocks(String query) async {
    return _retryApiCall(() async {
      final url = Uri.parse(
          '${ApiConstants.buildUrl(ApiConstants.symbolSearchEndpoint)}?symbol=$query&apikey=$apiKey');
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['status'] != 'ok') {
        throw Exception(data['message'] ?? 'Failed to search stocks');
      }

      List results = data['data'] ?? [];
      return results.map((e) => StockModel.fromSearchJson(e)).toList();
    });
  }

  Future<StockModel> getQuote(String symbol) async {
    return _retryApiCall(() async {
      await ApiConstants.checkRateLimit();

      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.quoteEndpoint}?symbol=$symbol&apikey=${ApiConstants.apiKey}');
      final response = await http.get(url);

      print('=== Single Quote Response for $symbol ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'HTTP ${response.statusCode}: Failed to get quote for $symbol');
      }

      final data = jsonDecode(response.body);

      if (data['status'] == 'error') {
        throw Exception(data['message'] ?? 'API returned error for $symbol');
      }

      if (data['symbol'] == null || data['close'] == null) {
        throw Exception('Invalid stock data received for $symbol');
      }

      try {
        final stock = StockModel.fromQuoteJson(data);
        print('✅ Successfully parsed: ${stock.symbol}, Price: ${stock.close}');
        return stock;
      } catch (e) {
        print('❌ Error parsing stock data for $symbol: $e');
        print('Data was: $data');
        throw Exception('Failed to parse stock data for $symbol: $e');
      }
    });
  }

  Future<Map<String, StockModel>> getBatchQuotes(List<String> symbols) async {
    if (symbols.isEmpty) return {};

    return _retryApiCall(() async {
      final limitedSymbols = symbols.take(8).toList();
      final symbolsString = limitedSymbols.join(',');

      final url = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.quoteEndpoint}?symbol=$symbolsString&apikey=${ApiConstants.apiKey}');

      print('=== Batch Request ===');
      print('URL: $url');
      print('Symbols: $limitedSymbols');

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      print('=== Batch Response ===');
      print(response.body);
      print('=====================');

      Map<String, StockModel> quotes = {};

      if (limitedSymbols.length == 1) {
        print('Processing SINGLE symbol response');

        final status = data['status'];
        if (status == 'error') {
          print('✗ Error response: ${data['message']}');
        } else if (status == 'ok' || status == null) {
          try {
            final stock = StockModel.fromQuoteJson(data);
            quotes[stock.symbol] = stock;
            print(
                '✓ Successfully parsed: ${stock.symbol}, Price: ${stock.close}');
          } catch (e) {
            print('✗ Error parsing single quote: $e');
          }
        } else {
          print('✗ Unknown status: $status');
        }
      } else {
        print('Processing MULTIPLE symbols response');
        for (var symbol in limitedSymbols) {
          print('--- Processing symbol: $symbol ---');
          if (data[symbol] != null) {
            print('Data exists for $symbol');

            final status = data[symbol]['status'];
            if (status == 'error') {
              print('✗ Error response for $symbol: ${data[symbol]['message']}');
              continue;
            }

            if (status == 'ok' || status == null) {
              try {
                final stock = StockModel.fromQuoteJson(data[symbol]);
                quotes[symbol] = stock;
                print(
                    '✓ Successfully parsed: ${stock.symbol}, Price: ${stock.close}');
              } catch (e) {
                print('✗ Error parsing $symbol: $e');
                print('Data was: ${data[symbol]}');
              }
            } else {
              print('✗ Unknown status for $symbol: $status');
            }
          } else {
            print('✗ No data found for $symbol');
          }
        }
      }

      print('=== Final quotes map: ${quotes.keys.toList()} ===');
      return quotes;
    });
  }

  Future<List<StockModel>> updateQuotes(List<StockModel> searchResults) async {
    if (searchResults.isEmpty) return [];

    final limitedResults = searchResults.take(8).toList();
    final symbols = limitedResults.map((s) => s.symbol).toList();

    print('=== Starting updateQuotes ===');
    print('Symbols to fetch: $symbols');

    try {
      final quotes = await getBatchQuotes(symbols);

      print('=== Merging results ===');
      print('Got ${quotes.length} quotes');

      List<StockModel> updated = [];
      for (var stock in limitedResults) {
        if (quotes.containsKey(stock.symbol)) {
          final merged = stock.copyWithQuote(quotes[stock.symbol]!);
          updated.add(merged);
          print(
              '✓ Merged ${stock.symbol}: Price=${merged.open}, Change=${merged.percentChange}');
        } else {
          updated.add(stock);
          print('✗ No quote for ${stock.symbol}, using defaults');
        }
      }

      return updated;
    } catch (e) {
      print('✗✗✗ Error updating quotes: $e');

      return limitedResults;
    }
  }
}
