import 'package:flutter/material.dart';
import '../../../search_stocks/data/models/stock_model.dart';
import '../../../search_stocks/data/repositories/stock_repository.dart';
import '../../../../core/utils/connectivity_service.dart';
import '../../../../core/utils/error_handler.dart';

class StockDetailsViewModel extends ChangeNotifier {
  final StockRepository _repository;

  StockDetailsViewModel({
    required StockRepository repository,
  }) : _repository = repository;

  StockModel? _stock;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;

  StockModel? get stock => _stock;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  bool get hasError => _error != null;

  void initialize(StockModel initialStock) {
    _stock = initialStock;
    _error = null;
    notifyListeners();
  }

  Future<void> refreshStock(BuildContext context) async {
    if (_stock == null) return;

    final isOnline = await ConnectivityService.isOnline();
    if (!isOnline) {
      _error = 'No internet connection';
      if (context.mounted) {
        ErrorHandler.showWarning(context, 'No internet connection');
      }
      notifyListeners();
      return;
    }

    _isRefreshing = true;
    _error = null;
    notifyListeners();

    try {
      final updatedStock = await _repository.getStockQuote(_stock!.symbol);

      if (updatedStock != null) {
        _stock = _stock!.copyWithQuote(updatedStock);
        _error = null;

        if (context.mounted) {
          ErrorHandler.showSuccess(context, 'Stock data updated');
        }
      } else {
        _error = 'Failed to fetch stock data';
        if (context.mounted) {
          ErrorHandler.showError(context, 'Failed to update stock data');
        }
      }
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        ErrorHandler.showError(context, 'Error: ${e.toString()}');
      }
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(BuildContext context) async {
    if (_stock == null) return;

    try {
      final isFavorite = await _repository.isFavorite(_stock!.symbol);

      if (isFavorite) {
        await _repository.removeFavorite(_stock!.symbol);
        if (context.mounted) {
          ErrorHandler.showInfo(context, 'Removed from favorites');
        }
      } else {
        await _repository.addFavorite(_stock!);
        if (context.mounted) {
          ErrorHandler.showSuccess(context, 'Added to favorites');
        }
      }

      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showError(context, 'Failed to update favorites');
      }
    }
  }

  Future<bool> isFavorite() async {
    if (_stock == null) return false;
    return await _repository.isFavorite(_stock!.symbol);
  }

  void copySymbol(BuildContext context) {
    if (_stock == null) return;

    ErrorHandler.showSuccess(context, 'Symbol copied: ${_stock!.symbol}');
  }

  void shareStock(BuildContext context) {
    if (_stock == null) return;

    ErrorHandler.showInfo(
        context, 'Share: ${_stock!.name} (${_stock!.symbol})');
  }

  @override
  void dispose() {
    super.dispose();
  }
}
