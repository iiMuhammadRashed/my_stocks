import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/search_stocks/data/models/stock_model.dart';

class HiveFavoritesService {
  static const String favoritesBox = 'favorites';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(StockModelAdapter());
    }
    if (!Hive.isBoxOpen(favoritesBox)) {
      await Hive.openBox<StockModel>(favoritesBox);
    }
  }

  static Future<void> addFavorite(StockModel stock) async {
    final box = await _getBox();
    await box.put(stock.symbol, stock);
  }

  static Future<void> removeFavorite(String symbol) async {
    final box = await _getBox();
    await box.delete(symbol);
  }

  static bool isFavorite(String symbol) {
    if (!Hive.isBoxOpen(favoritesBox)) return false;
    final box = Hive.box<StockModel>(favoritesBox);
    return box.containsKey(symbol);
  }

  static List<StockModel> getFavorites() {
    if (!Hive.isBoxOpen(favoritesBox)) return [];
    final box = Hive.box<StockModel>(favoritesBox);
    return box.values.toList();
  }

  static Future<void> clearFavorites() async {
    final box = await _getBox();
    await box.clear();
  }

  static Future<void> updateFavorite(StockModel stock) async {
    final box = await _getBox();
    if (box.containsKey(stock.symbol)) {
      await box.put(stock.symbol, stock);
    }
  }

  static Future<void> updateMultipleFavorites(List<StockModel> stocks) async {
    final box = await _getBox();
    for (final stock in stocks) {
      if (box.containsKey(stock.symbol)) {
        await box.put(stock.symbol, stock);
      }
    }
  }

  static Future<Box<StockModel>> _getBox() async {
    if (!Hive.isBoxOpen(favoritesBox)) {
      return await Hive.openBox<StockModel>(favoritesBox);
    }
    return Hive.box<StockModel>(favoritesBox);
  }
}
