import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/receipt_scanner_screen.dart';
import '../screens/receipt_history_screen.dart';
import '../screens/wallet/send_money_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/wallet/request_money_screen.dart';
import '../screens/shop/order_tracking_screen.dart';
import '../screens/shop/shop_notifications_screen.dart';
import '../models/shop_models.dart'; // Import for Order model
import '../screens/profile/profile_main.dart'; // Import for Profile section
import '../screens/api_test_screen.dart'; // Import for API test screen

// Import loading and onboarding screens with aliases
import '../screens/loading_screen_new.dart' as new_loading;
import '../screens/onboarding_screen_new.dart' as new_onboarding;
import '../screens/auth/signin_screen_new.dart' as new_signin;
import '../screens/auth/signup_screen_new.dart' as new_signup;

/// Class that handles all the app routes
class AppRoutes {
  static const String shopFilters = '/shop/filters';
  static const String favoriteShops = '/shop/favorites';
  static const String shopReviews = '/shop/reviews';
  static const String orderTracking = '/shop/order-tracking';
  static const String shopNotifications = '/shop/notifications';
  static const String profile = '/profile';
  static const String apiTest = '/api-test';
  static const String receiptHistory = '/receipt_history';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/loading':
        return MaterialPageRoute(builder: (_) => const new_loading.LoadingScreen());
      
      case '/onboarding':
        return MaterialPageRoute(
          builder: (context) => new_onboarding.OnboardingScreen(
            onFinish: () => Navigator.of(context).pushReplacementNamed('/signin'),
          ),
        );
      
      case '/signin':
        return MaterialPageRoute(builder: (_) => const new_signin.SignInScreen());
      
      case '/signup':
        return MaterialPageRoute(builder: (_) => const new_signup.SignUpScreen());
      
      case AppRoutes.orderTracking:
        // For OrderTrackingScreen, we need to handle the order parameter at runtime
        // Check if arguments is of type Order, otherwise handle the error
        if (settings.arguments is Order) {
          return MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(order: settings.arguments as Order),
          );
        } else {
          // Handle the case where arguments is not an Order
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid order data')),
            ),
          );
        }
        
      case AppRoutes.shopNotifications:
        return MaterialPageRoute(
          builder: (_) => const ShopNotificationPage(),
        );
      
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case '/receipt-scanner':
        return MaterialPageRoute(builder: (_) => const ReceiptScannerScreen());
        
      case AppRoutes.receiptHistory:
        return MaterialPageRoute(builder: (_) => const ReceiptHistoryScreen());
      
      case '/statistics':
        return MaterialPageRoute(builder: (_) => const StatisticsScreen());
        
      case '/send-money':
        return MaterialPageRoute(
          builder: (_) => const SendMoneyScreen(),
        );
      
      case '/request-money':
        return MaterialPageRoute(
          builder: (_) => const RequestMoneyScreen(),
        );
      
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileMain(),
        );
      
      case AppRoutes.apiTest:
        return MaterialPageRoute(
          builder: (_) => const ApiTestScreen(),
        );
      
      default:
        // If the route is not found, show a 404 page
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(
              child: Text('The requested page was not found.'),
            ),
          ),
        );
    }
  }
}

// Define TransactionType enum for use in routes
enum TransactionType { income, expense }

// AddTransactionScreen placeholder for route handling
class AddTransactionScreen extends StatelessWidget {
  final bool isIncome;
  
  const AddTransactionScreen({Key? key, required this.isIncome}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isIncome ? 'Add Income' : 'Add Expense'),
      ),
      body: Center(
        child: Text('Add ${isIncome ? 'Income' : 'Expense'} Screen'),
      ),
    );
  }
}
