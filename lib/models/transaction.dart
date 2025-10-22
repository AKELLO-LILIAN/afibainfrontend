enum TransactionType {
  payment,
  salary,
  refund,
  transfer,
  merchant,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class TransactionModel {
  final String hash;
  final TransactionType type;
  final double amount;
  final String currency;
  final String fromAddress;
  final String toAddress;
  final String description;
  final DateTime timestamp;
  final TransactionStatus status;
  final double fee;
  final String? merchantName;
  final String? localCurrency;
  final double? localAmount;
  final String? errorMessage;
  final int? blockNumber;
  final int? confirmations;

  TransactionModel({
    required this.hash,
    required this.type,
    required this.amount,
    required this.currency,
    required this.fromAddress,
    required this.toAddress,
    required this.description,
    required this.timestamp,
    required this.status,
    this.fee = 0.0,
    this.merchantName,
    this.localCurrency,
    this.localAmount,
    this.errorMessage,
    this.blockNumber,
    this.confirmations,
  });

  // Create a copy with modified fields
  TransactionModel copyWith({
    String? hash,
    TransactionType? type,
    double? amount,
    String? currency,
    String? fromAddress,
    String? toAddress,
    String? description,
    DateTime? timestamp,
    TransactionStatus? status,
    double? fee,
    String? merchantName,
    String? localCurrency,
    double? localAmount,
    String? errorMessage,
    int? blockNumber,
    int? confirmations,
  }) {
    return TransactionModel(
      hash: hash ?? this.hash,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      fee: fee ?? this.fee,
      merchantName: merchantName ?? this.merchantName,
      localCurrency: localCurrency ?? this.localCurrency,
      localAmount: localAmount ?? this.localAmount,
      errorMessage: errorMessage ?? this.errorMessage,
      blockNumber: blockNumber ?? this.blockNumber,
      confirmations: confirmations ?? this.confirmations,
    );
  }

  // Get display string for transaction type
  String get typeDisplayName {
    switch (type) {
      case TransactionType.payment:
        return 'Payment';
      case TransactionType.salary:
        return 'Salary';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.merchant:
        return 'Merchant Sale';
    }
  }

  // Get display string for status
  String get statusDisplayName {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Check if transaction is incoming
  bool isIncoming(String userAddress) {
    return toAddress.toLowerCase() == userAddress.toLowerCase();
  }

  // Get formatted amount string
  String get formattedAmount {
    return '${amount.toStringAsFixed(2)} $currency';
  }

  // Get short hash for display
  String get shortHash {
    return '${hash.substring(0, 10)}...${hash.substring(hash.length - 8)}';
  }

  // Get formatted fee
  String get formattedFee {
    return '${fee.toStringAsFixed(4)} ETH';
  }

  // Get formatted timestamp
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  String toString() {
    return 'TransactionModel(hash: $hash, type: $type, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel && other.hash == hash;
  }

  @override
  int get hashCode => hash.hashCode;
}

// Alias for backward compatibility
typedef Transaction = TransactionModel;

// Constructor helper
Transaction createTransaction({
  required String id,
  required TransactionType type,
  required double amount,
  required String currency,
  required String toAddress,
  required String fromAddress,
  required TransactionStatus status,
  required DateTime timestamp,
  required String description,
  required double fee,
  String? txHash,
}) {
  return TransactionModel(
    hash: txHash ?? id,
    type: type,
    amount: amount,
    currency: currency,
    fromAddress: fromAddress,
    toAddress: toAddress,
    status: status,
    timestamp: timestamp,
    description: description,
    fee: fee,
  );
}
