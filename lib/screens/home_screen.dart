import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/token_provider.dart';
import '../models/transaction.dart';
import '../widgets/blockchain_info_popup.dart';
import '../widgets/token_portfolio_widget.dart';
import '../widgets/wallet_connection_dialog.dart';
import '../widgets/wallet_selection_modal.dart';
import '../services/web3_wallet_service.dart';
import '../data/education_content.dart';
import '../screens/profile_screen.dart';
import '../utils/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      
      Provider.of<TransactionProvider>(context, listen: false).loadTransactionHistory();
      
      // Initialize TokenProvider with wallet address if connected
      if (walletProvider.isConnected && walletProvider.walletAddress != null) {
        tokenProvider.initialize(walletProvider.walletAddress!.hexEip55);
      } else {
        tokenProvider.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'AfriBain',
          style: TextStyle(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<WalletProvider>(
            builder: (context, walletProvider, child) {
              return IconButton(
                onPressed: () {
                  if (walletProvider.isConnected) {
                    walletProvider.disconnectWallet();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Wallet disconnected')),
                    );
                  } else {
                    walletProvider.connectWallet().then((success) {
                      if (success) {
                        // Reinitialize TokenProvider with wallet address
                        final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
                        if (walletProvider.walletAddress != null) {
                          tokenProvider.initialize(walletProvider.walletAddress!.hexEip55);
                        }
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Wallet connected successfully')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to connect wallet')),
                        );
                      }
                    });
                  }
                },
                icon: Icon(
                  walletProvider.isConnected ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
                  color: walletProvider.isConnected ? AppTheme.primaryGreen : Colors.grey,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer3<WalletProvider, TransactionProvider, TokenProvider>(
        builder: (context, walletProvider, transactionProvider, tokenProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.primaryGreen.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wallet Balance',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  walletProvider.isConnected 
                                      ? '\$${tokenProvider.totalPortfolioValue.toStringAsFixed(2)}'
                                      : 'Not connected',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              walletProvider.isConnected ? Icons.check_circle : Icons.circle_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Connected: Show address
                      if (walletProvider.isConnected) ...[
                        Text(
                          walletProvider.shortAddress,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await walletProvider.disconnectWallet();
                            Web3WalletService.disconnect();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Wallet disconnected'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Disconnect'),
                        ),
                      ] else ...[
                        // Not Connected: Show connect button
                        Text(
                          'Connect your wallet to access blockchain features',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showWalletConnection(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.account_balance_wallet),
                            label: const Text(
                              'Connect Wallet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        'Deposit',
                        Icons.add_circle,
                        () => Navigator.pushNamed(context, '/deposit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        'Convert',
                        Icons.swap_horiz,
                        () => Navigator.pushNamed(context, '/token_converter'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        'Pay',
                        Icons.payment,
                        () => Navigator.pushNamed(context, '/payment'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Token Portfolio Section
                if (walletProvider.isConnected)
                  TokenPortfolioWidget(
                    onViewAll: () => Navigator.pushNamed(context, '/token_portfolio'),
                  ),
                
                if (walletProvider.isConnected)
                  const SizedBox(height: 24),
              
              // Blockchain Education Section
              const Text(
                'Learn About Blockchain',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              ...EducationCategory.categories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                
                if (index % 2 == 0) {
                  // Start of a new row
                  final nextCategory = index + 1 < EducationCategory.categories.length 
                      ? EducationCategory.categories[index + 1] 
                      : null;
                  
                  return Column(
                    children: [
                      if (index > 0) const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEducationCard(
                              category.title,
                              EducationContent.getDescription(category.id),
                              _getIconFromString(category.icon),
                              _getColorFromString(category.color),
                              category.id,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: nextCategory != null
                                ? _buildEducationCard(
                                    nextCategory.title,
                                    EducationContent.getDescription(nextCategory.id),
                                    _getIconFromString(nextCategory.icon),
                                    _getColorFromString(nextCategory.color),
                                    nextCategory.id,
                                  )
                                : const SizedBox(), // Empty space if odd number of items
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  // This is handled by the previous iteration
                  return const SizedBox.shrink();
                }
              }).where((widget) => widget is! SizedBox || (widget as SizedBox).height != null),
              
              const SizedBox(height: 24),
              
              // Transactions Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showFeatureComingSoon(context, 'Transaction History'),
                      child: Text(
                        'See All',
                        style: TextStyle(color: AppTheme.primaryGreen),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Transaction List
                if (transactionProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (transactionProvider.transactions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your transaction history will appear here',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...transactionProvider.transactions.take(3).map((transaction) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: transaction.type == TransactionType.payment 
                                  ? Colors.red[100] 
                                  : Colors.green[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              transaction.type == TransactionType.payment 
                                  ? Icons.arrow_upward 
                                  : Icons.arrow_downward,
                              color: transaction.type == TransactionType.payment 
                                  ? Colors.red[600] 
                                  : Colors.green[600],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.description,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${transaction.timestamp.day}/${transaction.timestamp.month}/${transaction.timestamp.year}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${transaction.type == TransactionType.payment ? '-' : '+'}${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: transaction.type == TransactionType.payment 
                                      ? Colors.red[600] 
                                      : Colors.green[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: transaction.status == TransactionStatus.completed 
                                      ? Colors.green[100] 
                                      : Colors.orange[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  transaction.status.toString().split('.').last.toUpperCase(),
                                  style: TextStyle(
                                    color: transaction.status == TransactionStatus.completed 
                                        ? Colors.green[700] 
                                        : Colors.orange[700],
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _navigateToScreen(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Pay',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Merchant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Salary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/payment');
        break;
      case 2:
        Navigator.pushNamed(context, '/merchant');
        break;
      case 3:
        Navigator.pushNamed(context, '/salary');
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }
  
  Widget _buildEducationCard(String title, String subtitle, IconData icon, Color color, String type) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => BlockchainInfoPopup(
            title: title,
            type: type,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
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
  
  Future<void> _showWalletConnection(BuildContext context) async {
    print('HomeScreen: _showWalletConnection called');
    
    // Initialize Web3 service first
    print('HomeScreen: Initializing Web3 service...');
    await Web3WalletService.initialize();
    print('HomeScreen: Web3 service initialized');
    
    // Show wallet selection modal
    print('HomeScreen: Showing wallet selection modal...');
    final result = await showWalletSelectionModal(context);
    print('HomeScreen: Modal result: $result');
    
    if (result != null && result['success'] == true && mounted) {
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      
      // Get the connected address from Web3WalletService
      final address = Web3WalletService.connectedAddress;
      
      if (address != null) {
        print('HomeScreen: Wallet connected, syncing with provider');
        
        // Update wallet provider with the connected address
        walletProvider.updateFromWeb3Service(address);
        
        // Initialize Web3 client in wallet provider
        await walletProvider.initializeWeb3();
        
        // Initialize token provider with connected wallet
        await tokenProvider.initialize(address.hexEip55);
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Wallet Connected Successfully!',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address.hexEip55,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Network: ${result['walletType'].toString().split('.').last}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }
  
  void _showFeatureComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature Coming Soon!'),
        content: Text('The $feature feature is currently under development and will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'monetization_on':
        return Icons.monetization_on;
      case 'hub':
        return Icons.hub;
      case 'security':
        return Icons.security;
      case 'swap_horiz':
        return Icons.swap_horiz;
      default:
        return Icons.help;
    }
  }
  
  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
