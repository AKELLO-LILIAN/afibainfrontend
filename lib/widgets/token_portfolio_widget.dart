import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/token.dart';
import '../providers/token_provider.dart';

class TokenPortfolioWidget extends StatelessWidget {
  final bool showTitle;
  final bool expandable;
  final VoidCallback? onViewAll;

  const TokenPortfolioWidget({
    super.key,
    this.showTitle = true,
    this.expandable = true,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TokenProvider>(
      builder: (context, tokenProvider, child) {
        if (tokenProvider.isLoadingBalances) {
          return const _LoadingPortfolio();
        }

        if (tokenProvider.allBalances.isEmpty) {
          return const _EmptyPortfolio();
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              if (showTitle) ...[
                _buildHeader(context, tokenProvider),
                const Divider(height: 1),
              ],
              _buildPortfolioValue(context, tokenProvider),
              const Divider(height: 1),
              _buildTypeBreakdown(context, tokenProvider),
              const Divider(height: 1),
              _buildTokenList(context, tokenProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, TokenProvider tokenProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Token Portfolio',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: const Text('View All'),
            ),
        ],
      ),
    );
  }

  Widget _buildPortfolioValue(BuildContext context, TokenProvider tokenProvider) {
    final totalValue = tokenProvider.totalPortfolioValue;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Total Portfolio Value',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalValue.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBreakdown(BuildContext context, TokenProvider tokenProvider) {
    final portfolioByType = tokenProvider.portfolioByType;
    final totalValue = tokenProvider.totalPortfolioValue;
    
    if (portfolioByType.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...portfolioByType.entries.map((entry) {
            final type = entry.key;
            final value = entry.value;
            final percentage = totalValue > 0 ? (value / totalValue) * 100 : 0.0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PortfolioTypeCard(
                type: type,
                value: value,
                percentage: percentage,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTokenList(BuildContext context, TokenProvider tokenProvider) {
    final balances = tokenProvider.allBalances;
    final displayCount = expandable && balances.length > 3 ? 3 : balances.length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (balances.length > 3) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Top Holdings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        ...balances.take(displayCount).map((balance) => 
          _TokenBalanceTile(balance: balance)
        ),
        if (expandable && balances.length > 3)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(
              child: TextButton(
                onPressed: onViewAll,
                child: Text('View all ${balances.length} tokens'),
              ),
            ),
          ),
      ],
    );
  }
}

class _LoadingPortfolio extends StatelessWidget {
  const _LoadingPortfolio();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading portfolio...'),
          ],
        ),
      ),
    );
  }
}

class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No tokens found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your token balances will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioTypeCard extends StatelessWidget {
  final TokenType type;
  final double value;
  final double percentage;

  const _PortfolioTypeCard({
    required this.type,
    required this.value,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    Color typeColor = _getTypeColor(type);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: typeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTypeDisplayName(type),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: typeColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(typeColor),
                  minHeight: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${value.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(TokenType type) {
    switch (type) {
      case TokenType.stable:
        return const Color(0xFF10B981); // Green
      case TokenType.volatile:
        return const Color(0xFFF59E0B); // Orange
      case TokenType.synthetic:
        return const Color(0xFF8B5CF6); // Purple
      case TokenType.local:
        return const Color(0xFF06B6D4); // Cyan
    }
  }

  String _getTypeDisplayName(TokenType type) {
    switch (type) {
      case TokenType.stable:
        return 'Stable Coins';
      case TokenType.volatile:
        return 'Volatile Tokens';
      case TokenType.synthetic:
        return 'Synthetic Assets';
      case TokenType.local:
        return 'Local Currencies';
    }
  }
}

class _TokenBalanceTile extends StatelessWidget {
  final TokenBalance balance;

  const _TokenBalanceTile({required this.balance});

  @override
  Widget build(BuildContext context) {
    final token = balance.token;
    final priceChange = token.priceChange24h ?? 0.0;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
            backgroundColor: token.typeColor.withValues(alpha: 0.1),
        child: Text(
          token.symbol.substring(0, 2).toUpperCase(),
          style: TextStyle(
            color: token.typeColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              token.symbol,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            balance.balance.toStringAsFixed(6),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: token.typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    token.typeDisplayName,
                    style: TextStyle(
                      color: token.typeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (token.currentPrice != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '\$${token.currentPrice!.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (priceChange != 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      '${priceChange >= 0 ? '+' : ''}${priceChange.toStringAsFixed(2)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: priceChange >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          Text(
            '\$${balance.valueInUSD.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Standalone portfolio screen widget
class TokenPortfolioScreen extends StatelessWidget {
  const TokenPortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<TokenProvider>(context, listen: false).refresh();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TokenPortfolioWidget(
              showTitle: false,
              expandable: false,
            ),
            const SizedBox(height: 16),
            _buildTokenTypeSection(context, TokenType.stable),
            const SizedBox(height: 16),
            _buildTokenTypeSection(context, TokenType.volatile),
            const SizedBox(height: 16),
            _buildTokenTypeSection(context, TokenType.synthetic),
            const SizedBox(height: 16),
            _buildTokenTypeSection(context, TokenType.local),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenTypeSection(BuildContext context, TokenType type) {
    return Consumer<TokenProvider>(
      builder: (context, tokenProvider, child) {
        final tokens = tokenProvider.getTokensByType(type);
        if (tokens.isEmpty) return const SizedBox.shrink();

        final balances = tokens
            .map((token) => tokenProvider.getBalance(token.address))
            .where((balance) => balance != null)
            .cast<TokenBalance>()
            .toList();

        if (balances.isEmpty) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _getTypeDisplayName(type),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...balances.map((balance) => _TokenBalanceTile(balance: balance)),
            ],
          ),
        );
      },
    );
  }

  String _getTypeDisplayName(TokenType type) {
    switch (type) {
      case TokenType.stable:
        return 'Stable Coins';
      case TokenType.volatile:
        return 'Volatile Tokens';
      case TokenType.synthetic:
        return 'Synthetic Assets';
      case TokenType.local:
        return 'Local Currencies';
    }
  }
}