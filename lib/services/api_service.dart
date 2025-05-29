import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../app_config.dart';

class ApiService {
  // Base URL for API requests
  static String get baseUrl => AppConfig.apiBaseUrl;

  // HTTP headers
  static Future<Map<String, String>> _getHeaders({
    bool requiresAuth = true,
  }) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Get auth token from shared preferences
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('🔑 Getting auth token: ${token != null ? "${token.substring(0, token.length > 10 ? 10 : token.length)}..." : "null"}');
    return token;
  }

  // Save auth token to shared preferences
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear auth token (for logout)
  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Generic GET request
  static Future<dynamic> get(String url, {bool requiresAuth = true}) async {
    // Use mock data if enabled
    if (AppConfig.useMockData) {
      return _getMockResponse(url);
    }
    
    try {
      print('🌐 API GET Request to: $url');
      
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      print('🔑 Headers: $headers');
      
      final response = await http.get(Uri.parse(url), headers: headers);
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body.length > 500 ? "${response.body.substring(0, 500)}..." : response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ API Error: $e');
      // If real API call fails, fall back to mock data
      return _getMockResponse(url);
    }
  }

  // Generic POST request
  static Future<dynamic> post(
    String url,
    dynamic body, {
    bool requiresAuth = true,
  }) async {
    // Use mock data if enabled
    if (AppConfig.useMockData) {
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Simulate network delay
      return _getMockResponse(url, body);
    }

    try {
      print('🌐 API POST Request to: $url');
      print('📦 Request Body: ${jsonEncode(body)}');
      
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      print('🔑 Headers: $headers');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ API Error: $e');
      // If real API call fails, fall back to mock data
      return _getMockResponse(url, body);
    }
  }

  // Generic PUT request
  static Future<dynamic> put(
    String url,
    dynamic body, {
    bool requiresAuth = true,
  }) async {
    // Use mock data if enabled
    if (AppConfig.useMockData) {
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Simulate network delay
      return _getMockResponse(url, body);
    }

    try {
      print('🌐 API PUT Request to: $url');
      print('📦 Request Body: ${jsonEncode(body)}');
      
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      print('🔑 Headers: $headers');
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ API Error: $e');
      // If real API call fails, fall back to mock data
      return _getMockResponse(url, body);
    }
  }

  // Generic DELETE request
  static Future<dynamic> delete(String url, {bool requiresAuth = true}) async {
    // Use mock data if enabled
    if (AppConfig.useMockData) {
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Simulate network delay
      return _getMockResponse(url);
    }

    try {
      print('🌐 API DELETE Request to: $url');
      
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      print('🔑 Headers: $headers');
      
      final response = await http.delete(Uri.parse(url), headers: headers);
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ API Error: $e');
      // If real API call fails, fall back to mock data
      return _getMockResponse(url);
    }
  }

  // Handle HTTP response
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Success response
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    } else {
      // Error response
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error occurred';
        throw Exception('API Error (${response.statusCode}): $errorMessage');
      } catch (e) {
        throw Exception(
          'API Error (${response.statusCode}): ${response.reasonPhrase}',
        );
      }
    }
  }

  // Get mock response based on path
  static Map<String, dynamic> _getMockResponse(
    String url, [
    Map<String, dynamic>? body,
  ]) {
    // Extract the endpoint from the URL
    final Uri uri = Uri.parse(url);
    final String path = uri.path;

    // Handle auth endpoints
    if (path.contains('/auth/register') || path.contains('/auth/signup')) {
      final name = body?['name'] ?? 'Demo User';
      final email = body?['email'] ?? 'demo@example.com';
      final token = 'mock_auth_token_${DateTime.now().millisecondsSinceEpoch}';

      return {
        'success': true,
        'message': 'User registered successfully',
        'token': token,
        'user': {
          'name': name,
          'email': email,
          'dob': body?['dob'] ?? '2000-01-01',
        },
      };
    } else if (path.contains('/auth/login') || path.contains('/auth/signin')) {
      final email = body?['email'] ?? 'demo@example.com';
      final token = 'mock_auth_token_${DateTime.now().millisecondsSinceEpoch}';

      return {
        'success': true,
        'message': 'User logged in successfully',
        'token': token,
        'user': {'name': 'Demo User', 'email': email, 'dob': '2000-01-01'},
      };
    } else if (path.contains('/transactions')) {
      // For new users, return empty transaction data
      return {
        'success': true,
        'data': [],
      };
    } else if (path.contains('/budgets')) {
      final now = DateTime.now();
      return {
        'success': true,
        'data': [
          {
            'id': '1',
            'title': 'Monthly Food Budget',
            'category': 'food',
            'limit': 10000,
            'spent': 3500,
            'startDate': DateTime(now.year, now.month, 1).toIso8601String(),
            'endDate': DateTime(now.year, now.month + 1, 0).toIso8601String(),
            'transactionIds': [],
            'isActive': true,
          },
          {
            'id': '2',
            'title': 'Entertainment Budget',
            'category': 'entertainment',
            'limit': 5000,
            'spent': 2000,
            'startDate': DateTime(now.year, now.month, 1).toIso8601String(),
            'endDate': DateTime(now.year, now.month + 1, 0).toIso8601String(),
            'transactionIds': [],
            'isActive': true,
          },
        ],
      };
    } else if (path.contains('/savings-goals')) {
      final now = DateTime.now();
      return {
        'success': true,
        'data': [
          {
            'id': '1',
            'title': 'Vacation',
            'description': 'Summer vacation fund',
            'targetAmount': 50000,
            'currentAmount': 20000,
            'createdDate':
                now.subtract(const Duration(days: 30)).toIso8601String(),
            'targetDate': now.add(const Duration(days: 90)).toIso8601String(),
            'color': 0xFF2196F3, // Blue color
            'iconName': 'beach_access',
          },
          {
            'id': '2',
            'title': 'New Laptop',
            'description': 'For work and gaming',
            'targetAmount': 80000,
            'currentAmount': 30000,
            'createdDate':
                now.subtract(const Duration(days: 60)).toIso8601String(),
            'targetDate': now.add(const Duration(days: 180)).toIso8601String(),
            'color': 0xFF4CAF50, // Green color
            'iconName': 'laptop',
          },
        ],
      };
    } else if (path.contains('/wallet')) {
      return {
        'success': true,
        'data': {
          'balance': 25000,
          'cards': [
            {'id': '1', 'name': 'Main Card', 'balance': 15000},
            {'id': '2', 'name': 'Savings Card', 'balance': 10000},
          ],
          'cash': 5000,
        },
      };
    } else if (path.contains('/notifications')) {
      return {
        'success': true,
        'data': [
          {
            'id': '1',
            'title': 'Budget Alert',
            'message': 'You are close to your Food budget limit',
            'read': false,
            'date':
                DateTime.now()
                    .subtract(const Duration(hours: 5))
                    .toIso8601String(),
          },
          {
            'id': '2',
            'title': 'Savings Goal',
            'message': 'You are 40% towards your Vacation goal',
            'read': true,
            'date':
                DateTime.now()
                    .subtract(const Duration(days: 1))
                    .toIso8601String(),
          },
        ],
      };
    } else if (path.contains('/statistics')) {
      if (path.contains('/spending-by-category')) {
        return {
          'success': true,
          'data': [
            {'category': 'Food', 'amount': 5500},
            {'category': 'Entertainment', 'amount': 2000},
            {'category': 'Transportation', 'amount': 3000},
          ],
        };
      } else if (path.contains('/income-vs-expense')) {
        return {
          'success': true,
          'data': {'income': 50000, 'expense': 10500},
        };
      }
    } else if (path.contains('/predictions')) {
      return {
        'success': true,
        'data': {
          'nextMonth': 12000,
          'trend': 'increasing',
          'categories': [
            {'category': 'Food', 'amount': 6000},
            {'category': 'Entertainment', 'amount': 3000},
            {'category': 'Transportation', 'amount': 3000},
          ],
        },
      };
    } else if (path.contains('/chatbot')) {
      return {
        'success': true,
        'data': {
          'text': 'I\'m here to help with your finances!',
          'intent': 'greeting',
          'confidence': 0.9,
        },
      };
    }

    // Default response for any other endpoint
    return {'success': true, 'message': 'Mock data response', 'data': {}};
  }
}
