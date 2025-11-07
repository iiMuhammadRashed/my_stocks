import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../data/models/stock_model.dart';
import '../../viewmodels/search_stocks_viewmodel.dart';
import '../widgets/stock_list_item.dart';

class SearchStocksScreen extends StatelessWidget {
  const SearchStocksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchStocksViewModel(),
      child: Consumer<SearchStocksViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Search Stocks'),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: Text(
                      '⭐ ${viewModel.favorites.length}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: viewModel.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by company or symbol...',
                      suffixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        viewModel.searchStocks(value);
                      }
                    },
                  ),
                ),
                if (viewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                if (viewModel.error.isNotEmpty && !viewModel.isLoading)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      viewModel.error,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (viewModel.results.isEmpty && !viewModel.isLoading) {
                        return const Center(
                          child: Text('Search for stocks to see results'),
                        );
                      }

                      return ListView.builder(
                        itemCount: viewModel.results.length,
                        itemBuilder: (context, index) {
                          final StockModel stock = viewModel.results[index];
                          final isAdded = viewModel.isFavorite(stock.symbol);

                          return StockItem(
                            symbol: stock.symbol,
                            name: stock.name,
                            price: stock.open,
                            changePercent: stock.percentChange,
                            isAdded: isAdded,
                            isLoading: viewModel.isAddingFavorite,
                            onAdd: () =>
                                viewModel.toggleFavorite(context, stock),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: viewModel.loadFavorites,
              tooltip: 'Show Favorites in Console',
              child: const Icon(Icons.star),
            ),
          );
        },
      ),
    );
  }
}
