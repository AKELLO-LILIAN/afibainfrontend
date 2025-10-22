import 'package:flutter/material.dart';

class DepositMethod {
  final String id;
  final String name;
  final String description;
  final String iconAsset;
  final Color color;
  final double minAmount;
  final double maxAmount;
  final double fee; // As percentage (0.02 = 2%)
  final String processingTime;
  final bool isActive;
  final List<String> supportedCurrencies;

  const DepositMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.color,
    required this.minAmount,
    required this.maxAmount,
    required this.fee,
    required this.processingTime,
    required this.isActive,
    required this.supportedCurrencies,
  });

  String get feePercentage => '${(fee * 100).toStringAsFixed(1)}%';
  
  double calculateFee(double amount) => amount * fee;
  
  double calculateTotal(double amount) => amount + calculateFee(amount);
  
  bool isAmountValid(double amount) {
    return amount >= minAmount && amount <= maxAmount;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconAsset': iconAsset,
      'color': color.value,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'fee': fee,
      'processingTime': processingTime,
      'isActive': isActive,
      'supportedCurrencies': supportedCurrencies,
    };
  }
  
  factory DepositMethod.fromJson(Map<String, dynamic> json) {
    return DepositMethod(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconAsset: json['iconAsset'],
      color: Color(json['color']),
      minAmount: json['minAmount'].toDouble(),
      maxAmount: json['maxAmount'].toDouble(),
      fee: json['fee'].toDouble(),
      processingTime: json['processingTime'],
      isActive: json['isActive'],
      supportedCurrencies: List<String>.from(json['supportedCurrencies']),
    );
  }
}

class DepositRequest {
  final DepositMethod method;
  final double amount;
  final String phoneNumber;
  final String accountNumber;
  final String currency;
  final Map<String, dynamic> additionalData;

  const DepositRequest({
    required this.method,
    required this.amount,
    this.phoneNumber = '',
    this.accountNumber = '',
    this.currency = 'UGX',
    this.additionalData = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'methodId': method.id,
      'amount': amount,
      'phoneNumber': phoneNumber,
      'accountNumber': accountNumber,
      'currency': currency,
      'additionalData': additionalData,
    };
  }
}

class DepositResult {
  final bool success;
  final String transactionId;
  final String status;
  final double amount;
  final String methodName;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  const DepositResult({
    required this.success,
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.methodName,
    this.errorMessage,
    this.metadata = const {},
  });

  factory DepositResult.success({
    required String transactionId,
    required double amount,
    required String methodName,
    String status = 'pending',
    Map<String, dynamic> metadata = const {},
  }) {
    return DepositResult(
      success: true,
      transactionId: transactionId,
      status: status,
      amount: amount,
      methodName: methodName,
      metadata: metadata,
    );
  }

  factory DepositResult.failure({
    required String errorMessage,
    String transactionId = '',
    double amount = 0.0,
    String methodName = '',
    Map<String, dynamic> metadata = const {},
  }) {
    return DepositResult(
      success: false,
      transactionId: transactionId,
      status: 'failed',
      amount: amount,
      methodName: methodName,
      errorMessage: errorMessage,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'transactionId': transactionId,
      'status': status,
      'amount': amount,
      'methodName': methodName,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  factory DepositResult.fromJson(Map<String, dynamic> json) {
    return DepositResult(
      success: json['success'],
      transactionId: json['transactionId'],
      status: json['status'],
      amount: json['amount'].toDouble(),
      methodName: json['methodName'],
      errorMessage: json['errorMessage'],
      metadata: json['metadata'] ?? {},
    );
  }
}

enum DepositStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

class DepositTransaction {
  final String id;
  final String methodId;
  final String methodName;
  final double amount;
  final double fee;
  final double total;
  final String currency;
  final DepositStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final Map<String, dynamic> metadata;

  const DepositTransaction({
    required this.id,
    required this.methodId,
    required this.methodName,
    required this.amount,
    required this.fee,
    required this.total,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    this.metadata = const {},
  });

  String get statusText {
    switch (status) {
      case DepositStatus.pending:
        return 'Pending';
      case DepositStatus.processing:
        return 'Processing';
      case DepositStatus.completed:
        return 'Completed';
      case DepositStatus.failed:
        return 'Failed';
      case DepositStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case DepositStatus.pending:
        return Colors.orange;
      case DepositStatus.processing:
        return Colors.blue;
      case DepositStatus.completed:
        return Colors.green;
      case DepositStatus.failed:
        return Colors.red;
      case DepositStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case DepositStatus.pending:
        return Icons.access_time;
      case DepositStatus.processing:
        return Icons.sync;
      case DepositStatus.completed:
        return Icons.check_circle;
      case DepositStatus.failed:
        return Icons.error;
      case DepositStatus.cancelled:
        return Icons.cancel;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'methodId': methodId,
      'methodName': methodName,
      'amount': amount,
      'fee': fee,
      'total': total,
      'currency': currency,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'failureReason': failureReason,
      'metadata': metadata,
    };
  }

  factory DepositTransaction.fromJson(Map<String, dynamic> json) {
    return DepositTransaction(
      id: json['id'],
      methodId: json['methodId'],
      methodName: json['methodName'],
      amount: json['amount'].toDouble(),
      fee: json['fee'].toDouble(),
      total: json['total'].toDouble(),
      currency: json['currency'],
      status: DepositStatus.values[json['status']],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      failureReason: json['failureReason'],
      metadata: json['metadata'] ?? {},
    );
  }
}