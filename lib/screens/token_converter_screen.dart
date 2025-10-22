import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/token.dart';
import '../providers/token_provider.dart';
import '../widgets/token_selector.dart';
import '../services/navigation_guard_service.dart';

class TokenConverterScreen extends StatefulWidget {
  final Token? fromToken;
  final Token? toToken;
  
  const TokenConverterScreen({
    super.key,
    this.fromToken,
    this.toToken,
  });

  @override
  State<TokenConverterScreen> createState() => _TokenConverterScreenState();
}

class _TokenConverterScreenState extends State<TokenConverterScreen> 
    with NavigationGuardMixin {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    
    print('TokenConverterScreen: initState called with fromToken: ${widget.fromToken?.symbol}, toToken: ${widget.toToken?.symbol}');
    
    // Initialize token provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      try {
        final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
        print('TokenConverterScreen: Token count before init: ${tokenProvider.allTokens.length}');
        
        if (tokenProvider.allTokens.isEmpty) {
          print('TokenConverterScreen: Initializing token provider...');
          await tokenProvider.initialize();
          print('TokenConverterScreen: Token count after init: ${tokenProvider.allTokens.length}');
          
          if (tokenProvider.error != null) {
            print('TokenConverterScreen: Error during initialization: ${tokenProvider.error}');
          }
        } else {
          print('TokenConverterScreen: Tokens already loaded');
        }
        
        // Set initial tokens if provided
        if (mounted && widget.fromToken != null) {
          print('TokenConverterScreen: Setting initial from token: ${widget.fromToken!.symbol}');
          tokenProvider.selectFromToken(widget.fromToken!);
        }
        
        if (mounted && widget.toToken != null) {
          print('TokenConverterScreen: Setting initial to token: ${widget.toToken!.symbol}');
          tokenProvider.selectToToken(widget.toToken!);
        }
      } catch (e) {
        print('TokenConverterScreen: Exception in initState: $e');
      }
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final text = _amountController.text;
    final amount = double.tryParse(text) ?? 0.0;
    
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    tokenProvider.setConversionAmount(amount);
  }

  Future<void> _selectFromToken() async {
    if (isOperationInProgress) {
      print('TokenConverterScreen: Operation already in progress, skipping token selection');
      return;
    }
    
    startProtectedOperation('selectFromToken');
    
    try {
      print('TokenConverterScreen: _selectFromToken called');
      
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      
      // Check if tokens are loaded
      if (tokenProvider.allTokens.isEmpty) {
        print('TokenConverterScreen: No tokens available for selection');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading tokens, please wait...'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      
      print('TokenConverterScreen: Showing token selector with ${tokenProvider.allTokens.length} tokens');
      
      final token = await showTokenSelector(
        context: context,
        title: 'Select Token to Convert',
        selectedToken: tokenProvider.selectedFromToken,
        showBalance: true,
      );

      if (!mounted) return;

      if (token != null) {
        print('TokenConverterScreen: Selected from token: ${token.symbol}');
        tokenProvider.selectFromToken(token);
      } else {
        print('TokenConverterScreen: No token selected');
      }
    } catch (e, stackTrace) {
      print('TokenConverterScreen: Error in _selectFromToken: $e');
      print('TokenConverterScreen: Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting token: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      completeProtectedOperation('selectFromToken');
    }
  }

  Future<void> _selectToToken() async {
    if (isOperationInProgress) {
      print('TokenConverterScreen: Operation already in progress, skipping to token selection');
      return;
    }
    
    startProtectedOperation('selectToToken');
    
    try {
      print('TokenConverterScreen: _selectToToken called');
      
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      
      // Check if tokens are loaded
      if (tokenProvider.allTokens.isEmpty) {
        print('TokenConverterScreen: No tokens available for selection (to token)');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading tokens, please wait...'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      
      print('TokenConverterScreen: Showing to token selector with ${tokenProvider.allTokens.length} tokens');
      
      final token = await showTokenSelector(
        context: context,
        title: 'Select Token to Receive',
        selectedToken: tokenProvider.selectedToToken,
        showBalance: false,
      );

      if (!mounted) return;

      if (token != null) {
        print('TokenConverterScreen: Selected to token: ${token.symbol}');
        tokenProvider.selectToToken(token);
      } else {
        print('TokenConverterScreen: No to token selected');
      }
    } catch (e, stackTrace) {
      print('TokenConverterScreen: Error in _selectToToken: $e');
      print('TokenConverterScreen: Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting token: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      completeProtectedOperation('selectToToken');
    }
  }

  void _swapTokens() {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    tokenProvider.swapTokens();
  }

  void _setMaxAmount() {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    if (tokenProvider.selectedFromToken != null) {
      final balance = tokenProvider.getBalance(tokenProvider.selectedFromToken!.address);
      if (balance != null) {
        _amountController.text = balance.balance.toString();
        tokenProvider.setConversionAmount(balance.balance);
      }
    }
  }

  void _showSlippageSettings() {
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SlippageSettingsSheet(
        currentSlippage: tokenProvider.slippageTolerance,
        onSlippageChanged: (slippage) {
          tokenProvider.setSlippageTolerance(slippage);
        },
      ),
    );
  }

  Future<void> _executeConversion() async {
    if (isOperationInProgress) {
      print('TokenConverterScreen: Conversion already in progress');
      return;
    }
    
    startProtectedOperation('executeConversion');
    
    try {
      print('TokenConverterScreen: _executeConversion called');
      
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      
      if (!mounted) {
        print('TokenConverterScreen: Widget not mounted during conversion, aborting');
        return;
      }
      
      print('TokenConverterScreen: About to call tokenProvider.executeConversion()');
      print('TokenConverterScreen: From token: ${tokenProvider.selectedFromToken?.symbol}');
      print('TokenConverterScreen: To token: ${tokenProvider.selectedToToken?.symbol}');
      print('TokenConverterScreen: Amount: ${tokenProvider.conversionAmount}');
      
      await tokenProvider.executeConversion();
      
      print('TokenConverterScreen: Conversion completed successfully');
      
      if (mounted) {
        print('TokenConverterScreen: Widget still mounted after conversion, showing success message');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conversion successful!'),
            backgroundColor: Colors.green,
          ),
        );
        _amountController.clear();
      } else {
        print('TokenConverterScreen: Widget no longer mounted after conversion');
      }
    } catch (e, stackTrace) {
      print('TokenConverterScreen: Conversion failed with error: $e');
      print('TokenConverterScreen: Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conversion failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        print('TokenConverterScreen: Widget not mounted during error handling');
      }
    } finally {
      completeProtectedOperation('executeConversion');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSlippageSettings,
          ),
        ],
      ),
      body: Consumer<TokenProvider>(
        builder: (context, tokenProvider, child) {
          if (tokenProvider.isLoadingTokens) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // From Token Section
                _buildTokenSection(
                  title: 'From',
                  token: tokenProvider.selectedFromToken,
                  onTap: _selectFromToken,
                  showBalance: true,
                  tokenProvider: tokenProvider,
                ),
                
                const SizedBox(height: 8),
                
                // Swap Button
                Center(
                  child: GestureDetector(
                    onTap: _swapTokens,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.swap_vert,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // To Token Section
                _buildTokenSection(
                  title: 'To',
                  token: tokenProvider.selectedToToken,
                  onTap: _selectToToken,
                  showBalance: false,
                  tokenProvider: tokenProvider,
                ),
                
                const SizedBox(height: 24),
                
                // Amount Input
                _buildAmountInput(tokenProvider),
                
                const SizedBox(height: 24),
                
                // Conversion Quote
                if (tokenProvider.currentQuote != null)
                  _buildQuoteCard(tokenProvider.currentQuote!),
                
                if (tokenProvider.isLoadingQuote)
                  const Center(child: CircularProgressIndicator()),
                
                const SizedBox(height: 24),
                
                // Convert Button
                _buildConvertButton(tokenProvider),
                
                if (tokenProvider.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tokenProvider.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: tokenProvider.clearError,
                          child: const Text('Dismiss'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTokenSection({
    required String title,
    required Token? token,
    required VoidCallback onTap,
    required bool showBalance,
    required TokenProvider tokenProvider,
  }) {
    final balance = token != null ? tokenProvider.getBalance(token.address) : null;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (showBalance && balance != null)
                    Text(
                      'Balance: ${balance.balance.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (token != null) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: token.typeColor.withValues(alpha: 0.1),
                      child: Text(
                        token.symbol.substring(0, 2).toUpperCase(),
                        style: TextStyle(
                          color: token.typeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            token.symbol,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            token.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: token.typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    token.typeDisplayName,
                    style: TextStyle(
                      color: token.typeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Select Token',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(TokenProvider tokenProvider) {
    final fromToken = tokenProvider.selectedFromToken;
    final balance = fromToken != null ? tokenProvider.getBalance(fromToken.address) : null;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Amount',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (balance != null)
                  TextButton(
                    onPressed: _setMaxAmount,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('MAX'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              focusNode: _amountFocus,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: Theme.of(context).textTheme.headlineMedium,
              decoration: InputDecoration(
                hintText: '0.0',
                border: InputBorder.none,
                suffix: fromToken != null 
                    ? Text(
                        fromToken.symbol,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(ConversionQuote quote) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conversion Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Output Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'You will receive',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${quote.amountOut.toStringAsFixed(6)} ${quote.toToken.symbol}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Exchange Rate
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Exchange Rate'),
                Text(
                  '1 ${quote.fromToken.symbol} = ${quote.exchangeRate.toStringAsFixed(6)} ${quote.toToken.symbol}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Fee
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fee'),
                Text(
                  '${quote.fee.toStringAsFixed(6)} ${quote.toToken.symbol}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Price Impact
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Price Impact'),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: quote.priceImpactColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        quote.priceImpactLevel,
                        style: TextStyle(
                          color: quote.priceImpactColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${quote.priceImpact.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: quote.priceImpactColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Warning for high price impact
            if (quote.hasHighPriceImpact)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'High price impact. You may receive less than expected.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Quote expiry
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Quote expires in ${quote.validUntil.difference(DateTime.now()).inSeconds}s',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConvertButton(TokenProvider tokenProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: tokenProvider.canConvert && !tokenProvider.isConverting
            ? _executeConversion
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: tokenProvider.isConverting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                _getButtonText(tokenProvider),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  String _getButtonText(TokenProvider tokenProvider) {
    if (tokenProvider.selectedFromToken == null) return 'Select Token to Convert';
    if (tokenProvider.selectedToToken == null) return 'Select Token to Receive';
    if (tokenProvider.conversionAmount <= 0) return 'Enter Amount';
    if (tokenProvider.currentQuote == null) return 'Getting Quote...';
    if (tokenProvider.currentQuote!.isExpired) return 'Quote Expired - Refresh';
    return 'Convert Tokens';
  }
}

class _SlippageSettingsSheet extends StatefulWidget {
  final double currentSlippage;
  final Function(double) onSlippageChanged;

  const _SlippageSettingsSheet({
    required this.currentSlippage,
    required this.onSlippageChanged,
  });

  @override
  State<_SlippageSettingsSheet> createState() => _SlippageSettingsSheetState();
}

class _SlippageSettingsSheetState extends State<_SlippageSettingsSheet> {
  late double _slippage;
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _slippage = widget.currentSlippage;
    _customController.text = _slippage.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Slippage Tolerance',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Set the maximum slippage you\'re willing to accept',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Preset buttons
          Row(
            children: [0.5, 1.0, 3.0].map((preset) => 
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${preset.toStringAsFixed(1)}%'),
                    selected: _slippage == preset,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _slippage = preset;
                          _customController.text = preset.toString();
                        });
                      }
                    },
                  ),
                ),
              ),
            ).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Custom input
          TextField(
            controller: _customController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Custom (%)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixText: '%',
            ),
            onChanged: (value) {
              final customSlippage = double.tryParse(value);
              if (customSlippage != null && customSlippage >= 0 && customSlippage <= 50) {
                setState(() {
                  _slippage = customSlippage;
                });
              }
            },
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSlippageChanged(_slippage);
                Navigator.pop(context);
              },
              child: const Text('Apply Settings'),
            ),
          ),
        ],
      ),
    );
  }
}