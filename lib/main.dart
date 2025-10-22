import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/wallet_connect_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/merchant_screen.dart';
import 'screens/salary_screen.dart';
import 'providers/wallet_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/token_provider.dart';
import 'screens/token_converter_screen.dart';
import 'screens/deposit_screen.dart';
import 'widgets/token_portfolio_widget.dart';
import 'services/navigation_guard_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Add global error handler to prevent crashes
  FlutterError.onError = (FlutterErrorDetails details) {
    print('Flutter Error: ${details.exception}');
    print('Stack Trace: ${details.stack}');
    
    // Don't crash the app, just log the error
    FlutterError.presentError(details);
  };
  
  // Initialize navigation guard system
  NavigationGuardService.initialize();
  
  runApp(const AfriBainApp());
}

class AfriBainApp extends StatelessWidget {
  const AfriBainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => TokenProvider()),
      ],
      child: MaterialApp(
        title: 'AfriBain',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/splash',
        navigatorObservers: [NavigationGuardObserver()],
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/': (context) => const HomeScreen(),
          '/wallet_connect': (context) => const WalletConnectScreen(),
          '/payment': (context) => const PaymentScreen(),
          '/merchant': (context) => const MerchantScreen(),
          '/salary': (context) => const SalaryScreen(),
          '/token_converter': (context) => const TokenConverterScreen(),
          '/token_portfolio': (context) => const TokenPortfolioScreen(),
          '/deposit': (context) => const DepositScreen(),
        },
      ),
    );
  }
}
