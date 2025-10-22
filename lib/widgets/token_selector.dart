import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/token.dart';
import '../providers/token_provider.dart';

class TokenSelector extends StatefulWidget {
  final String title;
  final Token? selectedToken;
  final List<TokenType>? filterTypes;
  final Function(Token) onTokenSelected;
  final bool showBalance;

  const TokenSelector({
    super.key,
    required this.title,
    this.selectedToken,
    this.filterTypes,
    required this.onTokenSelected,
    this.showBalance = true,
  });

  @override
  State<TokenSelector> createState() => _TokenSelectorState();
}

class _TokenSelectorState extends State<TokenSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<Token> _filteredTokens = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterTokens);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTokens);
    _searchController.dispose();
    super.dispose();
  }

  void _filterTokens() {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    final query = _searchController.text;
    
    List<Token> tokens;
    if (widget.filterTypes != null && widget.filterTypes!.isNotEmpty) {
      tokens = [];
      for (final type in widget.filterTypes!) {
        tokens.addAll(tokenProvider.getTokensByType(type));
      }
    } else {
      tokens = tokenProvider.allTokens;
    }
    
    setState(() {
      _filteredTokens = query.isEmpty 
          ? tokens 
          : tokens.where((token) =>
              token.symbol.toLowerCase().contains(query.toLowerCase()) ||
              token.name.toLowerCase().contains(query.toLowerCase())
            ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TokenProvider>(
      builder: (context, tokenProvider, child) {
        // Initialize filtered tokens if empty
        if (_filteredTokens.isEmpty && _searchController.text.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _filterTokens();
          });
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tokens...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Token type filters (if not pre-filtered)
              if (widget.filterTypes == null)
                _buildTypeFilters(tokenProvider),
              
              // Token list
              Flexible(
                child: _filteredTokens.isEmpty
                    ? _buildEmptyState()
                    : _buildTokenList(tokenProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeFilters(TokenProvider tokenProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: TokenType.values.map((type) {
          final tokens = tokenProvider.getTokensByType(type);
          if (tokens.isEmpty) return const SizedBox.shrink();
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type.name.toUpperCase()),
              selected: false,
              onSelected: (selected) {
                // Filter by this type
                _searchController.clear();
                setState(() {
                  _filteredTokens = tokens;
                });
              },
              backgroundColor: type == TokenType.stable 
                  ? Colors.green.withValues(alpha: 0.1)
                  : type == TokenType.volatile
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.purple.withValues(alpha: 0.1),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
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
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenList(TokenProvider tokenProvider) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _filteredTokens.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
      ),
      itemBuilder: (context, index) {
        final token = _filteredTokens[index];
        final balance = tokenProvider.getBalance(token.address);
        final isSelected = widget.selectedToken?.address == token.address;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              if (widget.showBalance && balance != null) ...[
                Text(
                  balance.balance.toStringAsFixed(6),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                token.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: token.typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
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
                  ],
                  if (token.priceChange24h != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '${token.priceChange24h! >= 0 ? '+' : ''}${token.priceChange24h!.toStringAsFixed(2)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: token.priceChange24h! >= 0 
                            ? Colors.green 
                            : Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
              : Icon(
                  Icons.radio_button_unchecked,
                  color: Theme.of(context).colorScheme.outline,
                ),
          onTap: () {
            try {
              print('TokenSelector: Token selected: ${token.symbol}');
              
              if (!context.mounted) {
                print('TokenSelector: Context not mounted, aborting selection');
                return;
              }
              
              // Just navigate back with the token - let the caller handle the selection
              Navigator.of(context).pop(token);
              
              print('TokenSelector: Successfully returned token');
            } catch (e, stackTrace) {
              print('TokenSelector: Error during token selection: $e');
              print('TokenSelector: Stack trace: $stackTrace');
              
              // Try to close the modal anyway
              if (context.mounted) {
                try {
                  Navigator.of(context).pop();
                } catch (navError) {
                  print('TokenSelector: Failed to close modal: $navError');
                }
              }
            }
          },
        );
      },
    );
  }
}

// Helper function to show token selector modal
Future<Token?> showTokenSelector({
  required BuildContext context,
  required String title,
  Token? selectedToken,
  List<TokenType>? filterTypes,
  bool showBalance = true,
}) {
  print('showTokenSelector: Called with title: $title');
  
  // Check if the context is still valid
  if (!context.mounted) {
    print('showTokenSelector: Context not mounted, returning null');
    return Future.value(null);
  }
  
  try {
    return showModalBottomSheet<Token?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => TokenSelector(
          title: title,
          selectedToken: selectedToken,
          filterTypes: filterTypes,
          showBalance: showBalance,
          onTokenSelected: (token) {
            print('showTokenSelector: onTokenSelected called with: ${token.symbol}');
            return Navigator.of(context).pop(token);
          },
        ),
      ),
    ).catchError((error) {
      print('showTokenSelector: Error showing modal: $error');
      return null;
    });
  } catch (e) {
    print('showTokenSelector: Exception: $e');
    return Future.value(null);
  }
}
