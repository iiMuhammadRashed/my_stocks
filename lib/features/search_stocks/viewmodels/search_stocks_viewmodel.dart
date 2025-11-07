import 'package:flutter/material.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/connectivity_service.dart';
import '../../../core/utils/user_manager.dart';
import '../../../services/data/hive_favorites_service.dart';
import '../../search_stocks/data/models/stock_model.dart';
import '../../search_stocks/data/services/stock_service.dart';

class SearchStocksViewModel extends ChangeNotifier {
  final StockService _service = StockService();
  final TextEditingController searchController = TextEditingController();

  List<StockModel> results = [];
  List<StockModel> favorites = [];
  bool isLoading = false;
  bool isAddingFavorite = false;
  String error = '';

  late final String? userId;

  SearchStocksViewModel() {
    userId = UserManager.getUserId();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    favorites = HiveFavoritesService.getFavorites();
    notifyListeners();

    debugPrint('⭐ Favorites loaded: ${favorites.length}');
  }

  Future<void> searchStocks(String query) async {
    if (query.isEmpty) return;

    final isOnline = await ConnectivityService.isOnline();
    if (!isOnline) {
      error = 'No internet connection. Please check your network.';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = '';
    results = [];
    notifyListeners();

    try {
      final searchResults = await _service.searchStocks(query);

      if (searchResults.isEmpty) {
        error = 'No results found';
        isLoading = false;
        notifyListeners();
        return;
      }

      final updatedResults = await _service.updateQuotes(searchResults);
      results = updatedResults;
    } catch (e) {
      error = 'Search failed: ${e.toString()}';
      debugPrint('❌ Search error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(String symbol) {
    return favorites.any((stock) => stock.symbol == symbol);
  }

  Future<void> toggleFavorite(BuildContext context, StockModel stock) async {
    if (!context.mounted) return;

    isAddingFavorite = true;
    notifyListeners();

    try {
      if (isFavorite(stock.symbol)) {
        await HiveFavoritesService.removeFavorite(stock.symbol);

        if (context.mounted) {
          ErrorHandler.showSuccess(
            context,
            '${stock.symbol} removed from favorites',
          );
        }
      } else {
        await HiveFavoritesService.addFavorite(stock);

        if (context.mounted) {
          ErrorHandler.showSuccess(
            context,
            '${stock.symbol} added to favorites',
          );
        }
      }

      await loadFavorites();
    } catch (e) {
      debugPrint('❌ Toggle favorite error: $e');
      if (context.mounted) {
        ErrorHandler.showError(context, 'Error: ${e.toString()}');
      }
    } finally {
      isAddingFavorite = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
