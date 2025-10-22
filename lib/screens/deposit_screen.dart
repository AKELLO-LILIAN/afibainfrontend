import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';
import '../widgets/deposit_method_card.dart';
import '../models/deposit_method.dart';
import '../services/deposit_service.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  
  DepositMethod? _selectedMethod;
  bool _isProcessing = false;
  String? _transactionId;
  
  final List<DepositMethod> _depositMethods = [
    DepositMethod(
      id: 'mtn_mobile_money',
      name: 'MTN Mobile Money',
      description: 'Deposit using MTN Mobile Money',
      iconAsset: 'assets/images/mtn_logo.png',
      color: Colors.yellow[700]!,
      minAmount: 1000.0,
      maxAmount: 1000000.0,
      fee: 0.02, // 2%
      processingTime: '2-5 minutes',
      isActive: true,
      supportedCurrencies: ['UGX', 'USD'],
    ),
    DepositMethod(
      id: 'airtel_money',
      name: 'Airtel Money',
      description: 'Deposit using Airtel Money',
      iconAsset: 'assets/images/airtel_logo.png',
      color: Colors.red[700]!,
      minAmount: 1000.0,
      maxAmount: 1000000.0,
      fee: 0.02, // 2%
      processingTime: '2-5 minutes',
      isActive: true,
      supportedCurrencies: ['UGX', 'USD'],
    ),
    DepositMethod(
      id: 'bank_transfer',
      name: 'Bank Transfer',
      description: 'Deposit via bank transfer',
      iconAsset: 'assets/images/bank_logo.png',
      color: Colors.blue[700]!,
      minAmount: 10000.0,
      maxAmount: 10000000.0,
      fee: 0.01, // 1%
      processingTime: '1-3 business days',
      isActive: true,
      supportedCurrencies: ['UGX', 'USD'],
    ),
    DepositMethod(
      id: 'visa_mastercard',
      name: 'Visa/Mastercard',
      description: 'Deposit using your debit/credit card',
      iconAsset: 'assets/images/card_logo.png',
      color: Colors.indigo[700]!,
      minAmount: 5000.0,
      maxAmount: 2000000.0,
      fee: 0.035, // 3.5%
      processingTime: 'Instant',
      isActive: true,
      supportedCurrencies: ['USD', 'UGX'],
    ),
  ];
  
  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _accountController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit Funds'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen.withOpacity(0.1),
                    AppTheme.primaryGreen.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Deposit Information',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Deposited funds will be converted to stablecoins (USDC/USDT)\n'
                    '• You can use these funds to buy other tokens\n'
                    '• Processing times vary by payment method\n'
                    '• All deposits are secured by blockchain technology',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Deposit Methods
            const Text(
              'Select Deposit Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._depositMethods.map((method) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DepositMethodCard(
                method: method,
                isSelected: _selectedMethod?.id == method.id,
                onTap: () {
                  setState(() {
                    _selectedMethod = method;
                  });
                },
              ),
            )),
            
            const SizedBox(height: 24),
            
            // Amount Input
            if (_selectedMethod != null) ...[
              const Text(
                'Enter Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  hintText: 'Enter amount in UGX',
                  prefixText: 'UGX ',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _amountController.clear(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryGreen),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (value) {
                  setState(() {}); // Rebuild to update fee calculation
                },
              ),
              
              const SizedBox(height: 8),
              
              // Amount limits
              Text(
                'Min: UGX ${_selectedMethod!.minAmount.toStringAsFixed(0)} • '
                'Max: UGX ${_selectedMethod!.maxAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Fee Breakdown
              if (_amountController.text.isNotEmpty && 
                  double.tryParse(_amountController.text) != null)
                _buildFeeBreakdown(),
              
              const SizedBox(height: 16),
              
              // Payment Details Input
              _buildPaymentDetailsInput(),
              
              const SizedBox(height: 24),
              
              // Deposit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _canProceedWithDeposit() && !_isProcessing
                      ? _processDeposit
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Processing...'),
                          ],
                        )
                      : const Text(
                          'Proceed with Deposit',
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
    );
  }
  
  Widget _buildFeeBreakdown() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final fee = amount * _selectedMethod!.fee;
    final total = amount + fee;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Amount:', style: TextStyle(fontSize: 14)),
              Text(
                'UGX ${amount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fee (${(_selectedMethod!.fee * 100).toStringAsFixed(1)}%):',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'UGX ${fee.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'UGX ${total.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentDetailsInput() {
    if (_selectedMethod == null) return const SizedBox.shrink();
    
    switch (_selectedMethod!.id) {
      case 'mtn_mobile_money':
      case 'airtel_money':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phone Number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
              ],
              decoration: InputDecoration(
                hintText: 'Enter your ${_selectedMethod!.name} number',
                prefixText: '+256 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryGreen),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        );
        
      case 'bank_transfer':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _accountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: 'Enter your bank account number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryGreen),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        );
        
      case 'visa_mastercard':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.credit_card,
                color: Colors.blue[700],
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Card Payment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You will be redirected to a secure payment page',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
        
      default:
        return const SizedBox.shrink();
    }
  }
  
  bool _canProceedWithDeposit() {
    if (_selectedMethod == null || _amountController.text.isEmpty) {
      return false;
    }
    
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount < _selectedMethod!.minAmount || amount > _selectedMethod!.maxAmount) {
      return false;
    }
    
    switch (_selectedMethod!.id) {
      case 'mtn_mobile_money':
      case 'airtel_money':
        return _phoneController.text.isNotEmpty;
      case 'bank_transfer':
        return _accountController.text.isNotEmpty;
      case 'visa_mastercard':
        return true;
      default:
        return false;
    }
  }
  
  Future<void> _processDeposit() async {
    if (!_canProceedWithDeposit()) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final amount = double.parse(_amountController.text);
      final depositRequest = DepositRequest(
        method: _selectedMethod!,
        amount: amount,
        phoneNumber: _phoneController.text,
        accountNumber: _accountController.text,
      );
      
      final result = await DepositService.processDeposit(depositRequest);
      
      if (result.success) {
        setState(() {
          _transactionId = result.transactionId;
        });
        
        _showDepositConfirmation(result);
      } else {
        _showErrorDialog(result.errorMessage ?? 'Deposit failed. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while processing your deposit. Please try again.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  void _showDepositConfirmation(DepositResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 28),
            const SizedBox(width: 12),
            const Text('Deposit Initiated'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your deposit request has been submitted successfully.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction ID: ${result.transactionId}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Amount: UGX ${result.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Method: ${result.methodName}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Status: ${result.status}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Processing time: ${_selectedMethod!.processingTime}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red[600], size: 28),
            const SizedBox(width: 12),
            const Text('Deposit Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}