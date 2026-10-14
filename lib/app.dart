// lib/app.dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/report_screen.dart';
import 'screens/community_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/ngo_dashboard_screen.dart';
import 'screens/ngo_report_management_screen.dart';
import 'screens/inventory_management_screen.dart';
import 'screens/location_calibration_screen.dart';
import 'screens/post_updates_screen.dart';
import 'screens/user_posts_screen.dart';
import 'screens/ai_chatbot_screen.dart';
import 'screens/hotline_screen.dart';
import 'screens/settings_screen.dart';
import 'services/api_service.dart';
import 'services/navigation_service.dart';
import 'widgets/expandable_bottom_nav.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Emergency Response System',
      theme: AppTheme.light(),
      navigatorKey: NavigationService.navigatorKey,
      onGenerateRoute: NavigationService.generateRoute,
      home: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String _currentRoute = '';
  bool _isNavigating = false; // Mutex to prevent double navigation

  @override
  void initState() {
    super.initState();
    _setInitialRoute();
  }

  void _setInitialRoute() {
    if (!ApiService.isLoggedIn) {
      _currentRoute = 'login';
    } else if (ApiService.currentRole == 'NGO') {
      _currentRoute = 'ngo_dashboard';
    } else {
      _currentRoute = 'home';
    }
  }

  void _handleLogout() {
    setState(() {
      _currentRoute = 'login';
      _isNavigating = false;
    });
  }

  void _onNavigate(String route) {
    // Special handling for login - reset navigation flag
    if (route == 'login') {
      _isNavigating = false;
    }
    
    // Prevent navigating to same route or double navigation
    if (_currentRoute == route || _isNavigating) return;
    
    _isNavigating = true;
    
    setState(() {
      _currentRoute = route;
    });
    
    // Reset the navigation flag after a short delay to allow state to settle
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _isNavigating = false;
      }
    });
  }

  Widget _getCurrentScreen() {
    switch (_currentRoute) {
      case 'login':
        return LoginScreen(onLogin: () {
          // Small delay to ensure ApiService state is fully updated
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                _isNavigating = false; // Reset navigation flag
                _currentRoute = ApiService.currentRole == 'NGO' ? 'ngo_dashboard' : 'home';
              });
            }
          });
        });
      
      // Citizen screens
      case 'home':
        return HomeScreen(onNavigate: _onNavigate);
      case 'report':
        return const ReportScreen();
      case 'map':
        return const MapScreen();
      case 'my_posts':
        return const UserPostsScreen();
      case 'chatbot':
        return const AIChatbotScreen();
      case 'location':
        return const LocationCalibrationScreen();
      case 'hotline':
        return const HotlineScreen();
      case 'settings':
        return const SettingsScreen();
      case 'profile':
        return const ProfileScreen();
      
      // NGO screens
      case 'ngo_dashboard':
        return const NGODashboardScreen();
      case 'manage_reports':
        return const NGOReportManagementScreen();
      case 'inventory':
        return const InventoryManagementScreen();
      case 'post_updates':
        return const PostUpdatesScreen();
      case 'community':
        return const CommunityScreen();
      case 'heatmaps':
        return const MapScreen(); // Placeholder for heatmaps
      
      default:
        return LoginScreen(onLogin: () {
          setState(() {
            _currentRoute = ApiService.currentRole == 'NGO' ? 'ngo_dashboard' : 'home';
          });
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ApiService.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: _getCurrentScreen(),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            bottom: 76,
            child: _getCurrentScreen(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ExpandableBottomNav(
              onNavigate: _onNavigate,
              currentRoute: _currentRoute,
            ),
          ),
        ],
      ),
    );
  }
}
