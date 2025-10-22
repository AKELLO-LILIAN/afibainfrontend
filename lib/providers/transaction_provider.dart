import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final List<TransactionModel> _transactions = [];
  final List<TransactionModel> _pendingTransactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<TransactionModel> get pendingTransactions => List.unmodifiable(_pendingTransactions);
  bool get isLoading => _isLoading;

  // Add new transaction
  void addTransaction(TransactionModel transaction) {
    if (transaction.status == TransactionStatus.pending) {
      _pendingTransactions.add(transaction);
    } else {
      _transactions.insert(0, transaction);
    }
    notifyListeners();
  }

  // Load transaction history (mock implementation)
  Future<void> loadTransactionHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock transactions with extensive history
      final mockTransactions = [
        // Recent transactions
        TransactionModel(
          hash: '0xabc123def456...',
          type: TransactionType.payment,
          amount: 12.50,
          currency: 'USDC',
          fromAddress: '0x742d35cc6634c0532925a3b8d48c0f9e15c6a1b0',
          toAddress: '0x456def789abc...',
          description: 'Coffee and pastry',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          status: TransactionStatus.completed,
          fee: 0.01,
          merchantName: 'Coffee Paradise',
        ),
        TransactionModel(
          hash: '0x789abc123def...',
          type: TransactionType.payment,
          amount: 45.75,
          currency: 'USDT',
          fromAddress: '0x742d35cc6634c0532925a3b8d48c0f9e15c6a1b0',
          toAddress: '0x789abc456def...',
          description: 'Weekly groceries',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          status: TransactionStatus.completed,
          fee: 0.05,
          merchantName: 'Fresh Market',
        ),
        TransactionModel(
          hash: '0x321fed987cba...',
          type: TransactionType.salary,
          amount: 2500.0,
          currency: 'USDC',
          fromAddress: '0x987fed321cba...',
          toAddress: '0x742d35cc6634c0532925a3b8d48c0f9e15c6a1b0',
          description: 'Monthly salary - Tech Corp',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          status: TransactionStatus.completed,
          fee: 2.5,
        ),
        TransactionModel(
          hash: '0x654abc987fed...',
          type: TransactionType.payment,
          amount: 35.20,
          currency: 'DAI',
          fromAddress: '0x742d35cc6634c0532925a3b8d48c0f9e15c6a1b0',
          toAddress: '0x123def456abc...',
          description: 'Fuel tank refill',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          status: TransactionStatus.completed,
          fee: 0.04,
          merchantName: 'Shell Station',
        ),
        TransactionModel(
          hash: '0x147258369abc...',
          type: TransactionType.payment,
          amount: 85.99,
          currency: 'USDC',
          fromAddress: '0x742d35cc6634c0532925a3b8d48c0f9e15c6a1b0',
          toAddress: '0xabc123def456...',
          description: 'Programming books',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          status: TransactionStatus.completed,
          fee: 0.09,
          merchantName: 'BookWorld',
        ),
        TransactionModel(
          hash: '0x963852741def...',
          type: TransactionType.refund,
          amount: 25.50,
          currency: 'USDT',
          fromAddress: '0x321fed987cba...',
          toAddress: '0x742d35cc6634c0532925a3b8d48c0f9e15c6a1b0',
          description: 'Refund - Defective headphones',
          timestamp: DateTime.now().subtract(const Duration(days: 4)),
          status: TransactionStatus.completed,
          fee: 0.0,
          merchantName: 'TechHub',
        ),
        TransactionModel(
          hash: '0x741852963abc...',
          type: TransactionType.payment,
          amount: 28.75,
          currency: 'USDC',
          fromAddress: '0x742d35cc6634c0532925a3b8d48c0f9e15c6a1b0',
          toAddress: '0x654abc987fed...',
          description: 'Prescription medications',
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          status: TransactionStatus.completed,
          fee: 0.03,
          merchantName: 'Pharma Plus',
        ),
        // Older transactions
        TransactionModel(
          hash: '0x159753486abc...',
          type: TransactionType.payment,
          amount: 15.00,
          currency: 'DAI',
          fromAddress: '0x742d35cc6634c0532925a3b8d48c0f9e15c6a1b0',
          toAddress: '0x456def789abc...',
          description: 'Morning coffee',
          timestamp: DateTime.now().subtract(const Duration(days: 7)),
          status: TransactionStatus.completed,
          fee: 0.02,
          merchantName: 'Coffee Paradise',
        ),
        TransactionModel(
          hash: '0x753159486def...',
          type: TransactionType.payment,
          amount: 125.40,
          currency: 'USDC',
          fromAddress: '0x742d35cc6634c0532925a3b8d48c0f9e15c6a1b0',
          toAddress: '0x789abc456def...',
          description: 'Monthly groceries',
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
          status: TransactionStatus.completed,
          fee: 0.13,
          merchantName: 'Fresh Market',
        ),
        TransactionModel(
          hash: '0x486159753def...',
          type: TransactionType.payment,
          amount: 55.80,
          currency: 'USDT',
          fromAddress: '0x742d35cc6634c0532925a3b8d48c0f9e15c6a1b0',
          toAddress: '0x123def456abc...',
          description: 'Car maintenance',
          timestamp: DateTime.now().subtract(const Duration(days: 15)),
          status: TransactionStatus.completed,
          fee: 0.06,
          merchantName: 'Shell Station',
        ),
      ];

      _transactions.clear();
      _transactions.addAll(mockTransactions);
    } catch (e) {
      debugPrint('Failed to load transaction history: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Calculate total spent
  double getTotalSpent({DateTime? startDate, DateTime? endDate}) {
    var filteredTransactions = _transactions.where((tx) => 
        tx.type == TransactionType.payment && tx.status == TransactionStatus.completed);

    if (startDate != null) {
      filteredTransactions = filteredTransactions.where((tx) => 
          tx.timestamp.isAfter(startDate));
    }

    if (endDate != null) {
      filteredTransactions = filteredTransactions.where((tx) => 
          tx.timestamp.isBefore(endDate));
    }

    return filteredTransactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Calculate total received
  double getTotalReceived({DateTime? startDate, DateTime? endDate}) {
    var filteredTransactions = _transactions.where((tx) => 
        (tx.type == TransactionType.salary || tx.type == TransactionType.refund) && 
        tx.status == TransactionStatus.completed);

    if (startDate != null) {
      filteredTransactions = filteredTransactions.where((tx) => 
          tx.timestamp.isAfter(startDate));
    }

    if (endDate != null) {
      filteredTransactions = filteredTransactions.where((tx) => 
          tx.timestamp.isBefore(endDate));
    }

    return filteredTransactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }
}