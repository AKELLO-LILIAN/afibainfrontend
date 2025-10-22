import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../utils/theme.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final List<Employee> _employees = [
    Employee(
      id: '001',
      name: 'John Doe',
      position: 'Senior Software Developer',
      walletAddress: '0x742d35Cc6634C0532925a3b8D5C9F9b4E6Bf31F4',
      salary: 2500.0,
      currency: 'USDC',
      paymentFrequency: 'Monthly',
      isActive: true,
      joinDate: DateTime(2023, 6, 15),
      lastPayment: DateTime(2024, 10, 30),
      paymentHistory: [
        PaymentRecord(date: DateTime(2024, 10, 30), amount: 2500.0, currency: 'USDC', status: 'Completed', txHash: '0xabc123...def456'),
        PaymentRecord(date: DateTime(2024, 9, 30), amount: 2500.0, currency: 'USDC', status: 'Completed', txHash: '0x789abc...123def'),
        PaymentRecord(date: DateTime(2024, 8, 30), amount: 2500.0, currency: 'USDC', status: 'Completed', txHash: '0x456def...789abc'),
        PaymentRecord(date: DateTime(2024, 7, 30), amount: 2500.0, currency: 'USDC', status: 'Completed', txHash: '0x123def...456abc'),
      ],
    ),
    Employee(
      id: '002',
      name: 'Mary Johnson',
      position: 'Product Manager',
      walletAddress: '0x8ba1f109551bD432803012645Hac136c772aBCd',
      salary: 3200.0,
      currency: 'USDT',
      paymentFrequency: 'Monthly',
      isActive: true,
      joinDate: DateTime(2023, 3, 10),
      lastPayment: DateTime(2024, 10, 30),
      paymentHistory: [
        PaymentRecord(date: DateTime(2024, 10, 30), amount: 3200.0, currency: 'USDT', status: 'Completed', txHash: '0xfed456...cba987'),
        PaymentRecord(date: DateTime(2024, 9, 30), amount: 3200.0, currency: 'USDT', status: 'Completed', txHash: '0x987fed...654cba'),
        PaymentRecord(date: DateTime(2024, 8, 30), amount: 3200.0, currency: 'USDT', status: 'Completed', txHash: '0x654cba...321fed'),
      ],
    ),
    Employee(
      id: '003',
      name: 'David Wilson',
      position: 'UI/UX Designer',
      walletAddress: '0x95aD61B0a150d79219dCF64E1E6Cc01f0B64C4cE',
      salary: 2200.0,
      currency: 'USDC',
      paymentFrequency: 'Bi-weekly',
      isActive: true,
      joinDate: DateTime(2023, 8, 22),
      lastPayment: DateTime(2024, 10, 15),
      paymentHistory: [
        PaymentRecord(date: DateTime(2024, 10, 15), amount: 1100.0, currency: 'USDC', status: 'Completed', txHash: '0x111aaa...999zzz'),
        PaymentRecord(date: DateTime(2024, 10, 1), amount: 1100.0, currency: 'USDC', status: 'Completed', txHash: '0x222bbb...888yyy'),
        PaymentRecord(date: DateTime(2024, 9, 15), amount: 1100.0, currency: 'USDC', status: 'Completed', txHash: '0x333ccc...777xxx'),
        PaymentRecord(date: DateTime(2024, 9, 1), amount: 1100.0, currency: 'USDC', status: 'Completed', txHash: '0x444ddd...666www'),
      ],
    ),
    Employee(
      id: '004',
      name: 'Sarah Brown',
      position: 'Marketing Specialist',
      walletAddress: '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed',
      salary: 2000.0,
      currency: 'USDC',
      paymentFrequency: 'Monthly',
      isActive: false,
      joinDate: DateTime(2023, 1, 5),
      lastPayment: DateTime(2024, 8, 31),
      paymentHistory: [
        PaymentRecord(date: DateTime(2024, 8, 31), amount: 2000.0, currency: 'USDC', status: 'Completed', txHash: '0x555eee...444vvv'),
        PaymentRecord(date: DateTime(2024, 7, 31), amount: 2000.0, currency: 'USDC', status: 'Completed', txHash: '0x666fff...333uuu'),
        PaymentRecord(date: DateTime(2024, 6, 30), amount: 2000.0, currency: 'USDC', status: 'Completed', txHash: '0x777ggg...222ttt'),
      ],
    ),
    Employee(
      id: '005',
      name: 'Michael Chen',
      position: 'DevOps Engineer',
      walletAddress: '0xdD870fA1b7C4700F2BD7f44238821C26f7392148',
      salary: 2800.0,
      currency: 'USDT',
      paymentFrequency: 'Monthly',
      isActive: true,
      joinDate: DateTime(2023, 11, 3),
      lastPayment: DateTime(2024, 10, 30),
      paymentHistory: [
        PaymentRecord(date: DateTime(2024, 10, 30), amount: 2800.0, currency: 'USDT', status: 'Completed', txHash: '0x888hhh...111sss'),
        PaymentRecord(date: DateTime(2024, 9, 30), amount: 2800.0, currency: 'USDT', status: 'Completed', txHash: '0x999iii...000rrr'),
        PaymentRecord(date: DateTime(2024, 8, 30), amount: 2800.0, currency: 'USDT', status: 'Completed', txHash: '0xaaajjj...zzzqqq'),
      ],
    ),
    Employee(
      id: '006',
      name: 'Emily Rodriguez',
      position: 'Frontend Developer',
      walletAddress: '0x71C7656EC7ab88b098defB751B7401B5f6d8976F',
      salary: 2300.0,
      currency: 'USDC',
      paymentFrequency: 'Monthly',
      isActive: true,
      joinDate: DateTime(2024, 2, 1),
      lastPayment: DateTime(2024, 10, 30),
      paymentHistory: [
        PaymentRecord(date: DateTime(2024, 10, 30), amount: 2300.0, currency: 'USDC', status: 'Completed', txHash: '0xbbbkkk...yyyppp'),
        PaymentRecord(date: DateTime(2024, 9, 30), amount: 2300.0, currency: 'USDC', status: 'Completed', txHash: '0xcccxxx...xxxooo'),
        PaymentRecord(date: DateTime(2024, 8, 30), amount: 2300.0, currency: 'USDC', status: 'Completed', txHash: '0xdddmmm...wwwnnn'),
      ],
    ),
    Employee(
      id: '007',
      name: 'James Thompson',
      position: 'Backend Developer',
      walletAddress: '0x2546BcD3c84621e976D8185a91A922aE77ECEc30',
      salary: 2600.0,
      currency: 'USDT',
      paymentFrequency: 'Monthly',
      isActive: true,
      joinDate: DateTime(2024, 1, 15),
      lastPayment: DateTime(2024, 10, 30),
      paymentHistory: [
        PaymentRecord(date: DateTime(2024, 10, 30), amount: 2600.0, currency: 'USDT', status: 'Completed', txHash: '0xeeeann...vvvmmm'),
        PaymentRecord(date: DateTime(2024, 9, 30), amount: 2600.0, currency: 'USDT', status: 'Completed', txHash: '0xfffboo...uuulll'),
        PaymentRecord(date: DateTime(2024, 8, 30), amount: 2600.0, currency: 'USDT', status: 'Completed', txHash: '0xgggcpp...tttkkk'),
      ],
    ),
    Employee(
      id: '008',
      name: 'Lisa Wang',
      position: 'QA Engineer',
      walletAddress: '0x8ba1f109551bD432803012645Hac136c772aBCd9',
      salary: 2100.0,
      currency: 'USDC',
      paymentFrequency: 'Monthly',
      isActive: true,
      joinDate: DateTime(2024, 3, 20),
      lastPayment: DateTime(2024, 10, 30),
      paymentHistory: [
        PaymentRecord(date: DateTime(2024, 10, 30), amount: 2100.0, currency: 'USDC', status: 'Completed', txHash: '0xhhhdqq...sssjjj'),
        PaymentRecord(date: DateTime(2024, 9, 30), amount: 2100.0, currency: 'USDC', status: 'Completed', txHash: '0xiiierr...rrriii'),
      ],
    ),
    Employee(
      id: '009',
      name: 'Robert Kim',
      position: 'Business Analyst',
      walletAddress: '0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C',
      salary: 2400.0,
      currency: 'USDT',
      paymentFrequency: 'Monthly',
      isActive: true,
      joinDate: DateTime(2024, 4, 10),
      lastPayment: DateTime(2024, 10, 30),
      paymentHistory: [
        PaymentRecord(date: DateTime(2024, 10, 30), amount: 2400.0, currency: 'USDT', status: 'Completed', txHash: '0xjjjfss...qqqhhh'),
        PaymentRecord(date: DateTime(2024, 9, 30), amount: 2400.0, currency: 'USDT', status: 'Completed', txHash: '0xkkkgtt...pppggg'),
      ],
    ),
    Employee(
      id: '010',
      name: 'Anna Martinez',
      position: 'Data Scientist',
      walletAddress: '0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c',
      salary: 3500.0,
      currency: 'USDT',
      paymentFrequency: 'Monthly',
      isActive: true,
      joinDate: DateTime(2024, 5, 1),
      lastPayment: DateTime(2024, 10, 30),
      paymentHistory: [
        PaymentRecord(date: DateTime(2024, 10, 30), amount: 3500.0, currency: 'USDT', status: 'Completed', txHash: '0xlllhuu...ooofff'),
        PaymentRecord(date: DateTime(2024, 9, 30), amount: 3500.0, currency: 'USDT', status: 'Pending', txHash: ''),
      ],
    ),
  ];

  String _searchQuery = '';
  String _filterStatus = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _addEmployee,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search employees...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Filter Chips
                Row(
                  children: [
                    const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('All'),
                      selected: _filterStatus == 'All',
                      onSelected: (selected) => setState(() => _filterStatus = 'All'),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Active'),
                      selected: _filterStatus == 'Active',
                      onSelected: (selected) => setState(() => _filterStatus = 'Active'),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Inactive'),
                      selected: _filterStatus == 'Inactive',
                      onSelected: (selected) => setState(() => _filterStatus = 'Inactive'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Summary Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Employees',
                    _employees.length.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Active',
                    _employees.where((e) => e.isActive).length.toString(),
                    Icons.person,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Payroll',
                    '\$${_employees.where((e) => e.isActive).fold(0.0, (sum, e) => sum + e.salary).toStringAsFixed(0)}',
                    Icons.payments,
                    AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          
          // Employee List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredEmployees.length,
              itemBuilder: (context, index) {
                final employee = _filteredEmployees[index];
                return _buildEmployeeCard(employee);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Employee> get _filteredEmployees {
    return _employees.where((employee) {
      final matchesSearch = _searchQuery.isEmpty ||
          employee.name.toLowerCase().contains(_searchQuery) ||
          employee.position.toLowerCase().contains(_searchQuery);
      
      final matchesFilter = _filterStatus == 'All' ||
          (_filterStatus == 'Active' && employee.isActive) ||
          (_filterStatus == 'Inactive' && !employee.isActive);
      
      return matchesSearch && matchesFilter;
    }).toList();
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
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
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
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
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
          backgroundColor: employee.isActive ? AppTheme.primaryGreen : Colors.grey,
          child: Text(
            employee.name.substring(0, 2).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                employee.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: employee.isActive ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                employee.isActive ? 'ACTIVE' : 'INACTIVE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: employee.isActive ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              employee.position,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Wallet: ${employee.shortWalletAddress}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.payments, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${employee.salary.toStringAsFixed(0)} ${employee.currency}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  employee.paymentFrequency,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('View Details'),
              ),
            ),
            const PopupMenuItem(
              value: 'pay',
              child: ListTile(
                leading: Icon(Icons.payment),
                title: Text('Process Payment'),
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Employee'),
              ),
            ),
            if (employee.isActive)
              const PopupMenuItem(
                value: 'deactivate',
                child: ListTile(
                  leading: Icon(Icons.person_off),
                  title: Text('Deactivate'),
                ),
              )
            else
              const PopupMenuItem(
                value: 'activate',
                child: ListTile(
                  leading: Icon(Icons.person_add),
                  title: Text('Activate'),
                ),
              ),
          ],
          onSelected: (value) => _handleEmployeeAction(employee, value.toString()),
        ),
      ),
    );
  }

  void _addEmployee() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add employee feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleEmployeeAction(Employee employee, String action) {
    switch (action) {
      case 'view':
        _showEmployeeDetails(employee);
        break;
      case 'pay':
        _processPayment(employee);
        break;
      case 'edit':
        _editEmployee(employee);
        break;
      case 'activate':
      case 'deactivate':
        _toggleEmployeeStatus(employee);
        break;
    }
  }

  void _showEmployeeDetails(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        employee.name.substring(0, 2).toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            employee.position,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: employee.isActive ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        employee.isActive ? 'ACTIVE' : 'INACTIVE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Details and Payment History
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Details', icon: Icon(Icons.person)),
                          Tab(text: 'Payment History', icon: Icon(Icons.payment)),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Details Tab
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('Employee ID', employee.id),
                                  _buildDetailRow('Wallet Address', employee.walletAddress),
                                  _buildDetailRow('Salary', '${employee.salary.toStringAsFixed(2)} ${employee.currency}'),
                                  _buildDetailRow('Payment Frequency', employee.paymentFrequency),
                                  _buildDetailRow('Join Date', _formatDate(employee.joinDate)),
                                  _buildDetailRow('Last Payment', _formatDate(employee.lastPayment)),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Payment Statistics',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetailRow('Total Payments', employee.completedPayments.toString()),
                                  _buildDetailRow('Total Amount Paid', '${employee.totalPayments.toStringAsFixed(2)} ${employee.currency}'),
                                ],
                              ),
                            ),
                            
                            // Payment History Tab
                            _buildPaymentHistoryTab(employee),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    if (employee.isActive)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _processPayment(employee);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Process Payment'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _processPayment(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Process Payment for ${employee.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to process salary payment?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Amount:'),
                      Text(
                        '${employee.salary.toStringAsFixed(2)} ${employee.currency}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('To:'),
                      Text(
                        employee.shortWalletAddress,
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _executeSalaryPayment(employee);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Process Payment'),
          ),
        ],
      ),
    );
  }

  void _executeSalaryPayment(Employee employee) {
    // Simulate payment processing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Processing payment for ${employee.name}...'),
        duration: const Duration(seconds: 3),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
    
    // In real implementation, integrate with salary payment contract
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment sent to ${employee.name} successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          employee.lastPayment = DateTime.now();
        });
      }
    });
  }

  void _editEmployee(Employee employee) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit employee feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleEmployeeStatus(Employee employee) {
    setState(() {
      employee.isActive = !employee.isActive;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          employee.isActive 
            ? '${employee.name} has been activated' 
            : '${employee.name} has been deactivated'
        ),
        backgroundColor: employee.isActive ? Colors.green : Colors.orange,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPaymentHistoryTab(Employee employee) {
    if (employee.paymentHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No payment history available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: employee.paymentHistory.length,
      itemBuilder: (context, index) {
        final payment = employee.paymentHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: payment.status == 'Completed' 
                  ? Colors.green[100] 
                  : Colors.orange[100],
              child: Icon(
                payment.status == 'Completed' 
                    ? Icons.check 
                    : Icons.access_time,
                color: payment.status == 'Completed' 
                    ? Colors.green 
                    : Colors.orange,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    '${payment.amount.toStringAsFixed(2)} ${payment.currency}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: payment.status == 'Completed' 
                        ? Colors.green[100] 
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    payment.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: payment.status == 'Completed' 
                          ? Colors.green[700] 
                          : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Date: ${payment.formattedDate}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (payment.txHash.isNotEmpty)
                  Text(
                    'Tx: ${payment.shortTxHash}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
            trailing: payment.txHash.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.open_in_new, size: 16),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Transaction Hash: ${payment.txHash}'),
                          action: SnackBarAction(
                            label: 'Copy',
                            onPressed: () {
                              // Copy to clipboard functionality would go here
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Transaction hash copied!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  )
                : null,
          ),
        );
      },
    );
  }
}

class Employee {
  final String id;
  final String name;
  final String position;
  final String walletAddress;
  final double salary;
  final String currency;
  final String paymentFrequency;
  bool isActive;
  final DateTime joinDate;
  DateTime lastPayment;
  final List<PaymentRecord> paymentHistory;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.walletAddress,
    required this.salary,
    required this.currency,
    required this.paymentFrequency,
    required this.isActive,
    required this.joinDate,
    required this.lastPayment,
    this.paymentHistory = const [],
  });

  String get shortWalletAddress {
    return '${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}';
  }

  double get totalPayments {
    return paymentHistory
        .where((payment) => payment.status == 'Completed')
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  int get completedPayments {
    return paymentHistory.where((payment) => payment.status == 'Completed').length;
  }
}

class PaymentRecord {
  final DateTime date;
  final double amount;
  final String currency;
  final String status;
  final String txHash;

  const PaymentRecord({
    required this.date,
    required this.amount,
    required this.currency,
    required this.status,
    required this.txHash,
  });

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get shortTxHash {
    return txHash.isNotEmpty 
        ? '${txHash.substring(0, 8)}...${txHash.substring(txHash.length - 6)}'
        : 'Pending';
  }
}
