import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../services/web3_wallet_service.dart';
import '../utils/theme.dart';
import 'walletconnect_qr_modal.dart';

class WalletConnectionDialog extends StatefulWidget {
  const WalletConnectionDialog({super.key});

  @override
  State<WalletConnectionDialog> createState() => _WalletConnectionDialogState();
}

class _WalletConnectionDialogState extends State<WalletConnectionDialog> {
  bool _isConnecting = false;
  String? _errorMessage;
  WalletType? _selectedWalletType;
  final TextEditingController _privateKeyController = TextEditingController();

  @override
  void dispose() {
    _privateKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: AppTheme.primaryGreen,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connect Wallet',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose your preferred wallet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Wallet list
            if (_selectedWalletType == null) ...[
              Flexible(
                child: Stack(
                  children: [
                    ListView(
                      shrinkWrap: true,
                      children: Web3WalletService.getAvailableWallets()
                          .map((wallet) => _buildWalletTile(wallet))
                          .toList(),
                    ),
                    if (_isConnecting)
                      Container(
                        color: Colors.white.withOpacity(0.8),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Connecting...',
                                style: TextStyle(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Make sure you have MetaMask installed and are on Sepolia Testnet',
                        style: TextStyle(color: Colors.blue[900], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Private key input
            if (_selectedWalletType == WalletType.privateKey) ...[
              Text(
                'Enter Private Key',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: _privateKeyController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '0x...',
                  prefixIcon: const Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 1,
              ),
              
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Never share your private key with anyone. This is for testing only.',
                        style: TextStyle(color: Colors.orange[900], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedWalletType = null;
                          _errorMessage = null;
                        });
                      },
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isConnecting ? null : _connectPrivateKey,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isConnecting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Connect'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWalletTile(WalletInfo wallet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: wallet.isAvailable ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: wallet.isAvailable ? Colors.grey[300]! : Colors.grey[200]!,
        ),
      ),
      child: InkWell(
        onTap: wallet.isAvailable ? () => _onWalletSelected(wallet) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Wallet icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: wallet.isAvailable 
                      ? AppTheme.primaryGreen.withOpacity(0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _getWalletIcon(wallet.type, wallet.isAvailable),
              ),
              
              const SizedBox(width: 16),
              
              // Wallet info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: wallet.isAvailable ? Colors.black87 : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wallet.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: wallet.isAvailable ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status indicator
              if (!wallet.isAvailable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getWalletIcon(WalletType type, bool isAvailable) {
    IconData icon;
    switch (type) {
      case WalletType.metamask:
        icon = Icons.extension;
        break;
      case WalletType.walletConnect:
        icon = Icons.qr_code_scanner;
        break;
      case WalletType.coinbase:
        icon = Icons.account_balance_wallet;
        break;
      case WalletType.trust:
        icon = Icons.shield;
        break;
      case WalletType.privateKey:
        icon = Icons.vpn_key;
        break;
    }
    
    return Icon(
      icon,
      color: isAvailable ? AppTheme.primaryGreen : Colors.grey[400],
      size: 24,
    );
  }

  void _onWalletSelected(WalletInfo wallet) {
    if (wallet.type == WalletType.privateKey) {
      setState(() {
        _selectedWalletType = wallet.type;
        _errorMessage = null;
      });
    } else if (wallet.type == WalletType.metamask) {
      _connectMetaMask();
    } else if (wallet.type == WalletType.walletConnect) {
      // Show loading immediately for WalletConnect
      setState(() {
        _isConnecting = true;
        _errorMessage = null;
      });
      _connectWalletConnect();
    } else if (wallet.type == WalletType.coinbase) {
      // Show loading immediately for Coinbase
      setState(() {
        _isConnecting = true;
        _errorMessage = null;
      });
      _connectCoinbase();
    } else {
      setState(() {
        _errorMessage = 'This wallet connection method is coming soon!';
      });
    }
  }

  Future<void> _connectMetaMask() async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      print('WalletConnectionDialog: Connecting to MetaMask...');
      final address = await Web3WalletService.connectMetaMask();
      
      if (address != null && mounted) {
        print('WalletConnectionDialog: MetaMask connected: ${address.hexEip55}');
        Navigator.of(context).pop({
          'success': true,
          'address': address.hexEip55,
          'walletType': WalletType.metamask,
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to connect to MetaMask. Please try again.';
          _isConnecting = false;
        });
      }
    } catch (e) {
      print('WalletConnectionDialog: MetaMask error: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isConnecting = false;
      });
    }
  }


  Future<void> _connectCoinbase() async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      print('WalletConnectionDialog: Starting Coinbase Wallet connection...');
      
      // Start connection process
      final connectionFuture = Web3WalletService.connectCoinbase();
      
      // Wait for URI to be generated
      String? uri;
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        uri = Web3WalletService.wcUri;
        if (uri != null) {
          print('WalletConnectionDialog: Coinbase URI generated after ${(i + 1) * 100}ms');
          break;
        }
      }
      
      // Show QR modal on desktop/web as fallback
      if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux) {
        if (uri != null && mounted) {
          print('WalletConnectionDialog: Showing Coinbase QR modal');
          showWalletConnectQRModal(context, uri);
        }
      }
      
      // Wait for connection to complete
      print('WalletConnectionDialog: Waiting for Coinbase Wallet approval...');
      final address = await connectionFuture;
      print('WalletConnectionDialog: Coinbase connected: ${address?.hexEip55}');
      
      // Close QR modal if showing
      if (mounted) {
        Navigator.of(context).pop(); // Close QR modal
      }
      
      if (address != null && mounted) {
        Navigator.of(context).pop({
          'success': true,
          'address': address.hexEip55,
          'walletType': WalletType.coinbase,
        });
      }
    } catch (e) {
      // Close QR modal if showing
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isConnecting = false;
      });
    }
  }

  Future<void> _connectWalletConnect() async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      print('WalletConnectionDialog: Starting WalletConnect connection...');
      
      // Start connection process (this will generate URI)
      final connectionFuture = Web3WalletService.connectWalletConnect();
      
      // Wait for URI to be generated (check multiple times)
      String? uri;
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        uri = Web3WalletService.wcUri;
        if (uri != null) {
          print('WalletConnectionDialog: URI generated after ${(i + 1) * 100}ms');
          break;
        }
      }
      
      // Show QR modal on desktop/web, deep link on mobile
      if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux) {
        if (uri != null && mounted) {
          // Show QR code modal
          print('WalletConnectionDialog: Showing QR modal');
          showWalletConnectQRModal(context, uri);
        } else {
          throw Exception('Failed to generate WalletConnect URI');
        }
      }
      
      // Wait for connection to complete
      print('WalletConnectionDialog: Waiting for user to scan QR...');
      final address = await connectionFuture;
      print('WalletConnectionDialog: Connection complete: ${address?.hexEip55}');
      
      // Close QR modal if showing
      if (mounted) {
        Navigator.of(context).pop(); // Close QR modal
      }
      
      if (address != null && mounted) {
        Navigator.of(context).pop({
          'success': true,
          'address': address.hexEip55,
          'walletType': WalletType.walletConnect,
        });
      }
    } catch (e) {
      // Close QR modal if showing
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isConnecting = false;
      });
    }
  }

  Future<void> _connectPrivateKey() async {
    final privateKey = _privateKeyController.text.trim();
    
    if (privateKey.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a private key';
      });
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      final address = await Web3WalletService.connectPrivateKey(privateKey);
      
      if (mounted) {
        Navigator.of(context).pop({
          'success': true,
          'address': address.hexEip55,
          'walletType': WalletType.privateKey,
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isConnecting = false;
      });
    }
  }
}

// Helper function to show wallet connection dialog
Future<Map<String, dynamic>?> showWalletConnectionDialog(BuildContext context) async {
  print('showWalletConnectionDialog: Opening dialog...');
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) {
      print('showWalletConnectionDialog: Building dialog widget');
      return const WalletConnectionDialog();
    },
  );
  print('showWalletConnectionDialog: Dialog closed with result: $result');
  return result;
}
