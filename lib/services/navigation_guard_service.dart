import 'package:flutter/material.dart';

class NavigationGuardService {
  static final Map<String, bool> _activeOperations = {};
  static final Map<String, DateTime> _operationStartTimes = {};
  static final List<NavigatorObserver> _observers = [];

  /// Register an active operation to prevent navigation
  static void registerOperation(String operationId) {
    print('NavigationGuard: Registering operation: $operationId');
    _activeOperations[operationId] = true;
    _operationStartTimes[operationId] = DateTime.now();
  }

  /// Complete an operation and allow navigation
  static void completeOperation(String operationId) {
    print('NavigationGuard: Completing operation: $operationId');
    _activeOperations.remove(operationId);
    _operationStartTimes.remove(operationId);
  }

  /// Check if any operations are currently active
  static bool get hasActiveOperations => _activeOperations.isNotEmpty;

  /// Get list of active operations
  static List<String> get activeOperations => _activeOperations.keys.toList();

  /// Check if a specific operation is active
  static bool isOperationActive(String operationId) {
    return _activeOperations.containsKey(operationId);
  }

  /// Get operation duration
  static Duration? getOperationDuration(String operationId) {
    final startTime = _operationStartTimes[operationId];
    if (startTime == null) return null;
    return DateTime.now().difference(startTime);
  }

  /// Clear all operations (use with caution)
  static void clearAllOperations() {
    print('NavigationGuard: Clearing all operations');
    _activeOperations.clear();
    _operationStartTimes.clear();
  }

  /// Clear stale operations (older than 5 minutes)
  static void clearStaleOperations() {
    final now = DateTime.now();
    final staleOperations = <String>[];
    
    for (final entry in _operationStartTimes.entries) {
      if (now.difference(entry.value).inMinutes > 5) {
        staleOperations.add(entry.key);
      }
    }
    
    for (final operationId in staleOperations) {
      print('NavigationGuard: Clearing stale operation: $operationId');
      _activeOperations.remove(operationId);
      _operationStartTimes.remove(operationId);
    }
  }

  /// Safe navigation wrapper that checks for active operations
  static Future<T?> safeNavigate<T extends Object?>(
    BuildContext context,
    String route, {
    Object? arguments,
    String? operationId,
  }) async {
    if (hasActiveOperations && operationId != null) {
      print('NavigationGuard: Blocking navigation to $route due to active operations: $activeOperations');
      
      // Show user feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for the current operation to complete'),
          duration: Duration(seconds: 2),
        ),
      );
      return null;
    }

    try {
      if (operationId != null) {
        registerOperation(operationId);
      }
      
      final result = await Navigator.pushNamed<T>(context, route, arguments: arguments);
      
      if (operationId != null) {
        completeOperation(operationId);
      }
      
      return result;
    } catch (e) {
      print('NavigationGuard: Navigation error: $e');
      if (operationId != null) {
        completeOperation(operationId);
      }
      rethrow;
    }
  }

  /// Safe pop wrapper
  static void safePop<T extends Object?>(
    BuildContext context, [
    T? result,
    String? operationId,
  ]) {
    try {
      if (operationId != null) {
        completeOperation(operationId);
      }
      Navigator.pop<T>(context, result);
    } catch (e) {
      print('NavigationGuard: Pop error: $e');
    }
  }

  /// Initialize navigation guard system
  static void initialize() {
    // Clear stale operations periodically
    Future.delayed(const Duration(minutes: 1), () {
      clearStaleOperations();
      initialize(); // Recursive call for periodic cleanup
    });
  }
}

/// Custom Navigator Observer to track navigation events
class NavigationGuardObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('NavigationGuard: Route pushed: ${route.settings.name}');
    
    // Check if navigation should be blocked
    if (NavigationGuardService.hasActiveOperations) {
      print('NavigationGuard: Navigation occurred with active operations: ${NavigationGuardService.activeOperations}');
    }
    
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('NavigationGuard: Route popped: ${route.settings.name}');
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    print('NavigationGuard: Route replaced: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('NavigationGuard: Route removed: ${route.settings.name}');
    super.didRemove(route, previousRoute);
  }
}

/// Mixin for widgets that perform operations requiring navigation protection
mixin NavigationGuardMixin<T extends StatefulWidget> on State<T> {
  String get operationId => '${widget.runtimeType}_${hashCode}';
  bool _operationInProgress = false;

  /// Start a protected operation
  void startProtectedOperation(String operationName) {
    if (_operationInProgress) {
      print('NavigationGuard: Operation $operationName already in progress for $operationId');
      return;
    }
    
    print('NavigationGuard: Starting protected operation: $operationName for $operationId');
    _operationInProgress = true;
    NavigationGuardService.registerOperation('${operationId}_$operationName');
  }

  /// Complete a protected operation
  void completeProtectedOperation(String operationName) {
    if (!_operationInProgress) {
      print('NavigationGuard: No operation in progress for $operationId');
      return;
    }
    
    print('NavigationGuard: Completing protected operation: $operationName for $operationId');
    _operationInProgress = false;
    NavigationGuardService.completeOperation('${operationId}_$operationName');
  }

  /// Check if operation is in progress
  bool get isOperationInProgress => _operationInProgress;

  @override
  void dispose() {
    // Clean up any remaining operations
    if (_operationInProgress) {
      NavigationGuardService.clearAllOperations();
    }
    super.dispose();
  }
}