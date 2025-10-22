import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class MerchantScreen extends StatefulWidget {
  const MerchantScreen({super.key});

  @override
  State<MerchantScreen> createState() => _MerchantScreenState();
}

class _MerchantScreenState extends State<MerchantScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock merchant data
  bool _isRegistered = true; // Set to false to show registration form
  
  // Payment settings state
  bool _paymentNotifications = true;
  bool _autoAcceptPayments = true;
  bool _multiCurrencySupport = true;
  double _minimumAmount = 1.0;
  double _maximumAmount = 10000.0;
  
  // Security settings state
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = false;
  bool _transactionLimits = true;
  final Map<String, dynamic> _merchantData = {
    'name': 'Coffee Paradise',
    'category': 'Food & Drink',
    'description': 'Premium coffee shop serving the best brews in town',
    'address': '123 Main Street, Downtown',
    'phone': '+1234567890',
    'email': 'info@coffeeparadise.com',
    'walletAddress': '0x742d35cc6634c0532925a3b8d48c0f9e15c6a1b0',
    'totalEarnings': 15420.50,
    'totalTransactions': 342,
    'isActive': true,
  };
  
  final List<Map<String, dynamic>> _recentPayments = [
    {
      'amount': 12.50,
      'currency': 'USDC',
      'customer': '0x456def...abc',
      'date': DateTime.now().subtract(const Duration(minutes: 30)),
      'description': 'Coffee and pastry',
      'status': 'completed',
    },
    {
      'amount': 8.75,
      'currency': 'USDT',
      'customer': '0x789abc...def',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'description': 'Cappuccino',
      'status': 'completed',
    },
    {
      'amount': 25.00,
      'currency': 'USDC',
      'customer': '0x123def...456',
      'date': DateTime.now().subtract(const Duration(hours: 5)),
      'description': 'Catering order',
      'status': 'completed',
    },
    {
      'amount': 15.25,
      'currency': 'DAI',
      'customer': '0xabc987...321',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'description': 'Lunch combo',
      'status': 'completed',
    },
    {
      'amount': 4.50,
      'currency': 'USDC',
      'customer': '0x654fed...789',
      'date': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      'description': 'Espresso',
      'status': 'completed',
    },
    {
      'amount': 18.75,
      'currency': 'USDT',
      'customer': '0x321cba...654',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'description': 'Meeting catering',
      'status': 'completed',
    },
    {
      'amount': 6.25,
      'currency': 'USDC',
      'customer': '0x789def...abc',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'description': 'Latte and muffin',
      'status': 'completed',
    },
    {
      'amount': 32.50,
      'currency': 'DAI',
      'customer': '0x147abc...852',
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'description': 'Corporate order',
      'status': 'completed',
    },
    {
      'amount': 9.00,
      'currency': 'USDC',
      'customer': '0x963fed...741',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'description': 'Americano and cookie',
      'status': 'completed',
    },
    {
      'amount': 14.75,
      'currency': 'USDT',
      'customer': '0x852def...159',
      'date': DateTime.now().subtract(const Duration(days: 6)),
      'description': 'Breakfast special',
      'status': 'completed',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryGreen,
        elevation: 0,
        bottom: _isRegistered ? TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryGreen,
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(Icons.dashboard, size: 16)),
            Tab(text: 'Payments', icon: Icon(Icons.payment, size: 16)),
            Tab(text: 'Settings', icon: Icon(Icons.settings, size: 16)),
          ],
        ) : null,
        actions: [
          if (_isRegistered)
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _merchantData['walletAddress']));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wallet address copied')),
                );
              },
              icon: const Icon(Icons.copy),
            ),
        ],
      ),
      body: _isRegistered ? TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildPaymentsTab(),
          _buildSettingsTab(),
        ],
      ) : _buildRegistrationForm(),
      floatingActionButton: _isRegistered ? FloatingActionButton.extended(
        onPressed: _generateQRCode,
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.qr_code, color: Colors.white),
        label: const Text('Payment QR', style: TextStyle(color: Colors.white)),
      ) : null,
    );
  }
  
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Merchant Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.primaryGreen.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _merchantData['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _merchantData['category'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _merchantData['isActive'] ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _merchantData['isActive'] ? 'ACTIVE' : 'INACTIVE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Wallet: ${_merchantData['walletAddress'].substring(0, 10)}...${_merchantData['walletAddress'].substring(_merchantData['walletAddress'].length - 8)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Options
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryGreen,
                    side: BorderSide(color: Colors.grey[300]!),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Payment History (Extended)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Payments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, size: 20),
                    onPressed: () {},
                    color: Colors.grey[600],
                  ),
                  IconButton(
                    icon: const Icon(Icons.sort, size: 20),
                    onPressed: () {},
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Payment list
          ..._recentPayments.map((payment) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.arrow_downward,
                      color: Colors.green[600],
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment['description'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatDate(payment['date']),
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
                        '+\$${payment['amount'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        payment['currency'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
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
  }
  
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Merchant Info Section
          const Text(
            'Business Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildInfoTile('Business Name', _merchantData['name'], Icons.store),
          _buildInfoTile('Category', _merchantData['category'], Icons.category),
          _buildInfoTile('Address', _merchantData['address'], Icons.location_on),
          _buildInfoTile('Phone', _merchantData['phone'], Icons.phone),
          _buildInfoTile('Email', _merchantData['email'], Icons.email),
          _buildInfoTile('Wallet Address', '${_merchantData['walletAddress'].substring(0, 10)}...${_merchantData['walletAddress'].substring(_merchantData['walletAddress'].length - 8)}', Icons.account_balance_wallet),
          
          const SizedBox(height: 24),
          
          // Payment Settings
          const Text(
            'Payment Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          ListTile(
            leading: const Icon(Icons.notifications, color: AppTheme.primaryGreen),
            title: const Text('Payment Notifications'),
            subtitle: const Text('Get notified when you receive payments'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppTheme.primaryGreen,
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.auto_awesome, color: AppTheme.primaryGreen),
            title: const Text('Auto-accept Payments'),
            subtitle: const Text('Automatically accept incoming payments'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppTheme.primaryGreen,
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.currency_exchange, color: AppTheme.primaryGreen),
            title: const Text('Multi-Currency Support'),
            subtitle: const Text('Accept USDC, USDT, and DAI'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppTheme.primaryGreen,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Security Settings
          const Text(
            'Security & Privacy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          ListTile(
            leading: const Icon(Icons.security, color: AppTheme.primaryGreen),
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Secure your account with 2FA'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          
          ListTile(
            leading: const Icon(Icons.lock, color: AppTheme.primaryGreen),
            title: const Text('Change PIN'),
            subtitle: const Text('Update your security PIN'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          
          ListTile(
            leading: const Icon(Icons.backup, color: AppTheme.primaryGreen),
            title: const Text('Backup Wallet'),
            subtitle: const Text('Secure your wallet recovery phrase'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showEditInfoDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Update Business Information'),
            ),
          ),
          
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _showDeactivateDialog();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Deactivate Merchant Account'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRegistrationForm() {
    return const Center(
      child: Text('Registration form coming soon...'),
    );
  }
  
  void _generateQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment QR Code'),
        content: const Text('QR code generation coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showEditInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Business Info'),
        content: const Text('Update form coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}