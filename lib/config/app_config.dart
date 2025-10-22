import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Network Configuration
  static String get networkName => dotenv.env['NETWORK_NAME'] ?? 'Sepolia Testnet';
  static String get chainId => dotenv.env['CHAIN_ID'] ?? '11155111';
  static String get rpcUrl => dotenv.env['SEPOLIA_RPC_URL'] ?? 'https://eth-sepolia.g.alchemy.com/v2/YOUR_ALCHEMY_API_KEY';
  // Support both PRIVATE_KEY and SEPOLIA_PRIVATE_KEY for backwards compatibility
  static String get privateKey => dotenv.env['PRIVATE_KEY'] ?? dotenv.env['SEPOLIA_PRIVATE_KEY'] ?? '';
  
  // WalletConnect Configuration
  static String get walletConnectProjectId => dotenv.env['WALLETCONNECT_PROJECT_ID'] ?? 'YOUR_PROJECT_ID';
  
  // Contract Addresses (loaded from environment variables)
  static String get afriBainCoreAddress => dotenv.env['AFRIBAIN_CORE_ADDRESS'] ?? '0x...';
  static String get tokenTypeManagerAddress => dotenv.env['TOKEN_TYPE_MANAGER_ADDRESS'] ?? '0x...';
  static String get crossTokenConverterAddress => dotenv.env['CROSS_TOKEN_CONVERTER_ADDRESS'] ?? '0x...';
  static String get stableCoinManagerAddress => dotenv.env['STABLECOIN_MANAGER_ADDRESS'] ?? '0x...';
  static String get currencyConverterAddress => dotenv.env['CURRENCY_CONVERTER_ADDRESS'] ?? '0x...';
  static String get merchantRegistryAddress => dotenv.env['MERCHANT_REGISTRY_ADDRESS'] ?? '0x...';
  static String get paymentProcessorAddress => dotenv.env['PAYMENT_PROCESSOR_ADDRESS'] ?? '0x...';
  static String get salaryPaymentAddress => dotenv.env['SALARY_PAYMENT_ADDRESS'] ?? '0x...';
  
  // Token Addresses (loaded from environment variables)
  static String get usdcAddress => dotenv.env['USDC_ADDRESS'] ?? '0x799A5f2A46FB1Cd2717C60d53FBbB6282CCf9A09';
  static String get usdtAddress => dotenv.env['USDT_ADDRESS'] ?? '0x937D07e3A47916B5B44F1749304ce1779E2e5458';
  static String get wethAddress => dotenv.env['WETH_ADDRESS'] ?? '0x...';
  static String get wbtcAddress => dotenv.env['WBTC_ADDRESS'] ?? '0x...';
  static String get bnbAddress => dotenv.env['BNB_ADDRESS'] ?? '0x...';
  
  // App Configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  // Development Mode Settings
  static bool get isDevelopment => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static bool get useMockData {
    // Only use mock data if explicitly set to true in .env
    return dotenv.env['USE_MOCK_DATA']?.toLowerCase() == 'true';
  }
  static bool get enableLogging => dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true' || true; // Always enable for debugging
  
  // Blockchain Settings
  static const int blockConfirmations = 2;
  static const Duration transactionTimeout = Duration(minutes: 5);
  
  // Token Configuration
  static const double defaultSlippageTolerance = 3.0; // 3%
  static const Duration quoteValidityDuration = Duration(minutes: 2);
  
  // UI Configuration
  static const int portfolioRefreshIntervalSeconds = 30;
  static const int priceUpdateIntervalSeconds = 15;
}