import 'package:flutter/material.dart';
import '../models/deposit_method.dart';

class DepositMethodCard extends StatelessWidget {
  final DepositMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const DepositMethodCard({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: method.isActive ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: method.isActive 
              ? (isSelected ? method.color.withOpacity(0.1) : Colors.white)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? method.color 
                : (method.isActive ? Colors.grey[300]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: method.isActive
              ? [
                  BoxShadow(
                    color: isSelected 
                        ? method.color.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon/Logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: method.isActive 
                    ? method.color.withOpacity(0.1)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: method.iconAsset.startsWith('assets/')
                  ? _buildAssetIcon()
                  : _buildFallbackIcon(),
            ),
            
            const SizedBox(width: 16),
            
            // Method Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          method.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: method.isActive 
                                ? Colors.black87 
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: method.color,
                          size: 20,
                        )
                      else if (!method.isActive)
                        Icon(
                          Icons.block,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    method.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: method.isActive 
                          ? Colors.grey[600] 
                          : Colors.grey[500],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Method details
                  Row(
                    children: [
                      _buildDetailChip(
                        'Fee: ${method.feePercentage}',
                        Icons.percent,
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        method.processingTime,
                        Icons.schedule,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    'Min: ${_formatAmount(method.minAmount)} • Max: ${_formatAmount(method.maxAmount)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: method.isActive 
                          ? Colors.grey[500] 
                          : Colors.grey[400],
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

  Widget _buildAssetIcon() {
    // For now, we'll use fallback icons since we don't have actual assets
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    IconData iconData;
    switch (method.id) {
      case 'mtn_mobile_money':
        iconData = Icons.phone_android;
        break;
      case 'airtel_money':
        iconData = Icons.smartphone;
        break;
      case 'bank_transfer':
        iconData = Icons.account_balance;
        break;
      case 'visa_mastercard':
        iconData = Icons.credit_card;
        break;
      default:
        iconData = Icons.payment;
    }

    return Icon(
      iconData,
      color: method.isActive ? method.color : Colors.grey[600],
      size: 24,
    );
  }

  Widget _buildDetailChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: method.isActive 
            ? Colors.grey[100] 
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: method.isActive 
                ? Colors.grey[600] 
                : Colors.grey[400],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: method.isActive 
                  ? Colors.grey[600] 
                  : Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}