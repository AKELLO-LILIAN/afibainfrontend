import 'package:flutter/material.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool isLoading;
  
  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Something went wrong',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getUserFriendlyError(error),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onRetry != null || onDismiss != null) ...[ 
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDismiss != null)
                  TextButton(
                    onPressed: onDismiss,
                    child: Text(
                      'Dismiss',
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                  ),
                if (onRetry != null) ...[ 
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoading ? null : onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Retry'),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  String _getUserFriendlyError(String error) {
    final lowerError = error.toLowerCase();
    
    if (lowerError.contains('timeout')) {
      return 'Connection timed out. Please check your internet connection and try again.';
    }
    
    if (lowerError.contains('rpc') || lowerError.contains('infura')) {
      return 'Unable to connect to blockchain network. Please try again later.';
    }
    
    if (lowerError.contains('balance')) {
      return 'Unable to fetch your token balances. Please try again.';
    }
    
    if (lowerError.contains('token')) {
      return 'Unable to load token information. Please try again.';
    }
    
    if (lowerError.contains('conversion') || lowerError.contains('quote')) {
      return 'Unable to get conversion rates. Please try again.';
    }
    
    if (lowerError.contains('network')) {
      return 'Network error. Please check your connection and try again.';
    }
    
    // For other errors, return a generic message but preserve some context
    if (error.length > 100) {
      return 'An unexpected error occurred. Please try again.';
    }
    
    return error;
  }
}

class LoadingStateWidget extends StatelessWidget {
  final String message;
  final Widget? child;
  
  const LoadingStateWidget({
    super.key,
    required this.message,
    this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (child != null) ...[ 
            const SizedBox(height: 16),
            child!,
          ],
        ],
      ),
    );
  }
}