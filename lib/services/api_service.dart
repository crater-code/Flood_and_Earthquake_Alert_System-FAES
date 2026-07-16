import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// COMPLETELY MOCK API SERVICE - ZERO NETWORK CALLS
/// All data is handled locally for demo purposes
class ApiService {
  // In-memory authentication state
  static String? _accessToken;
  static String? _refreshToken;
  static Map<String, dynamic>? _currentUser;
  
  // Mock data storage (in-memory)
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'name': 'Demo Citizen',
      'email': 'citizen@demo.com',
      'password': 'demo123',
      'number': '+92-300-1234567',
      'role': 'CITIZEN',
      'createdAt': '2024-01-01T00:00:00Z',
    },
    {
      'id': '2', 
      'name': 'Demo NGO Organization',
      'email': 'ngo@demo.com',
      'password': 'demo123',
      'number': '+92-321-7654321',
      'role': 'NGO',
      'createdAt': '2024-01-01T00:00:00Z',
    },
  ];
  
  static final List<Map<String, dynamic>> _mockReports = [];
  static final List<Map<String, dynamic>> _mockResources = [];
  static final List<Map<String, dynamic>> _mockEmergencyStates = [];

  /// Initialize the service (safe initialization)
  static Future<void> init() async {
    print('🚀 ApiService.init() starting - MOCK MODE ONLY');
    
    // Reset state
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;

    // Try to load from SharedPreferences (but don't fail if it doesn't work)
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('accessToken');
      _refreshToken = prefs.getString('refreshToken');
      final userJson = prefs.getString('currentUser');
      if (userJson != null) {
        _currentUser = jsonDecode(userJson);
      }
      print('✅ Persistent data loaded');
    } catch (e) {
      print('⚠️ SharedPreferences unavailable: $e (continuing without persistence)');
    }
    
    // Always initialize mock data
    _initializeMockData();
    print('✅ ApiService initialized successfully - MOCK MODE');
  }

  /// Initialize sample data for demo
  static void _initializeMockData() {
    // Sample reports with ONLY Rawalpindi and Islamabad locations (within 100km radius)
    if (_mockReports.isEmpty) {
      _mockReports.addAll([
        {
          'id': '1',
          'title': 'Heavy Flooding in Rawalpindi Cantonment',
          'description': 'Monsoon rains causing severe flooding in residential areas of Rawalpindi Cantonment. Emergency evacuation in progress.',
          'type': 'FLOOD',
          'latitude': 33.6844,
          'longitude': 73.0479,
          'locationName': 'Rawalpindi Cantonment',
          'userId': '1',
          'userName': 'Demo Citizen',
          'status': 'ACTIVE',
          'severity': 'HIGH',
          'mediaUrls': [
            'https://images.unsplash.com/photo-1547036967-23d11aacaee0?w=400',
            'https://images.unsplash.com/photo-1574687479244-462ba4609566?w=400'
          ],
          'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        },
        {
          'id': '2',
          'title': '3.8 Magnitude Earthquake in Islamabad',
          'description': 'Minor earthquake detected in F-8 sector, Islamabad. No major structural damage reported but residents advised to stay alert.',
          'type': 'EARTHQUAKE',
          'latitude': 33.7294,
          'longitude': 73.0931,
          'locationName': 'F-8 Sector, Islamabad',
          'userId': '2',
          'userName': 'Demo NGO Organization', 
          'status': 'ACTIVE',
          'severity': 'MEDIUM',
          'mediaUrls': [
            'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=400'
          ],
          'createdAt': DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
        },
        {
          'id': '3',
          'title': 'Landslide Risk in Margalla Hills',
          'description': 'Heavy rainfall has increased landslide risk in Margalla Hills National Park area. Hiking trails temporarily closed.',
          'type': 'LANDSLIDE',
          'latitude': 33.7688,
          'longitude': 73.0372,
          'locationName': 'Margalla Hills, Islamabad',
          'userId': '1',
          'userName': 'Demo Citizen',
          'status': 'ACTIVE',
          'severity': 'HIGH',
          'mediaUrls': [
            'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400',
            'https://images.unsplash.com/photo-1611273426858-450d8e3c9fce?w=400'
          ],
          'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        },
        {
          'id': '4',
          'title': 'Industrial Fire in Taxila',
          'description': 'Large fire outbreak in industrial area of Taxila. Fire brigade and emergency services responding. Smoke affecting nearby residential areas.',
          'type': 'FIRE',
          'latitude': 33.7407,
          'longitude': 72.8397,
          'locationName': 'Industrial Area, Taxila',
          'userId': '2',
          'userName': 'Demo NGO Organization',
          'status': 'ACTIVE',
          'severity': 'CRITICAL',
          'mediaUrls': [
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
            'https://images.unsplash.com/photo-1574799956175-4ab7c3dc8dbc?w=400'
          ],
          'createdAt': DateTime.now().subtract(const Duration(minutes: 20)).toIso8601String(),
        },
        {
          'id': '5',
          'title': 'Flash Flood Warning in Attock',
          'description': 'Meteorological department issues flash flood warning for Attock district. River Indus water level rising rapidly.',
          'type': 'FLOOD',
          'latitude': 33.7669,
          'longitude': 72.3581,
          'locationName': 'Attock District',
          'userId': '1',
          'userName': 'Demo Citizen',
          'status': 'ACTIVE',
          'severity': 'HIGH',
          'mediaUrls': [
            'https://images.unsplash.com/photo-1547036967-23d11aacaee0?w=400'
          ],
          'createdAt': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
        },
      ]);
    }
    
    // Sample resources for Rawalpindi/Islamabad region
    if (_mockResources.isEmpty) {
      _mockResources.addAll([
        {
          'id': '1',
          'category': 'Medical',
          'itemName': 'Emergency First Aid Kits',
          'quantity': 200,
          'unit': 'kits',
          'description': 'Fully stocked first aid kits with bandages, antiseptics, and emergency medications for flood victims.',
          'userId': '2',
          'userName': 'Demo NGO Organization',
          'location': 'Rawalpindi Relief Center',
          'contactNumber': '+92-321-7654321',
          'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        },
        {
          'id': '2',
          'category': 'Food',
          'itemName': 'Ready-to-Eat Meal Packets',
          'quantity': 800,
          'unit': 'packets',
          'description': 'Nutritious meal packets with rice, lentils, and vegetables. Suitable for emergency distribution.',
          'userId': '2',
          'userName': 'Demo NGO Organization',
          'location': 'F-7 Distribution Center, Islamabad',
          'contactNumber': '+92-321-7654321',
          'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        },
        {
          'id': '3',
          'category': 'Shelter',
          'itemName': 'Emergency Tents',
          'quantity': 150,
          'unit': 'tents',
          'description': 'Waterproof emergency tents for displaced families. Each tent accommodates 4-6 people.',
          'userId': '2',
          'userName': 'Demo NGO Organization', 
          'location': 'Margalla Emergency Camp',
          'contactNumber': '+92-321-7654321',
          'createdAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
        },
        {
          'id': '4',
          'category': 'Water',
          'itemName': 'Clean Drinking Water Bottles',
          'quantity': 2000,
          'unit': 'bottles',
          'description': 'Purified drinking water bottles (1.5L each). Essential for areas with contaminated water supply.',
          'userId': '2',
          'userName': 'Demo NGO Organization',
          'location': 'Multiple Distribution Points',
          'contactNumber': '+92-321-7654321',
          'createdAt': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
        },
      ]);
    }
  }

  /// Safe token management
  static Future<void> saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', access);
      await prefs.setString('refreshToken', refresh);
    } catch (e) {
      print('⚠️ Token save failed: $e (continuing with in-memory only)');
    }
  }

  static Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      await prefs.remove('currentUser');
    } catch (e) {
      print('⚠️ Token clear failed: $e (cleared in-memory)');
    }
  }

  // Getters
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  static String? get accessToken => _accessToken;
  static Map<String, String> get headers => _headers;
  static bool get isLoggedIn => _accessToken != null;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static String? get currentRole => _currentUser?['role'];

  /// MOCK LOGIN - Guaranteed to work offline
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print('🔍 MOCK LOGIN: $email');
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Find matching user
    final users = _mockUsers.where((u) => 
        u['email']?.toLowerCase() == email.toLowerCase() && 
        u['password'] == password);
    
    if (users.isEmpty) {
      print('❌ LOGIN FAILED: Invalid credentials');
      throw ApiException('Invalid email or password');
    }
    
    final user = users.first;
    print('✅ LOGIN SUCCESS: ${user['name']} (${user['role']})');
    
    // Generate tokens
    _accessToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    _refreshToken = 'mock_refresh_${DateTime.now().millisecondsSinceEpoch}';
    _currentUser = Map<String, dynamic>.from(user)..remove('password');
    
    // Save persistently (but don't fail if it doesn't work)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', _accessToken!);
      await prefs.setString('refreshToken', _refreshToken!);
      await prefs.setString('currentUser', jsonEncode(_currentUser!));
      print('✅ Login state saved');
    } catch (e) {
      print('⚠️ Save failed: $e (login still works)');
    }
    
    return {
      'success': true,
      'message': 'Login successful',
      'data': {
        'accessToken': _accessToken,
        'refreshToken': _refreshToken,
        'user': _currentUser,
      },
    };
  }

  /// MOCK REGISTRATION
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? number,
    String role = 'CITIZEN',
  }) async {
    print('🔍 MOCK REGISTER: $email');
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Check if user exists
    final exists = _mockUsers.any((u) => u['email']?.toLowerCase() == email.toLowerCase());
    if (exists) {
      throw ApiException('User with this email already exists');
    }
    
    // Create user
    final newUser = {
      'id': (_mockUsers.length + 1).toString(),
      'name': name,
      'email': email,
      'password': password,
      'number': number,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    _mockUsers.add(newUser);
    print('✅ REGISTER SUCCESS: ${newUser['name']}');
    
    return {
      'success': true,
      'message': 'Registration successful',
      'data': {
        'user': Map<String, dynamic>.from(newUser)..remove('password'),
      },
    };
  }

  /// MOCK LOGOUT
  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await clearTokens();
    print('✅ LOGOUT SUCCESS');
  }

  /// MOCK PROFILE METHODS
  static Future<Map<String, dynamic>> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_currentUser == null) {
      throw ApiException('User not logged in');
    }
    
    return {
      'success': true,
      'data': _currentUser,
    };
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? number,
    String? password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (_currentUser == null) {
      throw ApiException('User not logged in');
    }
    
    // Update current user
    if (name != null) _currentUser!['name'] = name;
    if (email != null) _currentUser!['email'] = email;
    if (number != null) _currentUser!['number'] = number;
    
    // Update in mock users list
    final userIndex = _mockUsers.indexWhere((u) => u['id'] == _currentUser!['id']);
    if (userIndex != -1) {
      if (name != null) _mockUsers[userIndex]['name'] = name;
      if (email != null) _mockUsers[userIndex]['email'] = email;
      if (number != null) _mockUsers[userIndex]['number'] = number;
      if (password != null) _mockUsers[userIndex]['password'] = password;
    }
    
    // Save changes
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUser', jsonEncode(_currentUser));
    } catch (e) {
      print('⚠️ Profile save failed: $e');
    }
    
    return {
      'success': true,
      'message': 'Profile updated successfully',
      'data': _currentUser,
    };
  }

  /// MOCK REPORT METHODS
  static Future<Map<String, dynamic>> createReport({
    required String title,
    required String description,
    required String type,
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    
    if (_currentUser == null) {
      throw ApiException('User not logged in');
    }
    
    final newReport = {
      'id': (_mockReports.length + 1).toString(),
      'title': title,
      'description': description,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName ?? 'Unknown Location',
      'userId': _currentUser!['id'],
      'userName': _currentUser!['name'],
      'status': 'ACTIVE',
      'severity': _getRandomSeverity(),
      'mediaUrls': [], // Can be populated later
      'createdAt': DateTime.now().toIso8601String(),
      'upvotes': 0,
      'downvotes': 0,
      'comments': [],
      'userUpvoted': false,
      'userDownvoted': false,
    };
    
    _mockReports.insert(0, newReport);
    print('✅ Report created: $title');
    
    return {
      'success': true,
      'message': 'Report created successfully',
      'data': newReport,
    };
  }
  
  static String _getRandomSeverity() {
    final severities = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];
    return severities[Random().nextInt(severities.length)];
  }

  static Future<List<dynamic>> getAllReports() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockReports.map((r) {
      final report = Map<String, dynamic>.from(r);
      // Ensure vote fields exist
      report['upvotes'] ??= 0;
      report['downvotes'] ??= 0;
      report['comments'] ??= [];
      report['userUpvoted'] ??= false;
      report['userDownvoted'] ??= false;
      return report;
    }).toList();
  }

  /// Upvote a report
  static Future<Map<String, dynamic>> upvoteReport(String reportId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final reportIndex = _mockReports.indexWhere((r) => r['id'] == reportId);
    if (reportIndex == -1) {
      throw ApiException('Report not found');
    }

    final report = _mockReports[reportIndex];
    
    if (report['userUpvoted'] == true) {
      // Remove upvote
      report['upvotes'] = (report['upvotes'] ?? 1) - 1;
      report['userUpvoted'] = false;
    } else {
      // Add upvote
      report['upvotes'] = (report['upvotes'] ?? 0) + 1;
      report['userUpvoted'] = true;
      
      // Remove downvote if exists
      if (report['userDownvoted'] == true) {
        report['downvotes'] = (report['downvotes'] ?? 1) - 1;
      }
      report['userDownvoted'] = false;
    }

    print('✅ Report upvoted: $reportId (Upvotes: ${report['upvotes']})');
    
    return {
      'success': true,
      'data': report,
    };
  }

  /// Downvote a report
  static Future<Map<String, dynamic>> downvoteReport(String reportId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final reportIndex = _mockReports.indexWhere((r) => r['id'] == reportId);
    if (reportIndex == -1) {
      throw ApiException('Report not found');
    }

    final report = _mockReports[reportIndex];
    
    if (report['userDownvoted'] == true) {
      // Remove downvote
      report['downvotes'] = (report['downvotes'] ?? 1) - 1;
      report['userDownvoted'] = false;
    } else {
      // Add downvote
      report['downvotes'] = (report['downvotes'] ?? 0) + 1;
      report['userDownvoted'] = true;
      
      // Remove upvote if exists
      if (report['userUpvoted'] == true) {
        report['upvotes'] = (report['upvotes'] ?? 1) - 1;
      }
      report['userUpvoted'] = false;
    }

    print('✅ Report downvoted: $reportId (Downvotes: ${report['downvotes']})');
    
    return {
      'success': true,
      'data': report,
    };
  }

  static Future<List<dynamic>> getMyReports() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_currentUser == null) {
      throw ApiException('User not logged in');
    }
    
    final myReports = _mockReports
        .where((r) => r['userId'] == _currentUser!['id'])
        .toList();
    
    return myReports.map((r) => Map<String, dynamic>.from(r)).toList();
  }

  static Future<void> deleteReport(String reportId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final index = _mockReports.indexWhere((r) => r['id'] == reportId);
    if (index == -1) {
      throw ApiException('Report not found');
    }
    
    final report = _mockReports[index];
    if (report['userId'] != _currentUser!['id'] && _currentUser!['role'] != 'ADMIN') {
      throw ApiException('You can only delete your own reports');
    }
    
    _mockReports.removeAt(index);
    print('✅ Report deleted: $reportId');
  }

  /// MOCK RESOURCE METHODS
  static Future<Map<String, dynamic>> addResource({
    required String category,
    required String itemName,
    required int quantity,
    String? unit,
    String? description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (_currentUser == null) {
      throw ApiException('User not logged in');
    }
    
    final newResource = {
      'id': (_mockResources.length + 1).toString(),
      'category': category,
      'itemName': itemName,
      'quantity': quantity,
      'unit': unit ?? 'units',
      'description': description ?? '',
      'userId': _currentUser!['id'],
      'userName': _currentUser!['name'],
      'location': 'Distribution Center',
      'contactNumber': _currentUser!['number'] ?? '+92-300-0000000',
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    _mockResources.insert(0, newResource);
    print('✅ Resource added: $itemName');
    
    return {
      'success': true,
      'message': 'Resource added successfully',
      'data': newResource,
    };
  }

  static Future<List<dynamic>> getMyResources() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_currentUser == null) {
      throw ApiException('User not logged in');
    }
    
    final myResources = _mockResources
        .where((r) => r['userId'] == _currentUser!['id'])
        .toList();
    
    return myResources.map((r) => Map<String, dynamic>.from(r)).toList();
  }

  static Future<List<dynamic>> getAllResources() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockResources.map((r) => Map<String, dynamic>.from(r)).toList();
  }

  static Future<void> deleteResource(String resourceId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final index = _mockResources.indexWhere((r) => r['id'] == resourceId);
    if (index == -1) {
      throw ApiException('Resource not found');
    }
    
    final resource = _mockResources[index];
    if (resource['userId'] != _currentUser!['id']) {
      throw ApiException('You can only delete your own resources');
    }
    
    _mockResources.removeAt(index);
    print('✅ Resource deleted: $resourceId');
  }

  static Future<Map<String, dynamic>> updateResource({
    required String resourceId,
    String? category,
    String? itemName,
    int? quantity,
    String? unit,
    String? description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _mockResources.indexWhere((r) => r['id'] == resourceId);
    if (index == -1) {
      throw ApiException('Resource not found');
    }
    
    final resource = _mockResources[index];
    if (resource['userId'] != _currentUser!['id']) {
      throw ApiException('You can only update your own resources');
    }
    
    // Update resource
    if (category != null) _mockResources[index]['category'] = category;
    if (itemName != null) _mockResources[index]['itemName'] = itemName;
    if (quantity != null) _mockResources[index]['quantity'] = quantity;
    if (unit != null) _mockResources[index]['unit'] = unit;
    if (description != null) _mockResources[index]['description'] = description;
    
    print('✅ Resource updated: $resourceId');
    
    return {
      'success': true,
      'message': 'Resource updated successfully',
      'data': _mockResources[index],
    };
  }

  /// EMERGENCY STATE METHODS (NGO ONLY)
  static Future<Map<String, dynamic>> declareEmergencyState({
    required String area,
    required String type,
    required String severity,
    required String description,
    double? latitude,
    double? longitude,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (_currentUser == null || _currentUser!['role'] != 'NGO') {
      throw ApiException('Only NGO organizations can declare emergency states');
    }
    
    final newEmergencyState = {
      'id': (_mockEmergencyStates.length + 1).toString(),
      'area': area,
      'type': type,
      'severity': severity,
      'description': description,
      'latitude': latitude ?? 33.7294, // Default to Islamabad
      'longitude': longitude ?? 73.0931,
      'ngoId': _currentUser!['id'],
      'ngoName': _currentUser!['name'],
      'status': 'ACTIVE',
      'createdAt': DateTime.now().toIso8601String(),
      'expiresAt': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    };
    
    _mockEmergencyStates.insert(0, newEmergencyState);
    print('✅ Emergency state declared: $area - $type');
    
    return {
      'success': true,
      'message': 'Emergency state declared successfully',
      'data': newEmergencyState,
    };
  }

  static Future<List<dynamic>> getActiveEmergencyStates() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final now = DateTime.now();
    final activeStates = _mockEmergencyStates.where((state) {
      final expiresAt = DateTime.parse(state['expiresAt']);
      return expiresAt.isAfter(now) && state['status'] == 'ACTIVE';
    }).toList();
    
    return activeStates.map((s) => Map<String, dynamic>.from(s)).toList();
  }

  static Future<void> revokeEmergencyState(String stateId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final index = _mockEmergencyStates.indexWhere((s) => s['id'] == stateId);
    if (index == -1) {
      throw ApiException('Emergency state not found');
    }
    
    final emergencyState = _mockEmergencyStates[index];
    if (emergencyState['ngoId'] != _currentUser!['id']) {
      throw ApiException('You can only revoke your own emergency states');
    }
    
    _mockEmergencyStates[index]['status'] = 'REVOKED';
    print('✅ Emergency state revoked: $stateId');
  }

  /// INVENTORY ALLOCATION METHODS
  static Future<Map<String, dynamic>> allocateResourceToReport({
    required String reportId,
    required String resourceId,
    required int quantity,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (_currentUser == null || _currentUser!['role'] != 'NGO') {
      throw ApiException('Only NGO organizations can allocate resources');
    }
    
    final resourceIndex = _mockResources.indexWhere((r) => r['id'] == resourceId);
    if (resourceIndex == -1) {
      throw ApiException('Resource not found');
    }
    
    final resource = _mockResources[resourceIndex];
    if (resource['quantity'] < quantity) {
      throw ApiException('Insufficient quantity available. Available: ${resource['quantity']}, Requested: $quantity');
    }
    
    _mockResources[resourceIndex]['quantity'] = resource['quantity'] - quantity;
    
    final allocation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'reportId': reportId,
      'resourceId': resourceId,
      'resourceName': resource['itemName'],
      'quantity': quantity,
      'unit': resource['unit'],
      'notes': notes ?? '',
      'ngoId': _currentUser!['id'],
      'ngoName': _currentUser!['name'],
      'allocatedAt': DateTime.now().toIso8601String(),
      'status': 'ALLOCATED',
    };
    
    print('✅ Resource allocated: ${resource['itemName']} (qty: $quantity) to report: $reportId');
    
    return {
      'success': true,
      'message': 'Resource allocated successfully',
      'data': allocation,
    };
  }
}

/// Exception class for API errors
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}