import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/data/hive_alerts_service.dart';
import '../../../search_stocks/data/models/stock_model.dart';
import '../../data/stock_alert_model.dart';

class StockAlertScreen extends StatefulWidget {
  final StockModel stock;

  const StockAlertScreen({super.key, required this.stock});

  @override
  State<StockAlertScreen> createState() => _StockAlertScreenState();
}

class _StockAlertScreenState extends State<StockAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _highController = TextEditingController();
  final _lowController = TextEditingController();

  late final double _currentPrice;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.stock.currentPrice;
    _loadExistingAlert();
  }

  @override
  void dispose() {
    _highController.dispose();
    _lowController.dispose();
    super.dispose();
  }

  void _loadExistingAlert() {
    final existing = HiveAlertsService.getAlertForSymbol(widget.stock.symbol);
    if (existing != null) {
      if (existing.highPrice != null) {
        _highController.text = existing.highPrice!.toStringAsFixed(2);
      }
      if (existing.lowPrice != null) {
        _lowController.text = existing.lowPrice!.toStringAsFixed(2);
      }

      print(
          "Loaded alert for ${existing.symbol} -> high: ${existing.highPrice}, low: ${existing.lowPrice}, lastPrice: ${existing.lastPrice}");
    } else {
      print("No existing alert for ${widget.stock.symbol}");
    }
  }

  String? _validatePrice(String? value, bool isHigh) {
    if (value == null || value.isEmpty) return null;

    final val = double.tryParse(value);
    if (val == null) return 'Invalid number';

    if (isHigh && val <= _currentPrice) {
      return 'Must be higher than current (\$${_currentPrice.toStringAsFixed(2)})';
    }
    if (!isHigh && val >= _currentPrice) {
      return 'Must be lower than current (\$${_currentPrice.toStringAsFixed(2)})';
    }
    return null;
  }

  Widget _buildPriceField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool isHigh,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) => _validatePrice(value, isHigh),
    );
  }

  void _saveAlert() async {
    if (_formKey.currentState?.validate() ?? false) {
      final highPrice = _highController.text.isNotEmpty
          ? double.tryParse(_highController.text)
          : null;
      final lowPrice = _lowController.text.isNotEmpty
          ? double.tryParse(_lowController.text)
          : null;

      final alert = StockAlertModel(
        symbol: widget.stock.symbol,
        highPrice: highPrice,
        lowPrice: lowPrice,
        lastPrice: null,
      );

      print(
          "Saving alert for ${alert.symbol} -> high: ${alert.highPrice}, low: ${alert.lowPrice}");

      await HiveAlertsService.saveAlert(alert);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alert saved successfully! ✅")),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Set Alert for ${widget.stock.name}"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Current Price: \$${_currentPrice.toStringAsFixed(2)}",
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildPriceField(
                label: "High Price Alert",
                icon: Icons.arrow_upward_rounded,
                controller: _highController,
                isHigh: true,
              ),
              const SizedBox(height: 16),
              _buildPriceField(
                label: "Low Price Alert",
                icon: Icons.arrow_downward_rounded,
                controller: _lowController,
                isHigh: false,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: const Text("Save Alert"),
                  onPressed: _saveAlert,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
