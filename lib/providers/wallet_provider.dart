import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class WalletProvider extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  
  Web3Client? _web3client;
  EthereumAddress? _walletAddress;
  EthPrivateKey? _privateKey;
  bool _isConnected = false;
  bool _isLoading = false;
  String _networkName = 'Sepolia Testnet';
  EtherAmount? _balance;
  
  WalletProvider() {
    // Auto-initialize when provider is created
    _autoInitialize();
  }
  
  Future<void> _autoInitialize() async {
    try {
      await initializeWeb3();
      if (_privateKey != null && _walletAddress != null) {
        await connectWallet();
      }
    } catch (e) {
      print('WalletProvider: Auto-initialization failed: $e');
    }
  }
  
  // Contract addresses from environment
  String get stableCoinManagerAddress => AppConfig.stableCoinManagerAddress;
  String get crossTokenConverterAddress => AppConfig.crossTokenConverterAddress;
  String get merchantRegistryAddress => AppConfig.merchantRegistryAddress;
  String get paymentProcessorAddress => AppConfig.paymentProcessorAddress;
  String get salaryPaymentAddress => AppConfig.salaryPaymentAddress;
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String get networkName => _networkName;
  EthereumAddress? get walletAddress => _walletAddress;
  EtherAmount? get balance => _balance;
  Web3Client? get web3Client => _web3client;
  
  String get walletAddressString => 
      _walletAddress?.hexEip55 ?? 'Not connected';
      
  String get shortAddress {
    if (_walletAddress == null) return 'Not connected';
    final address = _walletAddress!.hexEip55;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  // Initialize Web3 connection
  Future<void> initializeWeb3({String? rpcUrl}) async {
    try {
      final url = rpcUrl ?? AppConfig.rpcUrl;
      _web3client = Web3Client(url, Client());
      
      print('WalletProvider: Initializing Web3 with RPC: ${url.substring(0, url.length.clamp(0, 50))}...');
      print('WalletProvider: Network: $_networkName (Chain ID: ${AppConfig.chainId})');
      
      // Initialize with private key if available
      await _initializePrivateKey();
      
      // Try to restore previous connection
      await _restoreConnection();
    } catch (e) {
      print('WalletProvider: Failed to initialize Web3: $e');
      debugPrint('Failed to initialize Web3: $e');
    }
  }

  // Initialize private key from environment
  Future<void> _initializePrivateKey() async {
    try {
      final privateKeyHex = AppConfig.privateKey;
      if (privateKeyHex.isNotEmpty && !privateKeyHex.contains('YOUR_PRIVATE_KEY')) {
        _privateKey = EthPrivateKey.fromHex(privateKeyHex);
        _walletAddress = await _privateKey!.extractAddress();
        print('WalletProvider: Initialized with private key, address: ${_walletAddress!.hexEip55}');
      } else {
        print('WalletProvider: No valid private key found in environment');
      }
    } catch (e) {
      print('WalletProvider: Error initializing private key: $e');
    }
  }

  // Connect wallet using private key from environment or Web3WalletService
  Future<bool> connectWallet() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // First check if Web3WalletService has a connected wallet
      if (_walletAddress == null) {
        // Try to initialize from private key
        if (_privateKey == null) {
          await _initializePrivateKey();
        }
      }
      
      if (_walletAddress != null) {
        _isConnected = true;
        print('WalletProvider: Connected wallet with address: ${_walletAddress!.hexEip55}');
        
        await _saveConnection();
        await _updateBalance();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        print('WalletProvider: Failed to connect - no valid wallet');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('WalletProvider: Failed to connect wallet: $e');
      debugPrint('Failed to connect wallet: $e');
      return false;
    }
  }
  
  // Update wallet from Web3WalletService connection
  void updateFromWeb3Service(EthereumAddress address) {
    _walletAddress = address;
    _isConnected = true;
    print('WalletProvider: Updated from Web3Service, address: ${address.hexEip55}');
    _updateBalance();
    notifyListeners();
  }

  // Disconnect wallet
  Future<void> disconnectWallet() async {
    _walletAddress = null;
    _isConnected = false;
    _balance = null;
    
    await _clearConnection();
    notifyListeners();
  }

  // Update balance
  Future<void> _updateBalance() async {
    if (_web3client == null || _walletAddress == null) return;
    
    try {
      _balance = await _web3client!.getBalance(_walletAddress!);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to get balance: $e');
    }
  }

  // Save connection state
  Future<void> _saveConnection() async {
    if (_walletAddress != null) {
      await _storage.write(key: 'wallet_address', value: _walletAddress!.hexEip55);
      await _storage.write(key: 'is_connected', value: 'true');
    }
  }

  // Restore connection state
  Future<void> _restoreConnection() async {
    try {
      final address = await _storage.read(key: 'wallet_address');
      final connected = await _storage.read(key: 'is_connected');
      
      if (address != null && connected == 'true') {
        _walletAddress = EthereumAddress.fromHex(address);
        _isConnected = true;
        await _updateBalance();
      }
    } catch (e) {
      debugPrint('Failed to restore connection: $e');
    }
  }

  // Clear connection state
  Future<void> _clearConnection() async {
    await _storage.delete(key: 'wallet_address');
    await _storage.delete(key: 'is_connected');
  }

  // Get supported stable coins (mock - integrate with your contract)
  Future<List<String>> getSupportedStableCoins() async {
    return ['USDC', 'USDT', 'DAI'];
  }
  
  // Process payment (mock - integrate with your contract)
  Future<String?> processPayment({
    required String merchantAddress,
    required String tokenAddress,
    required double amount,
    required String currency,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(seconds: 3));
      
      _isLoading = false;
      notifyListeners();
      
      return '0xabc123def456...'; // Mock transaction hash
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Payment failed: $e');
      return null;
    }
  }
}