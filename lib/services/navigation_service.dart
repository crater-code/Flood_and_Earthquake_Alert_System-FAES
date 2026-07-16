import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/report_screen.dart';
import '../screens/community_screen.dart';
import '../screens/map_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';
import '../screens/ngo_dashboard_screen.dart';
import '../screens/ngo_report_management_screen.dart';
import '../screens/inventory_management_screen.dart';
import '../screens/location_calibration_screen.dart';
import '../screens/post_updates_screen.dart';
import '../screens/ai_chatbot_screen.dart';
import '../screens/hotline_screen.dart';
import '../screens/settings_screen.dart';
import 'api_service.dart';
import 'haptic_service.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static BuildContext? get context => navigatorKey.currentContext;

  // Route names for better navigation management
  static const String home = '/home';
  static const String report = '/report';
  static const String community = '/community';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String ngoDashboard = '/ngo-dashboard';
  static const String manageReports = '/manage-reports';
  static const String inventory = '/inventory';
  static const String locationCalibration = '/location';
  static const String postUpdates = '/post-updates';
  static const String chatbot = '/chatbot';
  static const String hotline = '/hotline';
  static const String settings = '/settings';

  // Navigation methods with error handling and haptic feedback
  static Future<T?> navigateTo<T>(String routeName, {Object? arguments}) async {
    if (context == null) return null;
    
    try {
      await HapticService.navigation();
      return await Navigator.pushNamed<T>(
        context!,
        routeName,
        arguments: arguments,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      return null;
    }
  }

  static Future<T?> navigateAndReplace<T>(String routeName, {Object? arguments}) async {
    if (context == null) return null;
    
    try {
      await HapticService.navigation();
      return await Navigator.pushReplacementNamed<T, void>(
        context!,
        routeName,
        arguments: arguments,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      return null;
    }
  }

  static Future<T?> navigateAndClearStack<T>(String routeName, {Object? arguments}) async {
    if (context == null) return null;
    
    try {
      return await Navigator.pushNamedAndRemoveUntil<T>(
        context!,
        routeName,
        (route) => false,
        arguments: arguments,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      return null;
    }
  }

  static void goBack<T>([T? result]) {
    if (context == null) return;
    
    try {
      if (Navigator.canPop(context!)) {
        Navigator.pop(context!, result);
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }

  static void popUntil(String routeName) {
    if (context == null) return;
    
    try {
      Navigator.popUntil(context!, ModalRoute.withName(routeName));
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }

  // Specific navigation helpers
  static Future<void> goToHome() => navigateAndReplace(home);
  
  static Future<void> goToLogin() => navigateAndClearStack(login);
  
  static Future<void> goToReport() => navigateTo(report);
  
  static Future<void> goToCommunity() => navigateTo(community);
  
  static Future<void> goToMap() => navigateTo(map);
  
  static Future<void> goToProfile() => navigateTo(profile);
  
  static Future<void> goToSettings() => navigateTo(settings);
  
  static Future<void> goToChatbot() => navigateTo(chatbot);
  
  static Future<void> goToHotline() => navigateTo(hotline);
  
  static Future<void> goToLocationCalibration() => navigateTo(locationCalibration);

  // NGO specific navigation
  static Future<void> goToNGODashboard() => navigateAndReplace(ngoDashboard);
  
  static Future<void> goToManageReports() => navigateTo(manageReports);
  
  static Future<void> goToInventory() => navigateTo(inventory);
  
  static Future<void> goToPostUpdates() => navigateTo(postUpdates);

  // Smart navigation based on user role
  static Future<void> goToRoleBasedHome() async {
    if (ApiService.currentRole == 'NGO') {
      await goToNGODashboard();
    } else {
      await goToHome();
    }
  }

  // Modal navigation helpers
  static Future<T?> showCustomModalBottomSheet<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? backgroundColor,
    Color? barrierColor,
  }) async {
    if (context == null) return null;
    
    return showModalBottomSheet<T>(
      context: context!,
      builder: builder,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
    );
  }

  static Future<T?> showCustomDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
  }) async {
    if (context == null) return null;
    
    return showDialog<T>(
      context: context!,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
    );
  }

  // Route generator for better route management
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final routeName = settings.name;
    
    switch (routeName) {
      case '/home':
        return _createRoute(const HomeScreen(), settings);
      case '/report':
        return _createRoute(const ReportScreen(), settings);
      case '/community':
        return _createRoute(const CommunityScreen(), settings);
      case '/map':
        return _createRoute(const MapScreen(), settings);
      case '/profile':
        return _createRoute(const ProfileScreen(), settings);
      case '/login':
        return _createRoute(const LoginScreen(), settings);
      case '/ngo-dashboard':
        return _createRoute(const NGODashboardScreen(), settings);
      case '/manage-reports':
        return _createRoute(const NGOReportManagementScreen(), settings);
      case '/inventory':
        return _createRoute(const InventoryManagementScreen(), settings);
      case '/location':
        return _createRoute(const LocationCalibrationScreen(), settings);
      case '/post-updates':
        return _createRoute(const PostUpdatesScreen(), settings);
      case '/chatbot':
        return _createRoute(const AIChatbotScreen(), settings);
      case '/hotline':
        return _createRoute(const HotlineScreen(), settings);
      case '/settings':
        return _createRoute(const SettingsScreen(), settings);
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }

  static PageRoute _createRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Breadcrumb navigation helper
  static List<String> getCurrentBreadcrumbs() {
    final List<String> breadcrumbs = [];
    
    if (context != null) {
      Navigator.of(context!).popUntil((route) {
        if (route.settings.name != null) {
          breadcrumbs.insert(0, route.settings.name!);
        }
        return route.isFirst;
      });
    }
    
    return breadcrumbs;
  }

  // Check if we can navigate back
  static bool canGoBack() {
    return context != null && Navigator.canPop(context!);
  }

  // Deep link handling
  static Future<void> handleDeepLink(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null) return;

    switch (uri.path) {
      case '/report':
        await goToReport();
        break;
      case '/community':
        await goToCommunity();
        break;
      case '/map':
        await goToMap();
        break;
      case '/profile':
        await goToProfile();
        break;
      case '/ngo-dashboard':
        if (ApiService.currentRole == 'NGO') {
          await goToNGODashboard();
        }
        break;
      default:
        await goToRoleBasedHome();
    }
  }

  // Show snackbar helper
  static void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    if (context == null) return;
    
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  // Show success message
  static void showSuccess(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
    );
  }

  // Show error message
  static void showError(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.red,
    );
  }

  // Show info message
  static void showInfo(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.blue,
    );
  }
}