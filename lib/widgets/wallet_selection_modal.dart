import 'package:flutter/material.dart';
import '../services/web3_wallet_service.dart';
import '../utils/theme.dart';
import 'walletconnect_qr_modal.dart';

class WalletSelectionModal extends StatefulWidget {
  const WalletSelectionModal({super.key});

  @override
  State<WalletSelectionModal> createState() => _WalletSelectionModalState();
}

class _WalletSelectionModalState extends State<WalletSelectionModal> {
  bool _isConnecting = false;
  String? _selectedWallet;

  final List<WalletOption> _wallets = [
    WalletOption(
      name: 'WalletConnect',
      description: 'Scan QR with any wallet',
      icon: Icons.qr_code_scanner,
      color: Color(0xFF3B99FC),
      isWalletConnect: true,
      showQRDirectly: true,
    ),
    WalletOption(
      name: 'MetaMask',
      description: 'Connect with MetaMask',
      icon: Icons.extension,
      color: Colors.orange,
      type: WalletType.metamask,
    ),
    WalletOption(
      name: 'Trust Wallet',
      description: 'Multi-chain wallet',
      icon: Icons.shield,
      color: Colors.blue,
      isWalletConnect: true,
    ),
    WalletOption(
      name: 'Coinbase Wallet',
      description: 'Secure self-custody wallet',
      icon: Icons.account_balance_wallet,
      color: Color(0xFF0052FF),
      type: WalletType.coinbase,
    ),
    WalletOption(
      name: 'Rainbow',
      description: 'Fun, simple, and secure',
      icon: Icons.water_drop,
      color: Colors.purple,
      isWalletConnect: true,
    ),
    WalletOption(
      name: 'Ledger',
      description: 'Hardware wallet',
      icon: Icons.usb,
      color: Colors.black,
      isWalletConnect: true,
    ),
    WalletOption(
      name: 'Argent',
      description: 'Smart wallet for DeFi',
      icon: Icons.account_balance,
      color: Colors.deepOrange,
      isWalletConnect: true,
    ),
    WalletOption(
      name: 'SafePal',
      description: 'Crypto wallet & DeFi',
      icon: Icons.security,
      color: Color(0xFF3375BB),
      isWalletConnect: true,
    ),
    WalletOption(
      name: 'Zerion',
      description: 'Invest in DeFi',
      icon: Icons.trending_up,
      color: Color(0xFF2962EF),
      isWalletConnect: true,
    ),
    WalletOption(
      name: 'imToken',
      description: 'Secure digital wallet',
      icon: Icons.lock,
      color: Color(0xFF11C4D1),
      isWalletConnect: true,
    ),
    WalletOption(
      name: 'TokenPocket',
      description: 'Multi-chain wallet',
      icon: Icons.folder_special,
      color: Color(0xFF2980FE),
      isWalletConnect: true,
    ),
    WalletOption(
      name: '1inch Wallet',
      description: 'DeFi / DEX wallet',
      icon: Icons.swap_horiz,
      color: Color(0xFF94A6C3),
      isWalletConnect: true,
    ),
    WalletOption(
      name: 'Crypto.com',
      description: 'DeFi wallet',
      icon: Icons.currency_bitcoin,
      color: Color(0xFF002D74),
      isWalletConnect: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: AppTheme.primaryGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect Wallet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Choose your preferred wallet',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
            ),

            // Wallet Grid
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _wallets.length,
                      itemBuilder: (context, index) {
                        final wallet = _wallets[index];
                        final isSelected = _selectedWallet == wallet.name;
                        
                        return _buildWalletCard(wallet, isSelected);
                      },
                    ),
                  ),
                  
                  // Loading overlay
                  if (_isConnecting)
                    Container(
                      color: Colors.white.withOpacity(0.9),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Connecting to $_selectedWallet...',
                              style: TextStyle(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check your wallet app',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'New to Ethereum wallets?',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Open learn more
                    },
                    child: const Text('Learn More'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(WalletOption wallet, bool isSelected) {
    return InkWell(
      onTap: () => _connectWallet(wallet),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? wallet.color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? wallet.color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: wallet.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                wallet.icon,
                color: wallet.color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              wallet.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              wallet.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connectWallet(WalletOption wallet) async {
    setState(() {
      _isConnecting = true;
      _selectedWallet = wallet.name;
    });

    try {
      if (wallet.type != null) {
        // Direct wallet connection (MetaMask, Coinbase)
        if (wallet.type == WalletType.metamask) {
          final address = await Web3WalletService.connectMetaMask();
          if (address != null && mounted) {
            Navigator.of(context).pop({
              'success': true,
              'address': address.hexEip55,
              'walletType': WalletType.metamask,
            });
          }
        } else if (wallet.type == WalletType.coinbase) {
          final address = await Web3WalletService.connectCoinbase();
          if (address != null && mounted) {
            Navigator.of(context).pop({
              'success': true,
              'address': address.hexEip55,
              'walletType': WalletType.coinbase,
            });
          }
        }
      } else if (wallet.isWalletConnect) {
        // WalletConnect for mobile wallets
        final connectionFuture = Web3WalletService.connectWalletConnect();
        
        // Wait for URI
        String? uri;
        for (int i = 0; i < 10; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          uri = Web3WalletService.wcUri;
          if (uri != null) break;
        }
        
        if (uri != null && mounted) {
          // Always show QR modal for WalletConnect wallets
          showWalletConnectQRModal(context, uri);
        }
        
        // Wait for connection
        final address = await connectionFuture;
        
        // Close QR modal
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
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _selectedWallet = null;
        });
      }
    }
  }
}

class WalletOption {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final WalletType? type;
  final bool isWalletConnect;
  final bool showQRDirectly;

  WalletOption({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.type,
    this.isWalletConnect = false,
    this.showQRDirectly = false,
  });
}

// Helper function to show wallet selection modal
Future<Map<String, dynamic>?> showWalletSelectionModal(BuildContext context) async {
  return await showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => const WalletSelectionModal(),
  );
}
