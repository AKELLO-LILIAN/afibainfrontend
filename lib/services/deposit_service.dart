import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/deposit_method.dart';

class DepositService {
  static final Map<String, DepositTransaction> _transactions = {};
  static final List<DepositTransaction> _transactionHistory = [];

  /// Process a deposit request
  static Future<DepositResult> processDeposit(DepositRequest request) async {
    try {
      // Validate the request
      final validationError = _validateRequest(request);
      if (validationError != null) {
        return DepositResult.failure(errorMessage: validationError);
      }

      // Generate transaction ID
      final transactionId = _generateTransactionId();
      
      // Calculate fees
      final fee = request.method.calculateFee(request.amount);
      final total = request.amount + fee;

      // Create transaction record
      final transaction = DepositTransaction(
        id: transactionId,
        methodId: request.method.id,
        methodName: request.method.name,
        amount: request.amount,
        fee: fee,
        total: total,
        currency: request.currency,
        status: DepositStatus.pending,
        createdAt: DateTime.now(),
        metadata: {
          'phoneNumber': request.phoneNumber,
          'accountNumber': request.accountNumber,
          ...request.additionalData,
        },
      );

      // Store transaction
      _transactions[transactionId] = transaction;
      _transactionHistory.add(transaction);

      // Simulate processing based on method
      _simulateProcessing(transactionId, request.method);

      return DepositResult.success(
        transactionId: transactionId,
        amount: request.amount,
        methodName: request.method.name,
        status: 'pending',
        metadata: {
          'fee': fee,
          'total': total,
          'currency': request.currency,
        },
      );
    } catch (e) {
      return DepositResult.failure(
        errorMessage: 'Failed to process deposit: $e',
      );
    }
  }

  /// Get deposit transaction by ID
  static DepositTransaction? getTransaction(String transactionId) {
    return _transactions[transactionId];
  }

  /// Get all deposit transactions (for history)
  static List<DepositTransaction> getAllTransactions() {
    return List.from(_transactionHistory.reversed);
  }

  /// Get pending transactions
  static List<DepositTransaction> getPendingTransactions() {
    return _transactionHistory
        .where((t) => t.status == DepositStatus.pending || t.status == DepositStatus.processing)
        .toList();
  }

  /// Check deposit status
  static Future<DepositStatus> checkDepositStatus(String transactionId) async {
    final transaction = _transactions[transactionId];
    if (transaction == null) {
      throw Exception('Transaction not found');
    }
    return transaction.status;
  }

  /// Validate deposit request
  static String? _validateRequest(DepositRequest request) {
    // Check if method is active
    if (!request.method.isActive) {
      return 'Selected payment method is currently unavailable';
    }

    // Check amount limits
    if (!request.method.isAmountValid(request.amount)) {
      return 'Amount must be between ${request.method.minAmount} and ${request.method.maxAmount}';
    }

    // Check method-specific requirements
    switch (request.method.id) {
      case 'mtn_mobile_money':
      case 'airtel_money':
        if (request.phoneNumber.isEmpty) {
          return 'Phone number is required for ${request.method.name}';
        }
        if (!_isValidPhoneNumber(request.phoneNumber)) {
          return 'Please enter a valid phone number';
        }
        break;

      case 'bank_transfer':
        if (request.accountNumber.isEmpty) {
          return 'Account number is required for bank transfer';
        }
        if (!_isValidAccountNumber(request.accountNumber)) {
          return 'Please enter a valid account number';
        }
        break;

      case 'visa_mastercard':
        // Card validation would be handled by payment processor
        break;

      default:
        return 'Unknown payment method';
    }

    return null; // No validation errors
  }

  /// Generate unique transaction ID
  static String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'DEP${timestamp.substring(timestamp.length - 8)}$random';
  }

  /// Simulate deposit processing based on method
  static void _simulateProcessing(String transactionId, DepositMethod method) {
    Timer(const Duration(seconds: 2), () {
      _updateTransactionStatus(transactionId, DepositStatus.processing);
    });

    // Simulate different processing times
    Duration processingTime;
    switch (method.id) {
      case 'mtn_mobile_money':
      case 'airtel_money':
        processingTime = Duration(seconds: 10 + Random().nextInt(20)); // 10-30 seconds
        break;
      case 'visa_mastercard':
        processingTime = Duration(seconds: 5 + Random().nextInt(10)); // 5-15 seconds
        break;
      case 'bank_transfer':
        processingTime = Duration(minutes: 2 + Random().nextInt(5)); // 2-7 minutes (simulate)
        break;
      default:
        processingTime = const Duration(seconds: 30);
    }

    Timer(processingTime, () {
      // Simulate 95% success rate
      final isSuccessful = Random().nextDouble() < 0.95;
      
      if (isSuccessful) {
        _updateTransactionStatus(transactionId, DepositStatus.completed);
      } else {
        _updateTransactionStatus(
          transactionId, 
          DepositStatus.failed,
          failureReason: 'Transaction failed - insufficient funds or network error',
        );
      }
    });
  }

  /// Update transaction status
  static void _updateTransactionStatus(
    String transactionId, 
    DepositStatus status, {
    String? failureReason,
  }) {
    final transaction = _transactions[transactionId];
    if (transaction == null) return;

    // Create updated transaction
    final updatedTransaction = DepositTransaction(
      id: transaction.id,
      methodId: transaction.methodId,
      methodName: transaction.methodName,
      amount: transaction.amount,
      fee: transaction.fee,
      total: transaction.total,
      currency: transaction.currency,
      status: status,
      createdAt: transaction.createdAt,
      completedAt: status == DepositStatus.completed || status == DepositStatus.failed
          ? DateTime.now()
          : transaction.completedAt,
      failureReason: failureReason ?? transaction.failureReason,
      metadata: transaction.metadata,
    );

    // Update stored transaction
    _transactions[transactionId] = updatedTransaction;

    // Update in history
    final historyIndex = _transactionHistory.indexWhere((t) => t.id == transactionId);
    if (historyIndex >= 0) {
      _transactionHistory[historyIndex] = updatedTransaction;
    }

    print('DepositService: Transaction $transactionId updated to ${status.name}');
  }

  /// Validate phone number (basic validation)
  static bool _isValidPhoneNumber(String phone) {
    // Remove spaces and common prefixes
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check for Uganda format (+256 or 256 followed by 9 digits)
    // or general format (7-15 digits)
    final ugandaPattern = RegExp(r'^(\+?256|0)?[7-9]\d{8}$');
    final generalPattern = RegExp(r'^\d{7,15}$');
    
    return ugandaPattern.hasMatch(cleaned) || generalPattern.hasMatch(cleaned);
  }

  /// Validate account number (basic validation)
  static bool _isValidAccountNumber(String account) {
    // Remove spaces and dashes
    final cleaned = account.replaceAll(RegExp(r'[\s\-]'), '');
    
    // Check if it's numeric and reasonable length (6-20 digits)
    final pattern = RegExp(r'^\d{6,20}$');
    return pattern.hasMatch(cleaned);
  }

  /// Cancel pending deposit
  static Future<bool> cancelDeposit(String transactionId) async {
    final transaction = _transactions[transactionId];
    if (transaction == null) {
      return false;
    }

    // Can only cancel pending or processing transactions
    if (transaction.status != DepositStatus.pending && 
        transaction.status != DepositStatus.processing) {
      return false;
    }

    _updateTransactionStatus(transactionId, DepositStatus.cancelled);
    return true;
  }

  /// Get supported deposit methods
  static List<DepositMethod> getSupportedMethods() {
    return [
      DepositMethod(
        id: 'mtn_mobile_money',
        name: 'MTN Mobile Money',
        description: 'Deposit using MTN Mobile Money',
        iconAsset: 'assets/images/mtn_logo.png',
        color: const Color(0xFFFFD700), // Gold
        minAmount: 1000.0,
        maxAmount: 1000000.0,
        fee: 0.02, // 2%
        processingTime: '2-5 minutes',
        isActive: true,
        supportedCurrencies: ['UGX', 'USD'],
      ),
      DepositMethod(
        id: 'airtel_money',
        name: 'Airtel Money',
        description: 'Deposit using Airtel Money',
        iconAsset: 'assets/images/airtel_logo.png',
        color: const Color(0xFFE53E3E), // Red
        minAmount: 1000.0,
        maxAmount: 1000000.0,
        fee: 0.02, // 2%
        processingTime: '2-5 minutes',
        isActive: true,
        supportedCurrencies: ['UGX', 'USD'],
      ),
      DepositMethod(
        id: 'bank_transfer',
        name: 'Bank Transfer',
        description: 'Deposit via bank transfer',
        iconAsset: 'assets/images/bank_logo.png',
        color: const Color(0xFF3182CE), // Blue
        minAmount: 10000.0,
        maxAmount: 10000000.0,
        fee: 0.01, // 1%
        processingTime: '1-3 business days',
        isActive: true,
        supportedCurrencies: ['UGX', 'USD'],
      ),
      DepositMethod(
        id: 'visa_mastercard',
        name: 'Visa/Mastercard',
        description: 'Deposit using your debit/credit card',
        iconAsset: 'assets/images/card_logo.png',
        color: const Color(0xFF553C9A), // Indigo
        minAmount: 5000.0,
        maxAmount: 2000000.0,
        fee: 0.035, // 3.5%
        processingTime: 'Instant',
        isActive: true,
        supportedCurrencies: ['USD', 'UGX'],
      ),
    ];
  }

  /// Get deposit statistics
  static Map<String, dynamic> getDepositStats() {
    final transactions = getAllTransactions();
    
    double totalDeposited = 0;
    double totalFees = 0;
    int successfulDeposits = 0;
    int failedDeposits = 0;
    
    for (final transaction in transactions) {
      if (transaction.status == DepositStatus.completed) {
        totalDeposited += transaction.amount;
        totalFees += transaction.fee;
        successfulDeposits++;
      } else if (transaction.status == DepositStatus.failed) {
        failedDeposits++;
      }
    }
    
    return {
      'totalTransactions': transactions.length,
      'totalDeposited': totalDeposited,
      'totalFees': totalFees,
      'successfulDeposits': successfulDeposits,
      'failedDeposits': failedDeposits,
      'successRate': transactions.isNotEmpty 
          ? (successfulDeposits / transactions.length * 100).toStringAsFixed(1)
          : '0.0',
    };
  }
}