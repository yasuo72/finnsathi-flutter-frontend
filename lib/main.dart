// Finsaathi Multi App - Custom Sign Up Screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'services/theme_service.dart';
import 'services/navigation_service.dart';
import 'routing/app_routes.dart';
// These screens are imported in their respective parent screens
import 'services/finance_service.dart';
import 'services/ai_chat_service.dart';
import 'services/wallet_service.dart';
import 'services/profile_service.dart';
import 'services/gamification_service.dart';
// API services for backend integration
import 'providers/api_providers.dart';
import 'services/api_service_manager.dart';
import 'app_config.dart';

// Define color constants for consistent usage
const Color kPrimaryColor = Color(0xFF3F51B5); // Indigo for primary actions
const Color kSecondaryColor = Color(
  0xFF7986CB,
); // Lighter indigo for secondary elements
const Color kAccentColor = Color(
  0xFF4CAF50,
); // Green for accents and success states
const Color kErrorColor = Color(0xFFE57373); // Soft red for errors

// Light theme colors
const Color kLightBackground = Color(0xFFF5F7FA); // Soft off-white background
const Color kLightSurface = Colors.white; // White surface
const Color kLightText = Color(0xFF424242); // Dark grey for text
const Color kLightSecondaryText = Color(
  0xFF757575,
); // Medium grey for secondary text

// Dark theme colors
const Color kDarkBackground = Color(0xFF121212); // Material dark background
const Color kDarkSurface = Color(0xFF1E1E1E); // Slightly lighter surface
const Color kDarkCardColor = Color(0xFF252525); // Card color for dark mode
const Color kDarkText = Color(0xFFEEEEEE); // Off-white for text
const Color kDarkSecondaryText = Color(
  0xFFB0B0B0,
); // Light grey for secondary text

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kPrimaryColor,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: kLightBackground,
  cardColor: kLightSurface,
  shadowColor: Colors.black.withOpacity(0.1),
  dividerColor: Colors.grey.shade200,
  appBarTheme: const AppBarTheme(
    backgroundColor: kLightSurface,
    elevation: 0,
    iconTheme: IconThemeData(color: kLightText),
    titleTextStyle: TextStyle(
      color: kLightText,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: kLightSurface,
    selectedItemColor: kPrimaryColor,
    unselectedItemColor: Colors.grey.shade600,
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
    elevation: 8,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: kLightText),
    bodyMedium: TextStyle(color: kLightText),
    titleLarge: TextStyle(color: kLightText, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: kLightText, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(color: kLightSecondaryText),
    labelLarge: TextStyle(color: kLightText),
  ),
  colorScheme: const ColorScheme.light(
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    tertiary: kAccentColor,
    surface: kLightSurface,
    background: kLightBackground,
    error: kErrorColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: kLightText,
    onBackground: kLightText,
    onError: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kPrimaryColor),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kPrimaryColor,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: kDarkBackground,
  cardColor: kDarkCardColor,
  shadowColor: Colors.black.withOpacity(0.3),
  dividerColor: Colors.grey.shade800,
  appBarTheme: const AppBarTheme(
    backgroundColor: kDarkSurface,
    elevation: 0,
    iconTheme: IconThemeData(color: kDarkText),
    titleTextStyle: TextStyle(
      color: kDarkText,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: kDarkSurface,
    selectedItemColor: kSecondaryColor,
    unselectedItemColor: Colors.grey,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
    elevation: 8,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: kDarkText),
    bodyMedium: TextStyle(color: kDarkText),
    titleLarge: TextStyle(color: kDarkText, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: kDarkText, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(color: kDarkSecondaryText),
    labelLarge: TextStyle(color: kDarkText),
  ),
  colorScheme: const ColorScheme.dark(
    primary: kSecondaryColor, // Using a lighter shade for dark mode
    secondary: kPrimaryColor,
    tertiary: kAccentColor,
    surface: kDarkSurface,
    background: kDarkBackground,
    error: kErrorColor,
    onPrimary: kDarkText,
    onSecondary: kDarkText,
    onSurface: kDarkText,
    onBackground: kDarkText,
    onError: kDarkText,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kSecondaryColor,
      foregroundColor: kDarkText,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kDarkSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade800),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kSecondaryColor),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: const TextStyle(color: kDarkSecondaryText),
    hintStyle: const TextStyle(color: kDarkSecondaryText),
  ),
);

Future<void> main() async {
  // Ensure Flutter is initialized before doing anything else
  WidgetsFlutterBinding.ensureInitialized();
  
  // For stability, set preferred orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Add some delay to initialize properly
  await Future.delayed(const Duration(milliseconds: 200));
  
  // Load environment variables
  await dotenv.load();
  
  // Initialize AppConfig
  await AppConfig.initialize();
  
  // Use real API data to connect with Railway backend
  if (AppConfig.useMockData) {
    await AppConfig.setUseMockData(false);
  }

  // Initialize FinanceService
  final financeService = FinanceService();
  await financeService.init();

  // Initialize ThemeService
  final themeService = ThemeService();
  await themeService.init();

  // Initialize WalletService
  final walletService = WalletService();
  
  // Initialize ProfileService
  final profileService = ProfileService();
  
  // Initialize API Service Manager
  final apiServiceManager = ApiServiceManager();
  // Don't await this as it will be initialized when needed

  // Run the app with error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
    // In production, you might want to log to a service
  };

  runApp(
    MultiProvider(
      providers: [
        // Core app services
        ChangeNotifierProvider<FinanceService>(
          create: (context) => financeService,
        ),
        ChangeNotifierProvider<ThemeService>(create: (context) => themeService),
        // Create AIChatService with the finance service instance
        ProxyProvider<FinanceService, AIChatService>(
          update: (context, financeService, previous) => 
              previous ?? AIChatService(financeService),
        ),
        // Add WalletService for card and cash management
        ChangeNotifierProxyProvider<FinanceService, WalletService>(
          create: (_) => walletService,
          update: (_, financeService, walletService) {
            walletService?.setFinanceService(financeService);
            return walletService!;
          },
        ),
        // Add ProfileService for user profile management
        ChangeNotifierProvider<ProfileService>(
          create: (context) => profileService,
        ),
        // Add Navigation Service for app-wide navigation
        Provider<NavigationService>(
          create: (context) => NavigationService(),
        ),
        // Add GamificationService for gamification features
        ChangeNotifierProvider<GamificationService>(
          create: (context) {
            final profileService = Provider.of<ProfileService>(context, listen: false);
            final financeService = Provider.of<FinanceService>(context, listen: false);
            return GamificationService(profileService, financeService);
          },
        ),
        // Add API service providers for backend integration
        ChangeNotifierProvider<ApiServiceManager>(
          create: (context) => apiServiceManager,
        ),
        // Include all API-related providers
        ...getApiProviders(),
      ],
      child: const FinsaathiApp(),
    ),
  );
}

class FinsaathiApp extends StatefulWidget {
  const FinsaathiApp({super.key});

  @override
  FinsaathiAppState createState() => FinsaathiAppState();
}

class FinsaathiAppState extends State<FinsaathiApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Pre-warm image cache to avoid stutters
    PaintingBinding.instance.imageCache.maximumSize = 100;
    
    // Initialize API services
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize API Service Manager after the first frame
      Provider.of<ApiServiceManager>(context, listen: false).initializeData();
      
      // Show notification about mock data mode if enabled
      if (AppConfig.useMockData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'App is running in offline mode due to backend server issues. Your data will not be saved to the cloud.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange.shade800,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes to improve stability
    if (state == AppLifecycleState.resumed) {
      // Clear caches when app is resumed to free up memory
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    }
  }
  @override
  Widget build(BuildContext context) {
    // Get ThemeService instance from provider
    final themeService = Provider.of<ThemeService>(context);
    final navigationService = Provider.of<NavigationService>(context, listen: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finsaathi Multi',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // Add navigation key from service
      navigatorKey: navigationService.navigatorKey,
      // Reduce animations slightly to avoid OpenGL issues
      builder: (context, child) {
        // Apply a global configuration to images to prevent OpenGL issues
        return MediaQuery(
          // Set a safer text scale factor
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      initialRoute: '/splash',
      // Use the onGenerateRoute to handle app routes
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscure;
  const CustomTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Color(0xFF4866FF)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF4866FF)),
        ),
      ),
    );
  }
}
