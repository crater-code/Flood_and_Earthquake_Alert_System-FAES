// lib/services/backend_service.dart
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'api_service.dart';

/// Backend Service - Integrates with backend2 API
/// Handles reports and chatbot data from the real backend
class BackendService {
  // Configure your backend URL here
  static const String baseUrl = 'http://your-backend-url:3000/api/v1';
  
  // Get auth token from ApiService
  static String? get _authToken => ApiService.authToken;

  /// CREATE REPORT - Posts to backend2
  static Future<Map<String, dynamic>> createReport({
    required String title,
    required String description,
    required String type,
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/createReport'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'type': type,
          'latitude': latitude,
          'longitude': longitude,
          'locationName': locationName,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final backendReport = data['data'] ?? data;
        
        // Map to our format
        final report = _mapBackendReport(backendReport);
        
        // Sync with mock service
        ApiService.reports.add(report);
        
        return report;
      } else {
        throw Exception('Failed to create report: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating report: $e');
    }
  }

  /// GET ALL REPORTS - Fetch from backend2
  static Future<List<Map<String, dynamic>>> getAllReports() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/getAllReports'),
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reportsList = data['data'] as List;
        
        // Map backend response to our format
        List<Map<String, dynamic>> mappedReports = [];
        for (var report in reportsList) {
          mappedReports.add(_mapBackendReport(report));
        }
        
        // Sync with mock service
        ApiService.reports = mappedReports;
        
        return mappedReports;
      } else {
        throw Exception('Failed to fetch reports: ${response.body}');
      }
    } catch (e) {
      // Fallback to mock data if backend is unavailable
      debugPrint('Backend unavailable, using mock data: $e');
      return (await ApiService.getAllReports()).cast<Map<String, dynamic>>();
    }
  }

  /// Map backend response to frontend format
  static Map<String, dynamic> _mapBackendReport(Map<String, dynamic> backendReport) {
    return {
      'id': backendReport['id'] ?? '',
      'title': backendReport['title'] ?? 'Untitled',
      'description': backendReport['description'] ?? '',
      'type': backendReport['type'] ?? 'UNKNOWN',
      'latitude': backendReport['latitude'] ?? 0.0,
      'longitude': backendReport['longitude'] ?? 0.0,
      'locationName': backendReport['locationName'] ?? 'Unknown Location',
      'userName': backendReport['user']?['name'] ?? 'Anonymous',
      'upvotes': backendReport['upvotes'] ?? 0,
      'downvotes': backendReport['downvotes'] ?? 0,
      'comments': backendReport['comments'] ?? [],
      'status': backendReport['status'] ?? 'PENDING',
      'createdAt': backendReport['createdAt'] ?? DateTime.now().toIso8601String(),
      'userId': backendReport['userId'] ?? '',
    };
  }

  /// UPDATE REPORT
  static Future<Map<String, dynamic>> updateReport({
    required String reportId,
    required String title,
    required String description,
    required String type,
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/updateReport/$reportId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'type': type,
          'latitude': latitude,
          'longitude': longitude,
          'locationName': locationName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else {
        throw Exception('Failed to update report: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating report: $e');
    }
  }

  /// DELETE REPORT
  static Future<void> deleteReport(String reportId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/deleteReport/$reportId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete report: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting report: $e');
    }
  }

  /// GET MY REPORTS (USER'S REPORTS)
  static Future<List<Map<String, dynamic>>> getMyReports() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/getReports'),
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reportsList = data['data'] as List;
        return reportsList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch user reports: ${response.body}');
      }
    } catch (e) {
      // Fallback to mock data
      return ApiService.getReports();
    }
  }

  // ======= CHATBOT DATA =======
  
  /// Get emergency information for chatbot
  /// Can be extended to fetch from backend in the future
  static Future<Map<String, List<String>>> getEmergencyData() async {
    try {
      // For now, return mock data with structure ready for backend
      // In future, can call: GET $baseUrl/users/getEmergencyInfo
      return {
        'flood': [
          '1. Move to higher ground immediately',
          '2. Avoid walking/driving through floodwaters',
          '3. Turn off utilities if time permits',
          '4. Bring important documents',
          '5. Listen to emergency broadcasts',
          '6. Help neighbors if possible',
          '7. Emergency Contact: 1099',
        ],
        'earthquake': [
          'DURING: Drop, Cover, Hold On',
          '- Get under sturdy furniture',
          '- Protect your head and neck',
          '- Stay away from windows',
          'AFTER: Check for injuries',
          '- Leave building if safe',
          '- Avoid aftershocks',
          '- Listen for instructions',
        ],
        'fire': [
          '1. Alert others immediately',
          '2. Evacuate without using elevators',
          '3. Feel doors before opening',
          '4. Stay low to avoid smoke',
          '5. Move away from the building',
          '6. Don\'t return for belongings',
          '7. Call 16 from safe location',
        ],
      };
    } catch (e) {
      return {};
    }
  }

  /// Get health check - test if backend is available
  static Future<bool> isBackendAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
