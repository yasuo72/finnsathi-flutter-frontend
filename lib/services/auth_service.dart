import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../app_config.dart';
import 'auth_state_service.dart';
import 'api_service.dart';
import '../config/api_config.dart'; // Import ApiConfig

class AuthService {
  // Use AppConfig.useMockData instead of a separate flag
  // This ensures consistency with the rest of the app
  
  // Save user profile data to shared preferences for profile display
  static Future<void> saveUserProfileData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Create a profile data map with user information
      final Map<String, dynamic> profileData = {
        'id': userData['id'] ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
        'name': userData['name'] ?? 'User',
        'email': userData['email'] ?? '',
        'phone': userData['mobile'] ?? userData['phone'] ?? '',
        'avatarUrl': userData['avatarUrl'] ?? 'https://randomuser.me/api/portraits/lego/1.jpg',
        'dob': userData['dob'] ?? '',
        'membershipLevel': 'Basic',
        'levelProgress': 0.1,
        'nextLevel': 'Silver',
        'xp': 100,
        'level': 1,
        'points': 100,
        'rank': 100,
        'completedTransactions': 0,
      };
      
      // Save profile data
      await prefs.setString('user_profile', jsonEncode(profileData));
      print('User profile data saved successfully: $profileData');
    } catch (e) {
      print('Error saving user profile data: $e');
    }
  }
  
  static Future<http.Response> signup({
    required String name,
    required String dob,
    required String email,
    required String password,
    String? mobile,
  }) async {
    if (AppConfig.useMockData) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create a mock successful response with user data and token
      final userData = {
        'name': name,
        'email': email,
        'dob': dob,
      };
      
      final token = 'mock_auth_token_${DateTime.now().millisecondsSinceEpoch}';
      
      // Save authentication state
      await AuthStateService.saveAuthState(
        token: token,
        userData: userData,
      );
      
      // Also save the token for API requests
      await ApiService.saveAuthToken(token);
      
      return http.Response(
        jsonEncode({
          'success': true,
          'message': 'User registered successfully',
          'token': token,
          'user': userData
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    } else {
      // Use ApiService for real backend connection
      try {
        print('Attempting to register with Railway backend');
        print('Using URL: ${ApiConfig.register}');
        print('Sending registration data: name=$name, email=$email, dob=$dob');
        
        // Make a direct HTTP request instead of using ApiService to get more detailed error information
        final headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };
        
        final body = jsonEncode({
          'name': name,
          'dob': dob,
          'email': email,
          'password': password,
          if (mobile != null && mobile.isNotEmpty) 'mobile': mobile,
        });
        
        print('Request body: $body');
        
        final response = await http.post(
          Uri.parse(ApiConfig.register),
          headers: headers,
          body: body,
        );
        
        print('Registration status code: ${response.statusCode}');
        print('Registration response body: ${response.body}');
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success response
          final data = jsonDecode(response.body);
          
          // Save authentication state if registration successful
          if (data['token'] != null) {
            await ApiService.saveAuthToken(data['token']);
            
            // Create user data map
            final userData = data['user'] ?? {'name': name, 'email': email, 'dob': dob};
            
            // Save auth state
            await AuthStateService.saveAuthState(
              token: data['token'],
              userData: userData,
            );
            
            // Also save user profile data for profile display
            await saveUserProfileData(userData);
          }
          
          return response;
        } else {
          // Error response - return the actual response so we can see the error details
          print('Registration failed with status: ${response.statusCode}');
          return response;
        }
      } catch (e) {
        print('Signup error: ${e.toString()}');
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Network error: ${e.toString()}',
          }),
          500,
          headers: {'content-type': 'application/json'},
        );
      }
    }
  }

  static Future<http.Response> signin({
    String? email,
    String? mobile,
    required String password,
  }) async {
    if (AppConfig.useMockData) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create a mock successful response with user data
      final userData = {
        'name': 'Demo User',
        'email': email ?? 'demo@example.com',
      };
      
      final token = 'mock_auth_token_12345';
      
      // Save authentication state
      await AuthStateService.saveAuthState(
        token: token,
        userData: userData,
      );
      
      return http.Response(
        jsonEncode({
          'success': true,
          'message': 'User logged in successfully',
          'token': token,
          'user': userData
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    } else {
      // Use direct HTTP request for real backend connection
      try {
        print('Attempting to login with Railway backend');
        print('Using URL: ${ApiConfig.login}');
        print('Sending login data: email=$email, mobile=$mobile');
        
        // Make a direct HTTP request to get more detailed error information
        final headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };
        
        final body = jsonEncode({
          if (email != null && email.isNotEmpty) 'email': email,
          if (mobile != null && mobile.isNotEmpty) 'mobile': mobile,
          'password': password,
        });
        
        print('Request body: $body');
        
        final response = await http.post(
          Uri.parse(ApiConfig.login),
          headers: headers,
          body: body,
        );
        
        print('Login status code: ${response.statusCode}');
        print('Login response body: ${response.body}');
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success response
          final data = jsonDecode(response.body);
          
          // Save auth token if login successful
          if (data['token'] != null) {
            await ApiService.saveAuthToken(data['token']);
            
            // Create user data map
            final userData = data['user'] ?? {'email': email};
            
            // Save auth state
            await AuthStateService.saveAuthState(
              token: data['token'],
              userData: userData,
            );
            
            // Also save user profile data for profile display
            await saveUserProfileData(userData);
            
            print('Authentication state and profile data saved successfully');
          } else {
            print('No token received from backend');
          }
          
          return response;
        } else {
          // Error response - return the actual response so we can see the error details
          print('Login failed with status: ${response.statusCode}');
          return response;
        }
      } catch (e) {
        print('Login error: ${e.toString()}');
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Network error: ${e.toString()}',
          }),
          500,
          headers: {'content-type': 'application/json'},
        );
      }
    }
  }

  static Future<http.Response> verifyOtp({
    String? email,
    String? mobile,
    required String otp,
  }) async {
    if (AppConfig.useMockData) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, consider any 4-digit OTP as valid
      if (otp.length == 4 && int.tryParse(otp) != null) {
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'OTP verified successfully',
            'token': 'mock_verified_token_12345',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      } else {
        // Return error for invalid OTP format
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Invalid OTP. Please enter a 4-digit code.',
          }),
          400,
          headers: {'content-type': 'application/json'},
        );
      }
    } else {
      final url = Uri.parse('${AppConfig.backendBaseUrl}/api/verify');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'mobile': mobile,
          'otp': otp,
        }),
      );
      return response;
    }
  }

  static Future<http.Response> forgotPassword({
    String? email,
    String? mobile,
  }) async {
    if (AppConfig.useMockData) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      return http.Response(
        jsonEncode({
          'success': true,
          'message': 'OTP sent to your email/mobile for password reset',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    } else {
      final url = Uri.parse('${AppConfig.backendBaseUrl}/api/forgot-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'mobile': mobile,
        }),
      );
      return response;
    }
  }

  static Future<http.Response> resetPassword({
    String? email,
    String? mobile,
    required String otp,
    required String newPassword,
  }) async {
    if (AppConfig.useMockData) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, accept any 4-digit OTP for password reset
      if (otp.length == 4 && int.tryParse(otp) != null) {
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Password reset successfully',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      } else {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Invalid OTP. Please enter a 4-digit code.',
          }),
          400,
          headers: {'content-type': 'application/json'},
        );
      }
    } else {
      final url = Uri.parse('${AppConfig.backendBaseUrl}/api/reset-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'mobile': mobile,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );
      return response;
    }
  }

  static Future<http.Response> getProfile(String token) async {
    if (AppConfig.useMockData) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      return http.Response(
        jsonEncode({
          'success': true,
          'user': {
            'name': 'Demo User',
            'email': 'demo@example.com',
            'dob': '01-01-1990',
            'mobile': '+91 9876543210',
            'profilePicture': 'https://randomuser.me/api/portraits/lego/1.jpg',
          }
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    } else {
      final url = Uri.parse('${AppConfig.backendBaseUrl}/api/profile');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response;
    }
  }

  static Future<http.Response> updateProfile({
    required String token,
    String? name,
    String? dob,
  }) async {
    if (AppConfig.useMockData) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      return http.Response(
        jsonEncode({
          'success': true,
          'message': 'Profile updated successfully',
          'user': {
            'name': name ?? 'Demo User',
            'dob': dob ?? '01-01-1990',
            'email': 'demo@example.com',
            'mobile': '+91 9876543210',
          }
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    } else {
      final url = Uri.parse('${AppConfig.backendBaseUrl}/api/profile');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (dob != null) 'dob': dob,
        }),
      );
      return response;
    }
  }

  static Future<http.Response> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    if (AppConfig.useMockData) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // For demo purposes, accept any non-empty password change
      if (oldPassword.isNotEmpty && newPassword.isNotEmpty) {
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Password changed successfully',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      } else {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Password cannot be empty',
          }),
          400,
          headers: {'content-type': 'application/json'},
        );
      }
    } else {
      final url = Uri.parse('${AppConfig.backendBaseUrl}/api/change-password');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );
      return response;
    }
  }
}
