import 'dart:convert';
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';

enum WalletType {
  metamask,
  walletConnect,
  coinbase,
  trust,
  privateKey,
}

class WalletInfo {
  final WalletType type;
  final String name;
  final String description;
  final String iconAsset;
  final bool isAvailable;

  const WalletInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.isAvailable,
  });
}

class Web3WalletService {
  static Web3Client? _web3Client;
  static EthereumAddress? _connectedAddress;
  static WalletType? _connectedWalletType;
  static String? _chainId;
  static Web3App? _wcClient;
  static SessionData? _wcSession;
  static String? _wcUri;
  
  // Initialize Web3 client
  static Future<void> initialize() async {
    try {
      final rpcUrl = AppConfig.rpcUrl;
      _web3Client = Web3Client(rpcUrl, http.Client());
      print('Web3WalletService: Initialized with RPC: ${rpcUrl.substring(0, 50)}...');

      // Initialize WalletConnect v2 client
      if (_wcClient == null) {
        print('Web3WalletService: Initializing WalletConnect with project ID: ${AppConfig.walletConnectProjectId}');
        
        try {
          _wcClient = await Web3App.createInstance(
            relayUrl: 'wss://relay.walletconnect.com',
            projectId: AppConfig.walletConnectProjectId,
            metadata: const PairingMetadata(
              name: 'AfriBain',
              description: 'AfriBain - Crypto Payment Platform',
              url: 'https://afribain.app',
              icons: ['https://walletconnect.com/walletconnect-logo.png'],
            ),
          );
          print('Web3WalletService: WalletConnect initialized successfully');
          print('Web3WalletService: Active pairings: ${_wcClient!.pairings.getAll().length}');
          print('Web3WalletService: Active sessions: ${_wcClient!.sessions.getAll().length}');
        } catch (e) {
          print('Web3WalletService: Failed to initialize WalletConnect: $e');
          rethrow;
        }
      }
    } catch (e) {
      print('Web3WalletService: Failed to initialize: $e');
    }
  }

  // Get available wallets
  static List<WalletInfo> getAvailableWallets() {
    return [
      WalletInfo(
        type: WalletType.metamask,
        name: 'MetaMask',
        description: 'Connect using MetaMask browser extension',
        iconAsset: 'assets/images/metamask_logo.png',
        isAvailable: _isMetaMaskAvailable(),
      ),
      WalletInfo(
        type: WalletType.walletConnect,
        name: 'WalletConnect',
        description: 'Scan QR code with your mobile wallet',
        iconAsset: 'assets/images/walletconnect_logo.png',
        isAvailable: true,
      ),
      WalletInfo(
        type: WalletType.coinbase,
        name: 'Coinbase Wallet',
        description: 'Connect using Coinbase Wallet',
        iconAsset: 'assets/images/coinbase_logo.png',
        isAvailable: true, // Uses WalletConnect protocol
      ),
      WalletInfo(
        type: WalletType.trust,
        name: 'Trust Wallet',
        description: 'Connect using Trust Wallet',
        iconAsset: 'assets/images/trust_logo.png',
        isAvailable: false,
      ),
      WalletInfo(
        type: WalletType.privateKey,
        name: 'Private Key',
        description: 'Import using private key (for testing)',
        iconAsset: 'assets/images/key_logo.png',
        isAvailable: true,
      ),
    ];
  }

  // Check if MetaMask is available
  static bool _isMetaMaskAvailable() {
    if (kIsWeb) {
      try {
        return js.context.hasProperty('ethereum') || 
               js.context.hasProperty('web3');
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  // Connect to MetaMask
  static Future<EthereumAddress?> connectMetaMask() async {
    if (!kIsWeb) {
      throw Exception('MetaMask is only available on web platform');
    }

    try {
      print('Web3WalletService: Attempting MetaMask connection...');
      
      // Check if MetaMask is installed
      if (!_isMetaMaskAvailable()) {
        throw Exception('MetaMask is not installed. Please install MetaMask extension.');
      }

      // Request account access
      final ethereum = js.context['ethereum'];
      if (ethereum == null) {
        throw Exception('Ethereum provider not found');
      }

      // Request accounts
      final accounts = await _requestAccounts();
      
      if (accounts.isEmpty) {
        throw Exception('No accounts found. Please unlock MetaMask.');
      }

      final address = EthereumAddress.fromHex(accounts[0]);
      _connectedAddress = address;
      _connectedWalletType = WalletType.metamask;

      // Get chain ID
      _chainId = await _getChainId();
      print('Web3WalletService: Connected to MetaMask');
      print('Web3WalletService: Address: ${address.hexEip55}');
      print('Web3WalletService: Chain ID: $_chainId');

      // Verify we're on the correct network
      await _verifyNetwork();

      return address;
    } catch (e) {
      print('Web3WalletService: MetaMask connection failed: $e');
      rethrow;
    }
  }

  // Request accounts from MetaMask
  static Future<List<String>> _requestAccounts() async {
    try {
      final result = await js.context.callMethod('eval', [
        '''
        (async function() {
          try {
            const accounts = await window.ethereum.request({ 
              method: 'eth_requestAccounts' 
            });
            return accounts;
          } catch (error) {
            throw error.message || error.toString();
          }
        })()
        '''
      ]);

      if (result is js.JsArray) {
        return List<String>.from(result);
      }
      
      return [];
    } catch (e) {
      print('Web3WalletService: Failed to request accounts: $e');
      throw Exception('Failed to connect to MetaMask: $e');
    }
  }

  // Get current chain ID
  static Future<String> _getChainId() async {
    try {
      final result = await js.context.callMethod('eval', [
        '''
        (async function() {
          return await window.ethereum.request({ method: 'eth_chainId' });
        })()
        '''
      ]);
      return result.toString();
    } catch (e) {
      print('Web3WalletService: Failed to get chain ID: $e');
      return '0x0';
    }
  }

  // Verify network is correct
  static Future<void> _verifyNetwork() async {
    final expectedChainId = '0x${int.parse(AppConfig.chainId).toRadixString(16)}';
    
    if (_chainId != expectedChainId) {
      print('Web3WalletService: Wrong network detected. Expected: $expectedChainId, Got: $_chainId');
      
      // Try to switch network
      try {
        await _switchNetwork(expectedChainId);
      } catch (e) {
        throw Exception(
          'Please switch to ${AppConfig.networkName} in MetaMask.\n'
          'Current network: $_chainId\n'
          'Expected network: $expectedChainId'
        );
      }
    }
  }

  // Switch MetaMask network
  static Future<void> _switchNetwork(String chainId) async {
    try {
      await js.context.callMethod('eval', [
        '''
        (async function() {
          try {
            await window.ethereum.request({
              method: 'wallet_switchEthereumChain',
              params: [{ chainId: '$chainId' }],
            });
          } catch (switchError) {
            // This error code indicates that the chain has not been added to MetaMask
            if (switchError.code === 4902) {
              await window.ethereum.request({
                method: 'wallet_addEthereumChain',
                params: [{
                  chainId: '$chainId',
                  chainName: '${AppConfig.networkName}',
                  rpcUrls: ['${AppConfig.rpcUrl}'],
                  nativeCurrency: {
                    name: 'ETH',
                    symbol: 'ETH',
                    decimals: 18
                  },
                  blockExplorerUrls: ['https://sepolia.etherscan.io']
                }],
              });
            } else {
              throw switchError;
            }
          }
        })()
        '''
      ]);
      
      print('Web3WalletService: Successfully switched network');
    } catch (e) {
      print('Web3WalletService: Failed to switch network: $e');
      rethrow;
    }
  }

  // Connect using private key
  static Future<EthereumAddress> connectPrivateKey(String privateKeyHex) async {
    try {
      // Remove 0x prefix if present
      if (privateKeyHex.startsWith('0x')) {
        privateKeyHex = privateKeyHex.substring(2);
      }

      final privateKey = EthPrivateKey.fromHex(privateKeyHex);
      final address = await privateKey.extractAddress();
      
      _connectedAddress = address;
      _connectedWalletType = WalletType.privateKey;
      
      print('Web3WalletService: Connected with private key');
      print('Web3WalletService: Address: ${address.hexEip55}');
      
      return address;
    } catch (e) {
      print('Web3WalletService: Private key connection failed: $e');
      throw Exception('Invalid private key');
    }
  }

  // Send transaction via connected wallet
  static Future<String> sendTransaction({
    required String to,
    required String value,
    String? data,
  }) async {
    if (_connectedWalletType == WalletType.metamask) {
      return await _sendMetaMaskTransaction(to: to, value: value, data: data);
    } else if (_connectedWalletType == WalletType.walletConnect || 
               _connectedWalletType == WalletType.coinbase) {
      return await _sendWalletConnectTransaction(to: to, value: value, data: data);
    } else {
      throw Exception('Transaction sending not implemented for this wallet type');
    }
  }

  // Send transaction via MetaMask
  static Future<String> _sendMetaMaskTransaction({
    required String to,
    required String value,
    String? data,
  }) async {
    try {
      final from = _connectedAddress?.hexEip55;
      if (from == null) {
        throw Exception('No wallet connected');
      }

      final params = {
        'from': from,
        'to': to,
        'value': value,
        if (data != null) 'data': data,
      };

      final txHash = await js.context.callMethod('eval', [
        '''
        (async function() {
          const params = ${jsonEncode(params)};
          return await window.ethereum.request({
            method: 'eth_sendTransaction',
            params: [params],
          });
        })()
        '''
      ]);

      print('Web3WalletService: Transaction sent: $txHash');
      return txHash.toString();
    } catch (e) {
      print('Web3WalletService: Transaction failed: $e');
      throw Exception('Transaction failed: $e');
    }
  }

  // Sign message via MetaMask
  static Future<String> signMessage(String message) async {
    if (_connectedWalletType != WalletType.metamask) {
      throw Exception('Message signing only available for MetaMask');
    }

    try {
      final from = _connectedAddress?.hexEip55;
      if (from == null) {
        throw Exception('No wallet connected');
      }

      final signature = await js.context.callMethod('eval', [
        '''
        (async function() {
          return await window.ethereum.request({
            method: 'personal_sign',
            params: ['$message', '$from'],
          });
        })()
        '''
      ]);

      return signature.toString();
    } catch (e) {
      print('Web3WalletService: Message signing failed: $e');
      throw Exception('Failed to sign message: $e');
    }
  }

  // Connect to Coinbase Wallet (uses WalletConnect)
  static Future<EthereumAddress?> connectCoinbase() async {
    try {
      if (_wcClient == null) {
        await initialize();
      }

      print('Web3WalletService: Initiating Coinbase Wallet connection...');

      // Create connection with Coinbase-specific params
      final ConnectResponse response = await _wcClient!.connect(
        requiredNamespaces: {
          'eip155': const RequiredNamespace(
            chains: ['eip155:11155111'], // Sepolia chain ID
            methods: [
              'eth_sendTransaction',
              'eth_signTransaction',
              'eth_sign',
              'personal_sign',
              'eth_signTypedData',
            ],
            events: ['chainChanged', 'accountsChanged'],
          ),
        },
      );

      final Uri? uri = response.uri;
      if (uri != null) {
        _wcUri = uri.toString();
        
        // Try to open Coinbase Wallet directly via deep link
        final coinbaseUri = Uri.parse('https://go.cb-w.com/dapp?cb_url=${Uri.encodeComponent(uri.toString())}');
        print('Web3WalletService: Coinbase Wallet URI: $coinbaseUri');
        
        // Launch Coinbase Wallet app/extension
        await launchUrl(coinbaseUri, mode: LaunchMode.externalApplication);
      }

      // Wait for session approval
      _wcSession = await response.session.future;
      
      if (_wcSession == null) {
        throw Exception('Coinbase Wallet session failed');
      }

      // Extract address from session
      final accounts = _wcSession!.namespaces['eip155']?.accounts ?? [];
      if (accounts.isEmpty) {
        throw Exception('No accounts found in Coinbase Wallet session');
      }

      // Parse address from CAIP-10 format: eip155:11155111:0x...
      final addressStr = accounts.first.split(':').last;
      final address = EthereumAddress.fromHex(addressStr);
      
      _connectedAddress = address;
      _connectedWalletType = WalletType.coinbase;
      _chainId = '0xaa36a7'; // Sepolia

      print('Web3WalletService: Connected via Coinbase Wallet');
      print('Web3WalletService: Address: ${address.hexEip55}');

      return address;
    } catch (e) {
      print('Web3WalletService: Coinbase Wallet connection failed: $e');
      rethrow;
    }
  }

  // Connect to WalletConnect
  static Future<EthereumAddress?> connectWalletConnect() async {
    try {
      if (_wcClient == null) {
        await initialize();
      }

      print('Web3WalletService: Initiating WalletConnect connection...');
      print('Web3WalletService: WC Client status: ${_wcClient != null ? 'Ready' : 'Not initialized'}');

      // Create connection
      print('Web3WalletService: Creating WalletConnect pairing...');
      final ConnectResponse response = await _wcClient!.connect(
        requiredNamespaces: {
          'eip155': const RequiredNamespace(
            chains: ['eip155:11155111'], // Sepolia chain ID
            methods: [
              'eth_sendTransaction',
              'eth_signTransaction',
              'eth_sign',
              'personal_sign',
              'eth_signTypedData',
            ],
            events: ['chainChanged', 'accountsChanged'],
          ),
        },
      );

      print('Web3WalletService: Connect response received');
      final Uri? uri = response.uri;
      if (uri != null) {
        _wcUri = uri.toString();
        print('Web3WalletService: WalletConnect URI generated: $_wcUri');
        print('Web3WalletService: URI length: ${_wcUri!.length}');
        
        // Launch the URI to open wallet apps
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          print('Web3WalletService: Launched deep link');
        } catch (e) {
          print('Web3WalletService: Failed to launch deep link: $e');
        }
      } else {
        print('Web3WalletService: ERROR - No URI generated!');
      }

      // Wait for session approval
      print('Web3WalletService: Waiting for session approval...');
      _wcSession = await response.session.future;
      print('Web3WalletService: Session future completed');
      
      if (_wcSession == null) {
        throw Exception('WalletConnect session failed');
      }

      // Extract address from session
      final accounts = _wcSession!.namespaces['eip155']?.accounts ?? [];
      if (accounts.isEmpty) {
        throw Exception('No accounts found in WalletConnect session');
      }

      // Parse address from CAIP-10 format: eip155:11155111:0x...
      final addressStr = accounts.first.split(':').last;
      final address = EthereumAddress.fromHex(addressStr);
      
      _connectedAddress = address;
      _connectedWalletType = WalletType.walletConnect;
      _chainId = '0xaa36a7'; // Sepolia

      print('Web3WalletService: Connected via WalletConnect');
      print('Web3WalletService: Address: ${address.hexEip55}');

      return address;
    } catch (e) {
      print('Web3WalletService: WalletConnect connection failed: $e');
      rethrow;
    }
  }

  // Send transaction via WalletConnect
  static Future<String> _sendWalletConnectTransaction({
    required String to,
    required String value,
    String? data,
  }) async {
    if (_wcSession == null || _wcClient == null) {
      throw Exception('WalletConnect not connected');
    }

    try {
      final from = _connectedAddress?.hexEip55;
      if (from == null) {
        throw Exception('No wallet connected');
      }

      final txHash = await _wcClient!.request(
        topic: _wcSession!.topic,
        chainId: 'eip155:11155111',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            {
              'from': from,
              'to': to,
              'value': value,
              if (data != null) 'data': data,
            },
          ],
        ),
      );

      print('Web3WalletService: WalletConnect transaction sent: $txHash');
      return txHash.toString();
    } catch (e) {
      print('Web3WalletService: WalletConnect transaction failed: $e');
      throw Exception('Transaction failed: $e');
    }
  }

  // Get balance
  static Future<EtherAmount> getBalance(EthereumAddress address) async {
    if (_web3Client == null) {
      await initialize();
    }
    return await _web3Client!.getBalance(address);
  }

  // Disconnect wallet
  static Future<void> disconnect() async {
    try {
      // Disconnect WalletConnect session if active
      if (_wcSession != null && _wcClient != null) {
        await _wcClient!.disconnectSession(
          topic: _wcSession!.topic,
          reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
        );
        _wcSession = null;
        _wcUri = null;
      }
    } catch (e) {
      print('Web3WalletService: Error disconnecting WalletConnect: $e');
    }
    
    _connectedAddress = null;
    _connectedWalletType = null;
    _chainId = null;
    print('Web3WalletService: Wallet disconnected');
  }

  // Getters
  static EthereumAddress? get connectedAddress => _connectedAddress;
  static WalletType? get connectedWalletType => _connectedWalletType;
  static String? get chainId => _chainId;
  static bool get isConnected => _connectedAddress != null;
  static Web3Client? get web3Client => _web3Client;
  static String? get wcUri => _wcUri;
  static SessionData? get wcSession => _wcSession;

  // Listen to account changes (MetaMask only)
  static void setupMetaMaskListeners({
    Function(String)? onAccountChanged,
    Function(String)? onChainChanged,
    Function()? onDisconnect,
  }) {
    if (!kIsWeb || !_isMetaMaskAvailable()) return;

    try {
      // Account changed listener
      js.context.callMethod('eval', [
        '''
        if (window.ethereum) {
          window.ethereum.on('accountsChanged', function(accounts) {
            window.dispatchEvent(new CustomEvent('metamask_accounts_changed', { 
              detail: accounts 
            }));
          });
          
          window.ethereum.on('chainChanged', function(chainId) {
            window.dispatchEvent(new CustomEvent('metamask_chain_changed', { 
              detail: chainId 
            }));
          });
          
          window.ethereum.on('disconnect', function() {
            window.dispatchEvent(new CustomEvent('metamask_disconnected'));
          });
        }
        '''
      ]);
      
      print('Web3WalletService: MetaMask listeners setup complete');
    } catch (e) {
      print('Web3WalletService: Failed to setup listeners: $e');
    }
  }
}