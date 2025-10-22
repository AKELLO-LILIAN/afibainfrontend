import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import '../models/token.dart';
import '../config/app_config.dart';

class BlockchainService {
  // Get configuration from AppConfig
  static String get rpcUrl => AppConfig.rpcUrl;
  static String get chainId => AppConfig.chainId;
  
  // Contract addresses
  static String get afriBainCoreAddress => AppConfig.afriBainCoreAddress;
  static String get tokenTypeManagerAddress => AppConfig.tokenTypeManagerAddress;
  static String get crossTokenConverterAddress => AppConfig.crossTokenConverterAddress;
  static String get stableCoinManagerAddress => AppConfig.stableCoinManagerAddress;
  
  // Token addresses
  static String get usdcAddress => AppConfig.usdcAddress;
  static String get usdtAddress => AppConfig.usdtAddress;
  static String get wethAddress => AppConfig.wethAddress;
  static String get wbtcAddress => AppConfig.wbtcAddress;
  static String get bnbAddress => AppConfig.bnbAddress;
  
  late Web3Client _client;
  late EthereumAddress _userAddress;
  
  BlockchainService() {
    try {
      _client = Web3Client(rpcUrl, http.Client());
      if (AppConfig.enableLogging) {
        print('BlockchainService initialized with RPC: $rpcUrl');
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('Error initializing BlockchainService: $e');
      }
      rethrow;
    }
  }
  
  // Initialize with user's wallet address
  void initialize(String userAddress) {
    _userAddress = EthereumAddress.fromHex(userAddress);
  }
  
  // ERC20 ABI for balance queries
  static const String erc20ABI = '''
  [
    {
      "constant": true,
      "inputs": [{"name": "_owner", "type": "address"}],
      "name": "balanceOf",
      "outputs": [{"name": "balance", "type": "uint256"}],
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "decimals",
      "outputs": [{"name": "", "type": "uint8"}],
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "symbol",
      "outputs": [{"name": "", "type": "string"}],
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "name",
      "outputs": [{"name": "", "type": "string"}],
      "type": "function"
    }
  ]
  ''';
  
  // Get available tokens from deployed contracts
  Future<List<Token>> getAvailableTokens() async {
    try {
      // Use mock data only if explicitly configured
      final shouldUseMockData = AppConfig.useMockData;
      
      if (AppConfig.enableLogging) {
        print('BlockchainService: Using mock data: $shouldUseMockData');
        print('BlockchainService: RPC URL: ${rpcUrl.substring(0, rpcUrl.length.clamp(0, 50))}...');
        print('BlockchainService: Private key configured: ${AppConfig.privateKey.isNotEmpty}');
      }
      
      // For now, return the tokens that were deployed in your script
      final tokens = <Token>[
        Token(
          address: usdcAddress,
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
          currentPrice: shouldUseMockData ? 1.00 : (await _getTokenPrice(usdcAddress) ?? 1.00),
          priceChange24h: 0.02,
          lastUpdated: DateTime.now(),
        ),
        Token(
          address: usdtAddress,
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
          currentPrice: shouldUseMockData ? 0.999 : (await _getTokenPrice(usdtAddress) ?? 0.999),
          priceChange24h: -0.01,
          lastUpdated: DateTime.now(),
        ),
        // Add some mock volatile tokens for testing
        Token(
          address: '0x4200000000000000000000000000000000000006', // Mock WETH
          symbol: 'WETH',
          name: 'Mock Wrapped Ether',
          decimals: 18,
          type: TokenType.volatile,
          category: TokenCategory.wrapped,
          description: 'Wrapped Ethereum token',
          iconUrl: 'https://cryptologos.cc/logos/ethereum-eth-logo.png',
          isActive: true,
          isSupported: true,
          minAmount: 0.001,
          maxAmount: 10000.0,
          dailyLimit: 1000.0,
          currentPrice: shouldUseMockData ? 2500.00 : (await _getTokenPrice('0x4200000000000000000000000000000000000006') ?? 2500.00),
          priceChange24h: 3.45,
          lastUpdated: DateTime.now(),
        ),
      ];
      
      if (AppConfig.enableLogging) {
        print('BlockchainService: Loaded ${tokens.length} tokens');
      }
      
      return tokens;
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('BlockchainService: Error fetching tokens: $e');
      }
      throw Exception('Failed to fetch available tokens: $e');
    }
  }
  
  // Get user's token balances
  Future<Map<String, TokenBalance>> getUserTokenBalances(List<Token> tokens) async {
    final balances = <String, TokenBalance>{};
    
    try {
      for (final token in tokens) {
        final balance = await _getTokenBalance(token.address, token.decimals);
        if (balance > 0) {
          balances[token.address] = TokenBalance(
            token: token,
            balance: balance,
            valueInUSD: balance * (token.currentPrice ?? 0.0),
            lastUpdated: DateTime.now(),
          );
        }
      }
      
      return balances;
    } catch (e) {
      throw Exception('Failed to fetch token balances: $e');
    }
  }
  
  // Get token balance for a specific token
  Future<double> _getTokenBalance(String tokenAddress, int decimals) async {
    try {
      // Check if RPC URL is properly configured
      if (rpcUrl.contains('YOUR_INFURA_PROJECT_ID')) {
        print('Warning: RPC URL not configured, returning mock balance');
        return 0.0;
      }
      
      final contract = DeployedContract(
        ContractAbi.fromJson(erc20ABI, 'ERC20'),
        EthereumAddress.fromHex(tokenAddress),
      );
      
      final balanceFunction = contract.function('balanceOf');
      final result = await _client.call(
        contract: contract,
        function: balanceFunction,
        params: [_userAddress],
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Balance query timed out', const Duration(seconds: 10)),
      );
      
      final balanceWei = result[0] as BigInt;
      final balance = balanceWei / BigInt.from(10).pow(decimals);
      
      return balance.toDouble();
    } catch (e) {
      print('Error fetching balance for $tokenAddress: $e');
      return 0.0;
    }
  }
  
  // Get token price (mock implementation - in production, use a price oracle)
  Future<double?> _getTokenPrice(String tokenAddress) async {
    // Mock prices for development
    final mockPrices = {
      usdcAddress: 1.00,
      usdtAddress: 0.999,
      if (wethAddress != '0x...') wethAddress: 2500.00,
      if (wbtcAddress != '0x...') wbtcAddress: 45000.00,
      if (bnbAddress != '0x...') bnbAddress: 300.00,
    };
    
    return mockPrices[tokenAddress];
  }
  
  // Get conversion quote from CrossTokenConverter
  Future<ConversionQuote> getConversionQuote({
    required Token fromToken,
    required Token toToken,
    required double amount,
    required double slippageTolerance,
  }) async {
    try {
      // Mock implementation - in production, call your CrossTokenConverter contract
      final fromPrice = fromToken.currentPrice ?? 1.0;
      final toPrice = toToken.currentPrice ?? 1.0;
      
      final exchangeRate = fromPrice / toPrice;
      final amountOut = amount * exchangeRate;
      
      // Calculate fees based on token types
      double feeRate = 0.001; // 0.1% default
      if (fromToken.isVolatile || toToken.isVolatile) {
        feeRate = 0.003; // 0.3% for volatile tokens
      }
      
      final fee = amountOut * feeRate;
      final finalAmountOut = amountOut - fee;
      
      // Mock price impact
      final priceImpact = (amount / 10000) * 0.5;
      
      return ConversionQuote(
        fromToken: fromToken,
        toToken: toToken,
        amountIn: amount,
        amountOut: finalAmountOut,
        exchangeRate: exchangeRate,
        fee: fee,
        priceImpact: priceImpact,
        slippageTolerance: slippageTolerance,
        validUntil: DateTime.now().add(const Duration(minutes: 2)),
      );
    } catch (e) {
      throw Exception('Failed to get conversion quote: $e');
    }
  }
  
  // Execute token conversion
  Future<String> executeConversion({
    required Token fromToken,
    required Token toToken,
    required double amount,
    required double slippageTolerance,
    required String privateKey,
  }) async {
    try {
      // Mock implementation - in production, call your CrossTokenConverter contract
      await Future.delayed(const Duration(seconds: 2));
      
      // Return mock transaction hash
      return '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
    } catch (e) {
      throw Exception('Failed to execute conversion: $e');
    }
  }
  
  // Get African currencies from your deployed contracts
  Future<List<Token>> getAfricanCurrencies() async {
    try {
      // Mock implementation - in production, fetch from your CurrencyConverter contract
      return [
        Token(
          address: '0x...', // Synthetic NGN address
          symbol: 'NGN',
          name: 'Nigerian Naira',
          decimals: 18,
          type: TokenType.local,
          category: TokenCategory.syntheticAsset,
          description: 'Synthetic Nigerian Naira',
          iconUrl: '',
          isActive: true,
          isSupported: true,
          minAmount: 1.0,
          maxAmount: 10000000.0,
          dailyLimit: 1000000.0,
          currentPrice: 0.0012, // 1 NGN = $0.0012
          priceChange24h: 0.1,
          lastUpdated: DateTime.now(),
        ),
        Token(
          address: '0x...', // Synthetic KES address
          symbol: 'KES',
          name: 'Kenyan Shilling',
          decimals: 18,
          type: TokenType.local,
          category: TokenCategory.syntheticAsset,
          description: 'Synthetic Kenyan Shilling',
          iconUrl: '',
          isActive: true,
          isSupported: true,
          minAmount: 1.0,
          maxAmount: 10000000.0,
          dailyLimit: 1000000.0,
          currentPrice: 0.0067, // 1 KES = $0.0067
          priceChange24h: -0.05,
          lastUpdated: DateTime.now(),
        ),
      ];
    } catch (e) {
      throw Exception('Failed to fetch African currencies: $e');
    }
  }
  
  // Dispose resources
  void dispose() {
    _client.dispose();
  }
}