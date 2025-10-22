import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../utils/theme.dart';
import 'employees_screen.dart';
import 'history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _preferredCurrency = 'USDC';
  String _preferredLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.primaryGreen.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Consumer<WalletProvider>(
                builder: (context, walletProvider, child) {
                  return Column(
                    children: [
                      // Profile Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // User Info
                      Text(
                        'AfriBain User', // In production, get from user profile
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        walletProvider.isConnected 
                            ? walletProvider.shortAddress
                            : 'No wallet connected',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Connection Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: walletProvider.isConnected 
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: walletProvider.isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              walletProvider.isConnected 
                                  ? Icons.check_circle
                                  : Icons.error,
                              size: 16,
                              color: walletProvider.isConnected ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              walletProvider.isConnected ? 'Connected' : 'Disconnected',
                              style: TextStyle(
                                color: walletProvider.isConnected ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          'Employees',
                          'Manage staff',
                          Icons.people,
                          Colors.blue,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EmployeesScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          'History',
                          'View transactions',
                          Icons.history,
                          Colors.orange,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HistoryScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          'Portfolio',
                          'Token balances',
                          Icons.account_balance_wallet,
                          AppTheme.primaryGreen,
                          () => Navigator.pushNamed(context, '/token_portfolio'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          'Convert',
                          'Exchange tokens',
                          Icons.swap_horiz,
                          Colors.purple,
                          () => Navigator.pushNamed(context, '/token_converter'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Account Settings
                  _buildSettingsSection('Account', [
                    _buildSettingsItem(
                      'Personal Information',
                      'Update your profile details',
                      Icons.person_outline,
                      () => _showComingSoon('Personal Information'),
                    ),
                    _buildSettingsItem(
                      'Security & Privacy',
                      'Manage your security settings',
                      Icons.security,
                      () => _showSecuritySettings(),
                    ),
                    _buildSettingsItem(
                      'Wallet Settings',
                      'Manage connected wallets',
                      Icons.account_balance_wallet,
                      () => _showWalletSettings(),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // Preferences
                  _buildSettingsSection('Preferences', [
                    _buildSettingsItem(
                      'Notifications',
                      _notificationsEnabled ? 'Enabled' : 'Disabled',
                      Icons.notifications_outlined,
                      () => _toggleNotifications(),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) => _toggleNotifications(),
                        activeColor: AppTheme.primaryGreen,
                      ),
                    ),
                    _buildSettingsItem(
                      'Preferred Currency',
                      _preferredCurrency,
                      Icons.monetization_on,
                      () => _showCurrencySelector(),
                    ),
                    _buildSettingsItem(
                      'Language',
                      _preferredLanguage,
                      Icons.language,
                      () => _showLanguageSelector(),
                    ),
                  ]),
                  
                  const SizedBox(height: 20),
                  
                  // App Info
                  _buildSettingsSection('About', [
                    _buildSettingsItem(
                      'Help & Support',
                      'Get help or contact support',
                      Icons.help_outline,
                      () => _showComingSoon('Help & Support'),
                    ),
                    _buildSettingsItem(
                      'Terms of Service',
                      'Read our terms and conditions',
                      Icons.description,
                      () => _showComingSoon('Terms of Service'),
                    ),
                    _buildSettingsItem(
                      'Privacy Policy',
                      'Learn about data usage',
                      Icons.privacy_tip,
                      () => _showComingSoon('Privacy Policy'),
                    ),
                    _buildSettingsItem(
                      'App Version',
                      'v1.0.0',
                      Icons.info_outline,
                      null,
                    ),
                  ]),
                  
                  const SizedBox(height: 30),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Disconnect Wallet & Logout'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, String subtitle, IconData icon, VoidCallback? onTap, {Widget? trailing}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  void _editProfile() {
    _showComingSoon('Edit Profile');
  }

  void _toggleNotifications() {
    setState(() {
      _notificationsEnabled = !_notificationsEnabled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _notificationsEnabled 
              ? 'Notifications enabled' 
              : 'Notifications disabled'
        ),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _showCurrencySelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferred Currency',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...(['USDC', 'USDT', 'ETH', 'BTC'].map((currency) => ListTile(
              title: Text(currency),
              leading: Radio<String>(
                value: currency,
                groupValue: _preferredCurrency,
                onChanged: (value) {
                  setState(() {
                    _preferredCurrency = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            )).toList()),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...(['English', 'French', 'Swahili', 'Hausa', 'Amharic'].map((language) => ListTile(
              title: Text(language),
              leading: Radio<String>(
                value: language,
                groupValue: _preferredLanguage,
                onChanged: (value) {
                  setState(() {
                    _preferredLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            )).toList()),
          ],
        ),
      ),
    );
  }

  void _showSecuritySettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Security Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('Biometric Authentication'),
                subtitle: const Text('Use fingerprint or face unlock'),
                trailing: Switch(
                  value: _biometricEnabled,
                  onChanged: (value) {
                    setState(() {
                      _biometricEnabled = value;
                    });
                  },
                  activeColor: AppTheme.primaryGreen,
                ),
              ),
              
              ListTile(
                leading: const Icon(Icons.key),
                title: const Text('Change PIN'),
                subtitle: const Text('Update your app PIN'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showComingSoon('Change PIN'),
              ),
              
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup Wallet'),
                subtitle: const Text('Secure your recovery phrase'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showComingSoon('Backup Wallet'),
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWalletSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Consumer<WalletProvider>(
          builder: (context, walletProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wallet Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: const Text('Connected Wallet'),
                  subtitle: Text(walletProvider.isConnected 
                      ? walletProvider.shortAddress 
                      : 'No wallet connected'),
                  trailing: walletProvider.isConnected 
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.error, color: Colors.red),
                ),
                
                if (walletProvider.isConnected) ...[
                  ListTile(
                    leading: const Icon(Icons.copy),
                    title: const Text('Copy Address'),
                    onTap: () {
                      // Copy address to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Address copied to clipboard!')),
                      );
                    },
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.link_off, color: Colors.red),
                    title: const Text('Disconnect Wallet'),
                    onTap: () {
                      walletProvider.disconnectWallet();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Wallet disconnected')),
                      );
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.link, color: Colors.green),
                    title: const Text('Connect Wallet'),
                    onTap: () {
                      walletProvider.connectWallet();
                      Navigator.pop(context);
                    },
                  ),
                ],
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to disconnect your wallet and logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final walletProvider = Provider.of<WalletProvider>(context, listen: false);
              walletProvider.disconnectWallet();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}