import 'package:flutter/material.dart';
import '../data/education_content.dart';
import '../utils/theme.dart';

class BlockchainInfoPopup extends StatefulWidget {
  final String title;
  final String type;

  const BlockchainInfoPopup({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  State<BlockchainInfoPopup> createState() => _BlockchainInfoPopupState();
}

class _BlockchainInfoPopupState extends State<BlockchainInfoPopup> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryGreen.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForType(widget.type),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Learn about blockchain technology',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Tab Bar
            Container(
              color: Colors.grey[100],
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryGreen,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppTheme.primaryGreen,
                tabs: const [
                  Tab(text: 'Basics', icon: Icon(Icons.school, size: 16)),
                  Tab(text: 'Currency', icon: Icon(Icons.monetization_on, size: 16)),
                  Tab(text: 'Security', icon: Icon(Icons.security, size: 16)),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBasicsTab(),
                  _buildCurrencyTab(),
                  _buildSecurityTab(),
                ],
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showNetworkSelection(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                        side: BorderSide(color: AppTheme.primaryGreen),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Choose Network'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Got it!'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicsTab() {
    final content = EducationContent.getFullContent(widget.type);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EducationContent.getTitle(widget.type),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            EducationContent.getDescription(widget.type),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Stablecoins',
            'Cryptocurrencies pegged to stable assets like USD. USDC, USDT, and DAI maintain stable value, perfect for daily transactions.',
            Icons.trending_flat,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Local Currency Support',
            'Convert between stablecoins and local currencies (NGN, KES, GHS, ZAR) with real-time exchange rates.',
            Icons.swap_horiz,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Volatile Cryptocurrencies',
            'Traditional cryptocurrencies like ETH and BTC that can fluctuate in value. Great for investment but less ideal for daily payments.',
            Icons.show_chart,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildConversionExample(),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Private Keys',
            'Your private key is like your digital signature. Keep it secret and secure - it controls access to your funds.',
            Icons.key,
            Colors.red,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Non-Custodial Wallet',
            'You control your funds directly. AfriBain cannot access, freeze, or take your money. You are your own bank.',
            Icons.account_balance_wallet,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Transaction Fees',
            'Small fees (usually \$0.01-\$0.10) pay network validators to process your transactions securely and quickly.',
            Icons.receipt,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Recovery Phrase',
            'A 12-24 word phrase that can restore your wallet. Write it down and store it safely offline.',
            Icons.backup,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon, Color color) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.secondaryGold.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondaryGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: AppTheme.secondaryGold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Live Conversion Example',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCurrencyBox('100 USDC', 'Stablecoin'),
              ),
              const Icon(Icons.arrow_forward, color: Colors.grey),
              Expanded(
                child: _buildCurrencyBox('₦77,500', 'Nigerian Naira'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCurrencyBox('100 USDC', 'Stablecoin'),
              ),
              const Icon(Icons.arrow_forward, color: Colors.grey),
              Expanded(
                child: _buildCurrencyBox('₵1,250', 'Ghanaian Cedi'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Exchange rates update every 30 seconds based on market data.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyBox(String amount, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showNetworkSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Blockchain Network'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNetworkTile('Ethereum Mainnet', 'Most secure, higher fees', Icons.security, true),
            _buildNetworkTile('Polygon', 'Fast & cheap, good for daily use', Icons.speed, false),
            _buildNetworkTile('Base', 'Coinbase L2, low fees', Icons.layers, false),
            _buildNetworkTile('Arbitrum', 'Ethereum L2, moderate fees', Icons.account_tree, false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Network selection saved!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkTile(String name, String description, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppTheme.primaryGreen : Colors.grey),
        title: Text(name, style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.primaryGreen : Colors.black87,
        )),
        subtitle: Text(description),
        trailing: isSelected ? Icon(Icons.check_circle, color: AppTheme.primaryGreen) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: isSelected,
        selectedTileColor: AppTheme.primaryGreen.withOpacity(0.1),
        onTap: () {},
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'stablecoin':
        return Icons.monetization_on;
      case 'network':
        return Icons.hub;
      case 'security':
        return Icons.security;
      case 'conversion':
        return Icons.swap_horiz;
      default:
        return Icons.info;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}