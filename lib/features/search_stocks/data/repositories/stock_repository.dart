import 'package:flutter/foundation.dart';
import '../../../../core/utils/connectivity_service.dart';
import '../../../../services/data/hive_favorites_service.dart';
import '../models/stock_model.dart';
import '../services/stock_service.dart';

class StockRepository {
  final StockService _service;
  final String userId;

  StockRepository({
    required this.userId,
    StockService? service,
  }) : _service = service ?? StockService();

  Future<List<StockModel>> searchStocks(String query) async {
    if (query.isEmpty) return [];
    final searchResults = await _service.searchStocks(query);
    if (searchResults.isEmpty) return [];
    return await _service.updateQuotes(searchResults);
  }

  List<StockModel> getFavorites() {
    return HiveFavoritesService.getFavorites();
  }

  Future<void> addFavorite(StockModel stock) async {
    try {
      await HiveFavoritesService.addFavorite(stock);
      if (kDebugMode) print('✅ Added ${stock.symbol} to Hive and Firestore');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to add favorite: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(String symbol) async {
    try {
      await HiveFavoritesService.removeFavorite(symbol);
      if (kDebugMode) print('🗑️ Removed $symbol from Hive and Firestore');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to remove favorite: $e');
      rethrow;
    }
  }

  bool isFavorite(String symbol) {
    return HiveFavoritesService.getFavorites().any((s) => s.symbol == symbol);
  }

  Future<StockModel?> getStockQuote(String symbol) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (!isOnline) {
        if (kDebugMode) print('⚠️ Offline - cannot fetch quote for $symbol');
        return null;
      }

      final quote = await _service.getQuote(symbol);
      if (kDebugMode) print('✅ Fetched fresh quote for $symbol');
      return quote;
    } catch (e) {
      if (kDebugMode) print('❌ Failed to fetch quote for $symbol: $e');
      return null;
    }
  }

  Future<void> refreshFavorites() async {
    try {
      final localStocks = HiveFavoritesService.getFavorites();
      if (localStocks.isEmpty) return;

      final isOnline = await ConnectivityService.isOnline();
      if (!isOnline) {
        if (kDebugMode) print('⚠️ Offline mode - showing cached data');
        return;
      }

      final symbols = localStocks.map((s) => s.symbol).toList();
      if (kDebugMode)
        print('🔄 Refreshing ${symbols.length} favorites from API...');

      final quotes = await _service.getBatchQuotes(symbols);

      final updatedStocks = <StockModel>[];
      for (final stock in localStocks) {
        if (quotes.containsKey(stock.symbol)) {
          final updated = stock.copyWithQuote(quotes[stock.symbol]!);
          updatedStocks.add(updated);
        } else {
          updatedStocks.add(stock);
        }
      }

      await HiveFavoritesService.updateMultipleFavorites(updatedStocks);

      if (kDebugMode)
        print('✅ Refreshed ${updatedStocks.length} stocks successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to refresh favorites: $e');
    }
  }
}
