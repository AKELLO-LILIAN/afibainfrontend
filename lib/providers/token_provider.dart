import 'package:flutter/foundation.dart';
import '../models/token.dart';
import '../services/blockchain_service.dart';

class TokenProvider extends ChangeNotifier {
  // Blockchain service instance
  final BlockchainService _blockchainService = BlockchainService();
  
  // Available tokens by type
  final Map<TokenType, List<Token>> _tokensByType = {};
  
  // User's token balances
  final Map<String, TokenBalance> _balances = {};
  
  // Current conversion quote
  ConversionQuote? _currentQuote;
  
  // Loading states
  bool _isLoadingTokens = false;
  bool _isLoadingBalances = false;
  bool _isLoadingQuote = false;
  bool _isConverting = false;
  
  // Selected tokens for conversion
  Token? _selectedFromToken;
  Token? _selectedToToken;
  
  // Conversion amount
  double _conversionAmount = 0.0;
  
  // Default slippage tolerance (3%)
  double _slippageTolerance = 3.0;
  
  // Error state
  String? _error;

  // Getters
  Map<TokenType, List<Token>> get tokensByType => _tokensByType;
  Map<String, TokenBalance> get balances => _balances;
  ConversionQuote? get currentQuote => _currentQuote;
  bool get isLoadingTokens => _isLoadingTokens;
  bool get isLoadingBalances => _isLoadingBalances;
  bool get isLoadingQuote => _isLoadingQuote;
  bool get isConverting => _isConverting;
  Token? get selectedFromToken => _selectedFromToken;
  Token? get selectedToToken => _selectedToToken;
  double get conversionAmount => _conversionAmount;
  double get slippageTolerance => _slippageTolerance;
  String? get error => _error;

  // Helper getters
  List<Token> get allTokens {
    final List<Token> tokens = [];
    _tokensByType.values.forEach(tokens.addAll);
    return tokens;
  }

  List<Token> get stableCoins => _tokensByType[TokenType.stable] ?? [];
  List<Token> get volatileTokens => _tokensByType[TokenType.volatile] ?? [];
  List<Token> get syntheticAssets => _tokensByType[TokenType.synthetic] ?? [];
  List<Token> get localCurrencies => _tokensByType[TokenType.local] ?? [];

  List<TokenBalance> get allBalances => _balances.values.toList();
  
  double get totalPortfolioValue {
    return _balances.values.fold(0.0, (sum, balance) => sum + balance.valueInUSD);
  }

  Map<TokenType, double> get portfolioByType {
    final Map<TokenType, double> breakdown = {};
    for (final balance in _balances.values) {
      breakdown[balance.token.type] = 
          (breakdown[balance.token.type] ?? 0.0) + balance.valueInUSD;
    }
    return breakdown;
  }

  bool get canConvert {
    return _selectedFromToken != null &&
           _selectedToToken != null &&
           _conversionAmount > 0 &&
           !_isConverting &&
           _currentQuote != null &&
           !_currentQuote!.isExpired;
  }

  // Initialize with blockchain data
  Future<void> initialize([String? userAddress]) async {
    _isLoadingTokens = true;
    _error = null;
    notifyListeners();

    try {
      // Initialize blockchain service with user address if provided
      if (userAddress != null) {
        _blockchainService.initialize(userAddress);
      }
      
      await _loadTokens();
      
      // Only load balances if user address is provided
      if (userAddress != null) {
        await _loadBalances();
      }
    } catch (e) {
      _error = e.toString();
      print('TokenProvider initialization error: $e');
    } finally {
      _isLoadingTokens = false;
      notifyListeners();
    }
  }

  Future<void> _loadTokens() async {
    try {
      // Get available tokens from blockchain service
      final allTokens = await _blockchainService.getAvailableTokens();
      
      // Get African currencies
      final africanCurrencies = await _blockchainService.getAfricanCurrencies();
      allTokens.addAll(africanCurrencies);
      
      // Clear existing tokens
      _tokensByType.clear();
      
      // Group tokens by type
      for (final token in allTokens) {
        if (_tokensByType[token.type] == null) {
          _tokensByType[token.type] = [];
        }
        _tokensByType[token.type]!.add(token);
      }
      
      // Ensure all token types have lists (even if empty)
      for (final type in TokenType.values) {
        _tokensByType[type] ??= [];
      }
    } catch (e) {
      print('Error loading tokens: $e');
      // Fall back to mock data if blockchain service fails
      await _loadMockTokens();
    }
  }
  
  // Fallback method with mock tokens
  Future<void> _loadMockTokens() async {
    // Mock stable coins (keeping existing implementation as fallback)
    final stableCoins = [
      Token(
        address: '0x799A5f2A46FB1Cd2717C60d53FBbB6282CCf9A09',
        symbol: 'USDC',
        name: 'Mock USD Coin',
        decimals: 6,
        type: TokenType.stable,
        category: TokenCategory.fiatBacked,
        description: 'Fiat-backed stablecoin pegged to USD',
        iconUrl: 'https://cryptologos.cc/logos/usd-coin-usdc-logo.png',
        isActive: true,
        isSupported: true,
        minAmount: 0.01,
        maxAmount: 1000000.0,
        dailyLimit: 100000.0,
        currentPrice: 1.00,
        priceChange24h: 0.02,
        lastUpdated: DateTime.now(),
      ),
      Token(
        address: '0x937D07e3A47916B5B44F1749304ce1779E2e5458',
        symbol: 'USDT',
        name: 'Mock Tether USD',
        decimals: 6,
        type: TokenType.stable,
        category: TokenCategory.fiatBacked,
        description: 'Fiat-backed stablecoin pegged to USD',
        iconUrl: 'https://cryptologos.cc/logos/tether-usdt-logo.png',
        isActive: true,
        isSupported: true,
        minAmount: 0.01,
        maxAmount: 1000000.0,
        dailyLimit: 100000.0,
        currentPrice: 0.999,
        priceChange24h: -0.01,
        lastUpdated: DateTime.now(),
      ),
    ];

    _tokensByType[TokenType.stable] = stableCoins;
    _tokensByType[TokenType.volatile] = [];
    _tokensByType[TokenType.synthetic] = [];
    _tokensByType[TokenType.local] = [];
  }

  Future<void> _loadBalances() async {
    _isLoadingBalances = true;
    notifyListeners();

    try {
      // Get all available tokens
      final tokens = allTokens;
      if (tokens.isEmpty) {
        return;
      }
      
      // Get real balances from blockchain service
      final realBalances = await _blockchainService.getUserTokenBalances(tokens);
      
      // Update balances
      _balances.clear();
      _balances.addAll(realBalances);
      
      // If no real balances, add some mock balances for demonstration
      if (_balances.isEmpty) {
        await _loadMockBalances();
      }
      
    } catch (e) {
      _error = e.toString();
      print('Error loading balances: $e');
      // Fall back to mock balances
      await _loadMockBalances();
    } finally {
      _isLoadingBalances = false;
      notifyListeners();
    }
  }
  
  // Fallback method for mock balances
  Future<void> _loadMockBalances() async {
    final now = DateTime.now();
    
    // Add some mock balances for demonstration
    if (_tokensByType[TokenType.stable]!.isNotEmpty) {
      final usdc = _tokensByType[TokenType.stable]![0];
      _balances[usdc.address] = TokenBalance(
        token: usdc,
        balance: 1500.0,
        valueInUSD: 1500.0,
        lastUpdated: now,
      );
      
      if (_tokensByType[TokenType.stable]!.length > 1) {
        final usdt = _tokensByType[TokenType.stable]![1];
        _balances[usdt.address] = TokenBalance(
          token: usdt,
          balance: 800.0,
          valueInUSD: 799.2,
          lastUpdated: now,
        );
      }
    }
  }

  // Token selection methods
  void selectFromToken(Token token) {
    _selectedFromToken = token;
    _currentQuote = null;
    notifyListeners();
    
    if (_selectedToToken != null && _conversionAmount > 0) {
      _getConversionQuote();
    }
  }

  void selectToToken(Token token) {
    _selectedToToken = token;
    _currentQuote = null;
    notifyListeners();
    
    if (_selectedFromToken != null && _conversionAmount > 0) {
      _getConversionQuote();
    }
  }

  void swapTokens() {
    final temp = _selectedFromToken;
    _selectedFromToken = _selectedToToken;
    _selectedToToken = temp;
    _currentQuote = null;
    notifyListeners();
    
    if (_selectedFromToken != null && _selectedToToken != null && _conversionAmount > 0) {
      _getConversionQuote();
    }
  }

  void setConversionAmount(double amount) {
    _conversionAmount = amount;
    _currentQuote = null;
    notifyListeners();
    
    if (_selectedFromToken != null && _selectedToToken != null && amount > 0) {
      _getConversionQuote();
    }
  }

  void setSlippageTolerance(double tolerance) {
    _slippageTolerance = tolerance;
    notifyListeners();
    
    if (_selectedFromToken != null && _selectedToToken != null && _conversionAmount > 0) {
      _getConversionQuote();
    }
  }

  // Get conversion quote
  Future<void> _getConversionQuote() async {
    if (_selectedFromToken == null || _selectedToToken == null || _conversionAmount <= 0) {
      return;
    }

    _isLoadingQuote = true;
    _error = null;
    notifyListeners();

    try {
      // Get quote from blockchain service
      _currentQuote = await _blockchainService.getConversionQuote(
        fromToken: _selectedFromToken!,
        toToken: _selectedToToken!,
        amount: _conversionAmount,
        slippageTolerance: _slippageTolerance,
      );
    } catch (e) {
      _error = e.toString();
      print('Error getting conversion quote: $e');
    } finally {
      _isLoadingQuote = false;
      notifyListeners();
    }
  }

  // Execute conversion
  Future<void> executeConversion() async {
    if (!canConvert) return;

    _isConverting = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate blockchain transaction
      await Future.delayed(const Duration(seconds: 3));

      // Update balances (mock)
      final fromAddress = _selectedFromToken!.address;
      final toAddress = _selectedToToken!.address;
      
      // Deduct from balance
      if (_balances.containsKey(fromAddress)) {
        final fromBalance = _balances[fromAddress]!;
        _balances[fromAddress] = fromBalance.copyWith(
          balance: fromBalance.balance - _conversionAmount,
          valueInUSD: (fromBalance.balance - _conversionAmount) * (_selectedFromToken!.currentPrice ?? 1.0),
          lastUpdated: DateTime.now(),
        );
      }

      // Add to balance
      if (_balances.containsKey(toAddress)) {
        final toBalance = _balances[toAddress]!;
        _balances[toAddress] = toBalance.copyWith(
          balance: toBalance.balance + _currentQuote!.amountOut,
          valueInUSD: (toBalance.balance + _currentQuote!.amountOut) * (_selectedToToken!.currentPrice ?? 1.0),
          lastUpdated: DateTime.now(),
        );
      } else {
        _balances[toAddress] = TokenBalance(
          token: _selectedToToken!,
          balance: _currentQuote!.amountOut,
          valueInUSD: _currentQuote!.amountOut * (_selectedToToken!.currentPrice ?? 1.0),
          lastUpdated: DateTime.now(),
        );
      }

      // Clear conversion state
      _selectedFromToken = null;
      _selectedToToken = null;
      _conversionAmount = 0.0;
      _currentQuote = null;
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isConverting = false;
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await initialize();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Filter methods
  List<Token> getTokensByType(TokenType type) {
    return _tokensByType[type] ?? [];
  }

  List<Token> getTokensByCategory(TokenCategory category) {
    final List<Token> tokens = [];
    for (final tokenList in _tokensByType.values) {
      tokens.addAll(tokenList.where((token) => token.category == category));
    }
    return tokens;
  }

  TokenBalance? getBalance(String tokenAddress) {
    return _balances[tokenAddress];
  }

  // Search tokens
  List<Token> searchTokens(String query) {
    if (query.isEmpty) return allTokens;
    
    final lowerQuery = query.toLowerCase();
    return allTokens.where((token) {
      return token.symbol.toLowerCase().contains(lowerQuery) ||
             token.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  @override
  void dispose() {
    _blockchainService.dispose();
    super.dispose();
  }
}
