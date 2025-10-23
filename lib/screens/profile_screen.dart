import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  
  // User profile data
  String _userName = 'AfriBain User';
  String _userEmail = 'user@afribain.com';
  String _userPhone = '+234 XXX XXX XXXX';
  String _userBio = 'Blockchain enthusiast';
  
  // Contacts list
  final List<Map<String, String>> _contacts = [
    {
      'name': 'Alice Johnson',
      'walletAddress': '0x742d35Cc6634C0532925a3b8D5C9F9b4E6Bf31F4',
      'phone': '+234 801 234 5678',
      'email': 'alice@example.com',
      'note': 'Business partner',
    },
    {
      'name': 'Bob Smith',
      'walletAddress': '0x8ba1f109551bD432803012645Hac136c772aBCd',
      'phone': '+234 802 345 6789',
      'email': 'bob@example.com',
      'note': 'Friend',
    },
  ];

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
                        _userName,
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
                      () => _showPersonalInfoDialog(),
                    ),
                    _buildSettingsItem(
                      'My Contacts',
                      '${_contacts.length} saved contacts',
                      Icons.contacts,
                      () => _showContactsScreen(),
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
                      () => _showHelpSupport(),
                    ),
                    _buildSettingsItem(
                      'Terms of Service',
                      'Read our terms and conditions',
                      Icons.description,
                      () => _showTermsOfService(),
                    ),
                    _buildSettingsItem(
                      'Privacy Policy',
                      'Learn about data usage',
                      Icons.privacy_tip,
                      () => _showPrivacyPolicy(),
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
    _showPersonalInfoDialog();
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
                      Clipboard.setData(
                        ClipboardData(text: walletProvider.walletAddressString),
                      );
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
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/wallet_connect');
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
  
  void _showPersonalInfoDialog() {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);
    final phoneController = TextEditingController(text: _userPhone);
    final bioController = TextEditingController(text: _userBio);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personal Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: Icon(Icons.info),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userName = nameController.text;
                _userEmail = emailController.text;
                _userPhone = phoneController.text;
                _userBio = bioController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            const Text('Help & Support'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How can we help you?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.email, color: AppTheme.primaryGreen),
                title: const Text('Email Support'),
                subtitle: const Text('support@afribain.com'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening email client...')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.phone, color: AppTheme.primaryGreen),
                title: const Text('Phone Support'),
                subtitle: const Text('+256 740819876'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dialing support...')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.chat, color: AppTheme.primaryGreen),
                title: const Text('Live Chat'),
                subtitle: const Text('Available 24/7'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starting live chat...')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.book, color: AppTheme.primaryGreen),
                title: const Text('FAQs'),
                subtitle: const Text('Browse common questions'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening FAQ section...')),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.privacy_tip, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            const Text('Privacy Policy'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AfriBain Privacy Policy',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Last updated: October 2024',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Information We Collect',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'We collect information that you provide directly to us, including wallet addresses, transaction data, and profile information. We do not store your private keys or seed phrases.',
              ),
              const SizedBox(height: 16),
              const Text(
                '2. How We Use Your Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your information is used to provide and improve our services, process transactions, maintain security, and comply with legal obligations.',
              ),
              const SizedBox(height: 16),
              const Text(
                '3. Data Security',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'We implement industry-standard security measures including encryption, secure storage, and regular security audits to protect your data.',
              ),
              const SizedBox(height: 16),
              const Text(
                '4. Your Rights',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You have the right to access, correct, or delete your personal information. You can also export your data at any time.',
              ),
              const SizedBox(height: 16),
              const Text(
                '5. Contact Us',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'For privacy concerns, contact us at privacy@afribain.com',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy accepted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
  
  void _showContactsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('My Contacts'),
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () => _showAddContactDialog(),
                tooltip: 'Add Contact',
              ),
            ],
          ),
          body: _contacts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.contacts_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No contacts yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add contacts to send payments quickly',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showAddContactDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Contact'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                          child: Text(
                            contact['name']!.substring(0, 2).toUpperCase(),
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          contact['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (contact['note']?.isNotEmpty ?? false)
                              Text(
                                contact['note']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              _shortenAddress(contact['walletAddress']!),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'send',
                              child: Row(
                                children: [
                                  Icon(Icons.send),
                                  SizedBox(width: 8),
                                  Text('Send Payment'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility),
                                  SizedBox(width: 8),
                                  Text('View Details'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) => _handleContactAction(value.toString(), index, contact),
                        ),
                        onTap: () => _showContactDetails(contact),
                      ),
                    );
                  },
                ),
          floatingActionButton: _contacts.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () => _showAddContactDialog(),
                  backgroundColor: AppTheme.primaryGreen,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
        ),
      ),
    );
  }
  
  String _shortenAddress(String address) {
    if (address.length <= 13) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
  
  void _handleContactAction(String action, int index, Map<String, String> contact) {
    switch (action) {
      case 'send':
        Navigator.pop(context);
        Navigator.pushNamed(context, '/payment');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sending payment to ${contact['name']}')),
        );
        break;
      case 'view':
        _showContactDetails(contact);
        break;
      case 'edit':
        _showEditContactDialog(index, contact);
        break;
      case 'delete':
        _deleteContact(index, contact);
        break;
    }
  }
  
  void _showContactDetails(Map<String, String> contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
              child: Text(
                contact['name']!.substring(0, 2).toUpperCase(),
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                contact['name']!,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildContactDetailRow('Wallet Address', contact['walletAddress']!, Icons.account_balance_wallet),
              if (contact['email']?.isNotEmpty ?? false)
                _buildContactDetailRow('Email', contact['email']!, Icons.email),
              if (contact['phone']?.isNotEmpty ?? false)
                _buildContactDetailRow('Phone', contact['phone']!, Icons.phone),
              if (contact['note']?.isNotEmpty ?? false)
                _buildContactDetailRow('Note', contact['note']!, Icons.note),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/payment');
            },
            icon: const Icon(Icons.send),
            label: const Text('Send Payment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied to clipboard')),
              );
            },
          ),
        ],
      ),
    );
  }
  
  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final walletController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final noteController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: walletController,
                decoration: const InputDecoration(
                  labelText: 'Wallet Address *',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  hintText: '0x...',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (Optional)',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || walletController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Name and Wallet Address are required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              setState(() {
                _contacts.add({
                  'name': nameController.text,
                  'walletAddress': walletController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'note': noteController.text,
                });
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${nameController.text} added to contacts'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  void _showEditContactDialog(int index, Map<String, String> contact) {
    final nameController = TextEditingController(text: contact['name']);
    final walletController = TextEditingController(text: contact['walletAddress']);
    final emailController = TextEditingController(text: contact['email']);
    final phoneController = TextEditingController(text: contact['phone']);
    final noteController = TextEditingController(text: contact['note']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: walletController,
                decoration: const InputDecoration(
                  labelText: 'Wallet Address *',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (Optional)',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || walletController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Name and Wallet Address are required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              setState(() {
                _contacts[index] = {
                  'name': nameController.text,
                  'walletAddress': walletController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'note': noteController.text,
                };
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact updated'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _deleteContact(int index, Map<String, String> contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _contacts.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${contact['name']} deleted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.description, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            const Text('Terms of Service'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AfriBain Terms of Service',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Last updated: October 2024',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Acceptance of Terms',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'By accessing and using AfriBain, you accept and agree to be bound by these Terms of Service and our Privacy Policy.',
              ),
              const SizedBox(height: 16),
              const Text(
                '2. Service Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'AfriBain provides a non-custodial stablecoin platform for payments, conversions, and payroll management using blockchain technology.',
              ),
              const SizedBox(height: 16),
              const Text(
                '3. User Responsibilities',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You are responsible for maintaining the security of your wallet, private keys, and account credentials. AfriBain cannot recover lost keys or access your funds.',
              ),
              const SizedBox(height: 16),
              const Text(
                '4. Transaction Fees',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Network fees and service charges apply to transactions. Fees are displayed before confirmation and vary based on network conditions.',
              ),
              const SizedBox(height: 16),
              const Text(
                '5. Prohibited Activities',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You may not use AfriBain for illegal activities, money laundering, fraud, or any activity that violates local or international laws.',
              ),
              const SizedBox(height: 16),
              const Text(
                '6. Limitation of Liability',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'AfriBain is provided "as is" without warranties. We are not liable for losses due to market volatility, technical issues, or user error.',
              ),
              const SizedBox(height: 16),
              const Text(
                '7. Contact',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'For questions about these terms, contact legal@afribain.com',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms accepted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}
