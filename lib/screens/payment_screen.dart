import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/token_provider.dart';
import '../models/transaction.dart';
import '../models/token.dart';
import '../widgets/token_selector.dart';
import '../services/navigation_guard_service.dart';
import '../utils/theme.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> 
    with NavigationGuardMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _merchantController = TextEditingController();
  
  String _selectedCurrency = 'USDC';
  bool _isProcessing = false;
  Token? _selectedToken;
  
  final List<String> _currencies = ['USDC', 'USDT', 'DAI'];
  final List<String> _localCurrencies = ['NGN', 'KES', 'GHS', 'ZAR', 'USD'];
  String _selectedLocalCurrency = 'NGN';
  
  final Map<String, Map<String, double>> _exchangeRates = {
    'NGN': {'USDC': 775.0, 'USDT': 773.5, 'DAI': 776.2},
    'KES': {'USDC': 129.5, 'USDT': 129.1, 'DAI': 130.0},
    'GHS': {'USDC': 12.5, 'USDT': 12.4, 'DAI': 12.6},
    'ZAR': {'USDC': 18.2, 'USDT': 18.1, 'DAI': 18.3},
    'USD': {'USDC': 1.0, 'USDT': 0.998, 'DAI': 1.001},
  };
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TokenProvider>(context, listen: false).initialize();
    });
  }
  
  final List<Map<String, dynamic>> _recentMerchants = [
    {'name': 'Coffee Paradise', 'address': '0x456def789abc...', 'category': 'Food & Drink', 'rating': 4.8},
    {'name': 'Fresh Market', 'address': '0x789abc456def...', 'category': 'Groceries', 'rating': 4.6},
    {'name': 'Shell Station', 'address': '0x123def456abc...', 'category': 'Fuel', 'rating': 4.4},
    {'name': 'BookWorld', 'address': '0xabc123def456...', 'category': 'Books', 'rating': 4.7},
    {'name': 'TechHub', 'address': '0x321fed987cba...', 'category': 'Electronics', 'rating': 4.5},
    {'name': 'Pharma Plus', 'address': '0x654abc987fed...', 'category': 'Healthcare', 'rating': 4.9},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Payment'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryGreen,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _scanQRCode,
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan QR Code',
          ),
          IconButton(
            onPressed: _showPaymentQRCode,
            icon: const Icon(Icons.qr_code),
            tooltip: 'Show My QR Code',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Balance Card
              Consumer<WalletProvider>(
                builder: (context, wallet, child) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryGreen, AppTheme.primaryGreen.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Balance',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          wallet.isConnected ? '1,250.00 USDC' : 'Connect wallet to see balance',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Merchant Selection
              const Text(
                'Select Merchant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // Recent Merchants
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recentMerchants.length,
                  itemBuilder: (context, index) {
                    final merchant = _recentMerchants[index];
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: InkWell(
                        onTap: () {
                          _merchantController.text = merchant['name'];
                          _descriptionController.text = 'Payment to ${merchant['name']}';
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.store,
                                  color: AppTheme.primaryGreen,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                merchant['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                merchant['category'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Or Enter Merchant Manually
              TextFormField(
                controller: _merchantController,
                decoration: InputDecoration(
                  labelText: 'Merchant Name or Address',
                  hintText: 'Enter merchant name or wallet address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.store),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter merchant information';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Amount and Currency
              const Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter amount';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Enter valid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Consumer<TokenProvider>(
                      builder: (context, tokenProvider, child) {
                        return InkWell(
                          onTap: () async {
                            if (isOperationInProgress) {
                              print('PaymentScreen: Operation in progress, skipping token selection');
                              return;
                            }
                            
                            startProtectedOperation('selectToken');
                            
                            try {
                              final token = await showTokenSelector(
                                context: context,
                                title: 'Select Payment Token',
                                selectedToken: _selectedToken,
                                showBalance: true,
                              );
                              
                              if (token != null && mounted) {
                                setState(() {
                                  _selectedToken = token;
                                  _selectedCurrency = token.symbol;
                                });
                              }
                            } catch (e) {
                              print('PaymentScreen: Error selecting token: $e');
                            } finally {
                              completeProtectedOperation('selectToken');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                if (_selectedToken != null) ...[
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: _selectedToken!.typeColor.withValues(alpha: 0.1),
                                    child: Text(
                                      _selectedToken!.symbol.substring(0, 2).toUpperCase(),
                                      style: TextStyle(
                                        color: _selectedToken!.typeColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedToken!.symbol,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ] else ...[
                                  const Expanded(
                                    child: Text(
                                      'Select Token',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                                const Icon(Icons.keyboard_arrow_down, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Payment Description (Optional)',
                  hintText: 'What is this payment for?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Local Currency Conversion
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.secondaryGold.withValues(alpha: 0.1), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.secondaryGold.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Local Currency View',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryGold.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        DropdownButton<String>(
                          value: _selectedLocalCurrency,
                          items: _localCurrencies.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(currency, style: const TextStyle(fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLocalCurrency = value!;
                            });
                          },
                          underline: Container(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_amountController.text.isNotEmpty && double.tryParse(_amountController.text) != null)
                      _buildConversionDisplay(),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Pay Button
              Consumer<WalletProvider>(
                builder: (context, wallet, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: wallet.isConnected && !_isProcessing ? _processPayment : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              wallet.isConnected ? 'Pay Now' : 'Connect Wallet to Pay',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Security Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.green[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your payment is secured by blockchain technology and smart contracts.',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _scanQRCode() async {
    try {
      // Import mobile_scanner package for actual scanning
      // For now, show dialog with instructions
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.qr_code_scanner, color: AppTheme.primaryGreen),
              const SizedBox(width: 12),
              const Text('Scan QR Code'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_2, size: 100, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Point your camera at a QR code to scan merchant payment details.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // In production: Navigate to camera scanner screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Camera scanner will be implemented'),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Open Camera Scanner'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening scanner: $e')),
      );
    }
  }
  
  void _showPaymentQRCode() {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    if (!walletProvider.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect your wallet first')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Receive Payment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    // QR Code placeholder - In production, use qr_flutter package
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.qr_code_2,
                        size: 150,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Wallet Address',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      walletProvider.shortAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Copy address to clipboard
                      Clipboard.setData(
                        ClipboardData(text: walletProvider.walletAddressString),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address copied to clipboard'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Address'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Share QR code functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share functionality coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 3));
      
      // Create transaction record
      final transaction = TransactionModel(
        hash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}...',
        type: TransactionType.payment,
        amount: double.parse(_amountController.text),
        currency: _selectedCurrency,
        fromAddress: walletProvider.walletAddressString,
        toAddress: _merchantController.text.startsWith('0x') ? _merchantController.text : '0x456def789abc...',
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : 'Payment to ${_merchantController.text}',
        timestamp: DateTime.now(),
        status: TransactionStatus.completed,
        fee: double.parse(_amountController.text) * 0.001, // 0.1% fee
        merchantName: _merchantController.text.startsWith('0x') ? null : _merchantController.text,
      );
      
      transactionProvider.addTransaction(transaction);
      
      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600]),
                const SizedBox(width: 12),
                const Text('Payment Successful'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amount: ${_amountController.text} $_selectedCurrency'),
                Text('To: ${_merchantController.text}'),
                Text('Transaction: ${transaction.hash}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  Widget _buildConversionDisplay() {
    final amountValue = double.tryParse(_amountController.text) ?? 0.0;
    if (amountValue <= 0) return Container();
    
    final rate = _exchangeRates[_selectedLocalCurrency]?[_selectedCurrency] ?? 1.0;
    final convertedAmount = amountValue * rate;
    final currencySymbol = _getCurrencySymbol(_selectedLocalCurrency);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You Pay',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${amountValue.toStringAsFixed(2)} $_selectedCurrency',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward, color: Colors.grey),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Local Equivalent',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$currencySymbol${convertedAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rate: 1 $_selectedCurrency = $currencySymbol${rate.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'NGN':
        return '₦';
      case 'KES':
        return 'KSh';
      case 'GHS':
        return '₵';
      case 'ZAR':
        return 'R';
      case 'USD':
        return '\$';
      default:
        return currency;
    }
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _merchantController.dispose();
    super.dispose();
  }
}
