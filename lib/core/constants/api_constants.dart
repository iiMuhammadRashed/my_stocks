class ApiConstants {
  // Base Configuration

  static const String baseUrl = 'https://api.twelvedata.com';
  static const String apiKey = 'c5032b8381504367a04f18339aefd096';

  // Rate limiting for free plan (8 calls per minute)
  static DateTime _lastApiCallTime = DateTime(2000);
  static int _apiCallsThisMinute = 0;
  static const int maxCallsPerMinute = 6; // Conservative limit (less than 8)

  // Check if we can make an API call
  static Future<void> checkRateLimit() async {
    final now = DateTime.now();

    // Reset counter if a minute has passed
    if (now.difference(_lastApiCallTime).inMinutes >= 1) {
      _apiCallsThisMinute = 0;
    }

    // If we've hit the limit, wait
    if (_apiCallsThisMinute >= maxCallsPerMinute) {
      final waitTime = 60 - now.difference(_lastApiCallTime).inSeconds;
      if (waitTime > 0) {
        print('⏳ Rate limit reached. Waiting ${waitTime}s...');
        await Future.delayed(Duration(seconds: waitTime + 1));
        _apiCallsThisMinute = 0;
      }
    }

    _apiCallsThisMinute++;
    _lastApiCallTime = now;
    print('📞 API Call #$_apiCallsThisMinute this minute');
  }

  // Endpoints we actually use
  static const String quoteEndpoint = '/quote'; // For main stock details
  static const String symbolSearchEndpoint =
      '/symbol_search'; // For search screen
  static const String timeSeriesEndpoint = '/time_series'; // For line chart

  // Common Query Params
  static const String apiKeyParam = 'apikey';
  static const String symbolParam = 'symbol';
  static const String intervalParam = 'interval';
  static const String outputSizeParam = 'outputsize';

  // Default values for chart
  static const String defaultInterval = '1day';
  static const int defaultOutputSize = 30; // last 30 days

  // Helper methods
  static String buildUrl(String endpoint) => '$baseUrl$endpoint';

  static Map<String, dynamic> getCommonParams() => {
        apiKeyParam: apiKey,
      };
}
