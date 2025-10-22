import 'package:flutter/material.dart';

enum TokenType {
  stable,
  volatile,
  synthetic,
  local,
}

enum TokenCategory {
  fiatBacked,
  cryptoBacked,
  algorithmic,
  native,
  wrapped,
  syntheticAsset,
  localCurrency,
}

class Token {
  final String address;
  final String symbol;
  final String name;
  final int decimals;
  final TokenType type;
  final TokenCategory category;
  final String description;
  final String iconUrl;
  final bool isActive;
  final bool isSupported;
  final double minAmount;
  final double maxAmount;
  final double dailyLimit;
  final double? currentPrice; // Price in USD
  final double? priceChange24h; // 24h price change percentage
  final DateTime lastUpdated;

  const Token({
    required this.address,
    required this.symbol,
    required this.name,
    required this.decimals,
    required this.type,
    required this.category,
    required this.description,
    required this.iconUrl,
    required this.isActive,
    required this.isSupported,
    required this.minAmount,
    required this.maxAmount,
    required this.dailyLimit,
    this.currentPrice,
    this.priceChange24h,
    required this.lastUpdated,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      address: json['address'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      decimals: json['decimals'] as int,
      type: TokenType.values[json['type'] as int],
      category: TokenCategory.values[json['category'] as int],
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      isActive: json['isActive'] as bool,
      isSupported: json['isSupported'] as bool,
      minAmount: (json['minAmount'] as num).toDouble(),
      maxAmount: (json['maxAmount'] as num).toDouble(),
      dailyLimit: (json['dailyLimit'] as num).toDouble(),
      currentPrice: json['currentPrice'] != null ? (json['currentPrice'] as num).toDouble() : null,
      priceChange24h: json['priceChange24h'] != null ? (json['priceChange24h'] as num).toDouble() : null,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'symbol': symbol,
      'name': name,
      'decimals': decimals,
      'type': type.index,
      'category': category.index,
      'description': description,
      'iconUrl': iconUrl,
      'isActive': isActive,
      'isSupported': isSupported,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'dailyLimit': dailyLimit,
      'currentPrice': currentPrice,
      'priceChange24h': priceChange24h,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  Token copyWith({
    String? address,
    String? symbol,
    String? name,
    int? decimals,
    TokenType? type,
    TokenCategory? category,
    String? description,
    String? iconUrl,
    bool? isActive,
    bool? isSupported,
    double? minAmount,
    double? maxAmount,
    double? dailyLimit,
    double? currentPrice,
    double? priceChange24h,
    DateTime? lastUpdated,
  }) {
    return Token(
      address: address ?? this.address,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      decimals: decimals ?? this.decimals,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      isActive: isActive ?? this.isActive,
      isSupported: isSupported ?? this.isSupported,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChange24h: priceChange24h ?? this.priceChange24h,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Token && other.address == address;
  }

  @override
  int get hashCode => address.hashCode;

  @override
  String toString() {
    return 'Token(symbol: $symbol, name: $name, type: $type, price: \$${currentPrice?.toStringAsFixed(2) ?? "N/A"})';
  }

  // Helper methods
  bool get isStable => type == TokenType.stable;
  bool get isVolatile => type == TokenType.volatile;
  
  String get typeDisplayName {
    switch (type) {
      case TokenType.stable:
        return 'Stable Coin';
      case TokenType.volatile:
        return 'Volatile Token';
      case TokenType.synthetic:
        return 'Synthetic Asset';
      case TokenType.local:
        return 'Local Currency';
    }
  }

  String get categoryDisplayName {
    switch (category) {
      case TokenCategory.fiatBacked:
        return 'Fiat-Backed';
      case TokenCategory.cryptoBacked:
        return 'Crypto-Backed';
      case TokenCategory.algorithmic:
        return 'Algorithmic';
      case TokenCategory.native:
        return 'Native Token';
      case TokenCategory.wrapped:
        return 'Wrapped Token';
      case TokenCategory.syntheticAsset:
        return 'Synthetic Asset';
      case TokenCategory.localCurrency:
        return 'Local Currency';
    }
  }

  Color get typeColor {
    switch (type) {
      case TokenType.stable:
        return const Color(0xFF10B981); // Green
      case TokenType.volatile:
        return const Color(0xFFF59E0B); // Orange
      case TokenType.synthetic:
        return const Color(0xFF8B5CF6); // Purple
      case TokenType.local:
        return const Color(0xFF06B6D4); // Cyan
    }
  }
}

class TokenBalance {
  final Token token;
  final double balance;
  final double valueInUSD;
  final DateTime lastUpdated;

  const TokenBalance({
    required this.token,
    required this.balance,
    required this.valueInUSD,
    required this.lastUpdated,
  });

  factory TokenBalance.fromJson(Map<String, dynamic> json) {
    return TokenBalance(
      token: Token.fromJson(json['token'] as Map<String, dynamic>),
      balance: (json['balance'] as num).toDouble(),
      valueInUSD: (json['valueInUSD'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token.toJson(),
      'balance': balance,
      'valueInUSD': valueInUSD,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  TokenBalance copyWith({
    Token? token,
    double? balance,
    double? valueInUSD,
    DateTime? lastUpdated,
  }) {
    return TokenBalance(
      token: token ?? this.token,
      balance: balance ?? this.balance,
      valueInUSD: valueInUSD ?? this.valueInUSD,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'TokenBalance(${token.symbol}: ${balance.toStringAsFixed(6)}, value: \$${valueInUSD.toStringAsFixed(2)})';
  }
}

class ConversionQuote {
  final Token fromToken;
  final Token toToken;
  final double amountIn;
  final double amountOut;
  final double exchangeRate;
  final double fee;
  final double priceImpact;
  final double slippageTolerance;
  final DateTime validUntil;

  const ConversionQuote({
    required this.fromToken,
    required this.toToken,
    required this.amountIn,
    required this.amountOut,
    required this.exchangeRate,
    required this.fee,
    required this.priceImpact,
    required this.slippageTolerance,
    required this.validUntil,
  });

  factory ConversionQuote.fromJson(Map<String, dynamic> json) {
    return ConversionQuote(
      fromToken: Token.fromJson(json['fromToken'] as Map<String, dynamic>),
      toToken: Token.fromJson(json['toToken'] as Map<String, dynamic>),
      amountIn: (json['amountIn'] as num).toDouble(),
      amountOut: (json['amountOut'] as num).toDouble(),
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      priceImpact: (json['priceImpact'] as num).toDouble(),
      slippageTolerance: (json['slippageTolerance'] as num).toDouble(),
      validUntil: DateTime.parse(json['validUntil'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromToken': fromToken.toJson(),
      'toToken': toToken.toJson(),
      'amountIn': amountIn,
      'amountOut': amountOut,
      'exchangeRate': exchangeRate,
      'fee': fee,
      'priceImpact': priceImpact,
      'slippageTolerance': slippageTolerance,
      'validUntil': validUntil.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);
  
  bool get hasHighPriceImpact => priceImpact > 5.0; // 5%
  
  String get priceImpactLevel {
    if (priceImpact < 1.0) return 'Low';
    if (priceImpact < 3.0) return 'Medium';
    return 'High';
  }

  Color get priceImpactColor {
    if (priceImpact < 1.0) return const Color(0xFF10B981); // Green
    if (priceImpact < 3.0) return const Color(0xFFF59E0B); // Orange
    return const Color(0xFFEF4444); // Red
  }

  @override
  String toString() {
    return 'ConversionQuote(${amountIn.toStringAsFixed(6)} ${fromToken.symbol} → ${amountOut.toStringAsFixed(6)} ${toToken.symbol})';
  }
}