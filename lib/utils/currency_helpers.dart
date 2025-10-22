import 'package:flutter/material.dart';

String getCurrencySymbol(String currency) {
  switch (currency) {
    case 'NGN':
      return '₦';
    case 'KES':
      return 'KSh';
    case 'GHS':
      return '₵';
    case 'ZAR':
      return 'R';
    case 'USD':
      return '\$';
    default:
      return currency;
  }
}

final Map<String, Map<String, double>> exchangeRates = {
  'NGN': {'USDC': 775.0, 'USDT': 773.5, 'DAI': 776.2},
  'KES': {'USDC': 129.5, 'USDT': 129.1, 'DAI': 130.0},
  'GHS': {'USDC': 12.5, 'USDT': 12.4, 'DAI': 12.6},
  'ZAR': {'USDC': 18.2, 'USDT': 18.1, 'DAI': 18.3},
  'USD': {'USDC': 1.0, 'USDT': 0.998, 'DAI': 1.001},
};

Widget buildConversionDisplay({
  required String amount,
  required String cryptoCurrency,
  required String localCurrency,
  required Color accentColor,
}) {
  final amountValue = double.tryParse(amount) ?? 0.0;
  if (amountValue <= 0) return Container();
  
  final rate = exchangeRates[localCurrency]?[cryptoCurrency] ?? 1.0;
  final convertedAmount = amountValue * rate;
  final currencySymbol = getCurrencySymbol(localCurrency);
  
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You Pay',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${amountValue.toStringAsFixed(2)} $cryptoCurrency',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward, color: Colors.grey),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Local Equivalent',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$currencySymbol${convertedAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Rate: 1 $cryptoCurrency = $currencySymbol${rate.toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ),
  );
}

List<String> getStableCoins() {
  return ['USDC', 'USDT', 'DAI'];
}

List<String> getLocalCurrencies() {
  return ['NGN', 'KES', 'GHS', 'ZAR', 'USD'];
}

List<String> getVolatileCoins() {
  return ['ETH', 'BTC', 'MATIC', 'SOL'];
}

List<String> getBlockchainNetworks() {
  return ['Ethereum', 'Polygon', 'Base', 'Arbitrum', 'Optimism'];
}