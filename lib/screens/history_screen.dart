import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../utils/theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';
  DateTime? _selectedDate;
  final List<String> _filterOptions = ['All', 'Payment', 'Received', 'Salary', 'Merchant', 'Conversion'];

  // Mock transaction data
  final List<Transaction> _mockTransactions = [
    createTransaction(
      id: 'txn_001',
      type: TransactionType.payment,
      amount: 150.00,
      currency: 'USDC',
      toAddress: '0x8765...4321',
      fromAddress: '0x1234...5678',
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      description: 'Coffee shop payment',
      fee: 0.50,
      txHash: '0xabc123...def456',
    ),
    createTransaction(
      id: 'txn_002',
      type: TransactionType.salary,
      amount: 2500.00,
      currency: 'USDC',
      toAddress: '0x1234...5678',
      fromAddress: '0x9999...1111',
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Monthly salary payment',
      fee: 2.00,
      txHash: '0xdef456...abc123',
    ),
    createTransaction(
      id: 'txn_003',
      type: TransactionType.payment,
      amount: 75.50,
      currency: 'USDT',
      toAddress: '0x5555...6666',
      fromAddress: '0x1234...5678',
      status: TransactionStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      description: 'Restaurant bill',
      fee: 0.25,
      txHash: '0x123abc...456def',
    ),
    createTransaction(
      id: 'txn_004',
      type: TransactionType.merchant,
      amount: 320.00,
      currency: 'USDC',
      toAddress: '0x1234...5678',
      fromAddress: '0x7777...8888',
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Product sale - Electronics',
      fee: 1.60,
      txHash: '0x789def...012ghi',
    ),
    createTransaction(
      id: 'txn_005',
      type: TransactionType.payment,
      amount: 45.25,
      currency: 'USDC',
      toAddress: '0x2222...3333',
      fromAddress: '0x1234...5678',
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      description: 'Grocery shopping',
      fee: 0.15,
      txHash: '0x456ghi...789jkl',
    ),
    createTransaction(
      id: 'txn_006',
      type: TransactionType.salary,
      amount: 2500.00,
      currency: 'USDC',
      toAddress: '0x1234...5678',
      fromAddress: '0x9999...1111',
      status: TransactionStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 31)),
      description: 'Previous month salary',
      fee: 2.00,
      txHash: '0x012jkl...345mno',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Select Date',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_csv',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Export as CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 8),
                    Text('Export as PDF'),
                  ],
                ),
              ),
            ],
            onSelected: _handleExport,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Transactions',
                    _filteredTransactions.length.toString(),
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Volume',
                    '\$${_calculateTotalVolume().toStringAsFixed(0)}',
                    Icons.trending_up,
                    AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'This Month',
                    _thisMonthTransactions.toString(),
                    Icons.calendar_month,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Filter: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filterOptions.map((filter) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: _selectedFilter == filter,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                            checkmarkColor: AppTheme.primaryGreen,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (_selectedDate != null)
                  Chip(
                    label: Text(_formatDateFilter(_selectedDate!)),
                    onDeleted: () {
                      setState(() {
                        _selectedDate = null;
                      });
                    },
                    deleteIcon: const Icon(Icons.close, size: 16),
                  ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: _filteredTransactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Transaction> get _filteredTransactions {
    return _mockTransactions.where((transaction) {
      final matchesFilter = _selectedFilter == 'All' || 
          transaction.type.toString().split('.').last.toLowerCase() == _selectedFilter.toLowerCase();
      
      final matchesDate = _selectedDate == null ||
          (transaction.timestamp.day == _selectedDate!.day &&
           transaction.timestamp.month == _selectedDate!.month &&
           transaction.timestamp.year == _selectedDate!.year);

      return matchesFilter && matchesDate;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  int get _thisMonthTransactions {
    final now = DateTime.now();
    return _mockTransactions.where((tx) => 
      tx.timestamp.month == now.month && tx.timestamp.year == now.year
    ).length;
  }

  double _calculateTotalVolume() {
    return _filteredTransactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isOutgoing = transaction.type == TransactionType.payment;
    final iconColor = isOutgoing ? Colors.red[600] : Colors.green[600];
    final icon = _getTransactionIcon(transaction.type);
    
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
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatAddress(transaction.toAddress),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isOutgoing ? '-' : '+'}${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(transaction.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction.status.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(transaction.status),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDateTime(transaction.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Fee: \$${transaction.fee.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or make your first transaction',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.payment:
        return Icons.arrow_upward;
      case TransactionType.salary:
        return Icons.payments;
      case TransactionType.merchant:
        return Icons.store;
      default:
        return Icons.swap_horiz;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.cancelled:
        return Colors.grey;
    }
  }

  String _formatAddress(String address) {
    return 'To: ${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inDays == 0) {
      return 'Today ${_formatTime(dateTime)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday ${_formatTime(dateTime)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateFilter(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...(_filterOptions.map((filter) => ListTile(
              title: Text(filter),
              leading: Radio<String>(
                value: filter,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
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

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _showTransactionDetails(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Transaction ID', transaction.hash),
            _buildDetailRow('Type', transaction.type.toString().split('.').last.toUpperCase()),
            _buildDetailRow('Amount', '${transaction.amount.toStringAsFixed(2)} ${transaction.currency}'),
            _buildDetailRow('Fee', '\$${transaction.fee.toStringAsFixed(2)}'),
            _buildDetailRow('Status', transaction.status.toString().split('.').last.toUpperCase()),
            _buildDetailRow('From', transaction.fromAddress),
            _buildDetailRow('To', transaction.toAddress),
            _buildDetailRow('Description', transaction.description),
            _buildDetailRow('Date', _formatDateTime(transaction.timestamp)),
            _buildDetailRow('TX Hash', transaction.hash),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (transaction.hash.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                // In production, open blockchain explorer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening blockchain explorer...'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('View on Explorer'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleExport(String exportType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              exportType == 'export_csv' ? Icons.file_download : Icons.picture_as_pdf,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(width: 12),
            Text('Export ${exportType == 'export_csv' ? 'CSV' : 'PDF'}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export ${_filteredTransactions.length} transactions to ${exportType == 'export_csv' ? 'CSV' : 'PDF'} file?',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Transactions:'),
                      Text(
                        '${_filteredTransactions.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Volume:'),
                      Text(
                        '\$${_calculateTotalVolume().toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter:'),
                      Text(
                        _selectedFilter,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _performExport(exportType);
            },
            icon: const Icon(Icons.download),
            label: const Text('Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  void _performExport(String exportType) {
    // Simulate export process
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
            const SizedBox(width: 16),
            Text('Exporting ${_filteredTransactions.length} transactions...'),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
    
    // Simulate export completion
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Exported to ${exportType == 'export_csv' ? 'transactions.csv' : 'transactions.pdf'}',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () {
                // In production: Open the exported file
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('File location: /Downloads/'),
                  ),
                );
              },
            ),
          ),
        );
      }
    });
  }
}
