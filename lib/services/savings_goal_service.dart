import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import 'api_service.dart';
import '../app_config.dart';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavingsGoalService {
  static const String _endpoint = '/savings-goals';
  
  // Get all savings goals for the current user
  static Future<List<SavingsGoal>> getAllSavingsGoals() async {
    try {
      print('Fetching savings goals from: ${ApiConfig.savingsGoals}');
      
      // Check if auth token exists before making the request
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        print('⚠️ No auth token found. User may not be logged in properly.');
        return [];
      }
      
      print('🔑 Using auth token: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
      final data = await ApiService.get(ApiConfig.savingsGoals);

      if (data != null && data['success'] == true && data['data'] != null) {
        final List<dynamic> savingsGoalsJson = data['data'];
        print('✅ Successfully fetched ${savingsGoalsJson.length} savings goals');
        return savingsGoalsJson.map((json) => _convertBackendSavingsGoal(json)).toList();
      } else {
        print('❌ API response format issue: ${data?.toString() ?? 'null response'}');
      }
      
      print('No savings goals found or invalid response format');
      return [];
    } catch (e) {
      print('❌ Error fetching savings goals: $e');
      return [];
    }
  }
  
  // Get a single savings goal by ID
  static Future<SavingsGoal?> getSavingsGoalById(String id) async {
    try {
      final data = await ApiService.get('${AppConfig.apiBaseUrl}$_endpoint/$id');
      
      if (data != null && data['success'] == true && data['data'] != null) {
        return _convertBackendSavingsGoal(data['data']);
      }
      
      return null;
    } catch (e) {
      print('Error fetching savings goal: $e');
      return null;
    }
  }
  
  // Create a new savings goal
  static Future<SavingsGoal?> createSavingsGoal(SavingsGoal savingsGoal) async {
    try {
      print('Creating savings goal at: ${ApiConfig.savingsGoals}');
      print('Savings goal data: ${_convertToBackendFormat(savingsGoal)}');
      
      // Check if auth token exists before making the request
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        print('⚠️ No auth token found. User may not be logged in properly.');
        return null;
      }
      
      print('🔑 Using auth token: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
      final data = await ApiService.post(
        ApiConfig.savingsGoals,
        _convertToBackendFormat(savingsGoal)
      );
      
      if (data != null && data['success'] == true && data['data'] != null) {
        print('✅ Savings goal created successfully with ID: ${data['data']['_id'] ?? data['data']['id']}');
        return _convertBackendSavingsGoal(data['data']);
      }
      
      print('❌ Failed to create savings goal: ${data?['message'] ?? 'Unknown error'}');
      return null;
    } catch (e) {
      print('❌ Error creating savings goal: $e');
      return null;
    }
  }
  
  // Update an existing savings goal
  static Future<SavingsGoal?> updateSavingsGoal(SavingsGoal savingsGoal) async {
    try {
      final data = await ApiService.put(
        '${AppConfig.apiBaseUrl}$_endpoint/${savingsGoal.id}',
        _convertToBackendFormat(savingsGoal)
      );
      
      if (data != null && data['success'] == true && data['data'] != null) {
        return _convertBackendSavingsGoal(data['data']);
      }
      
      return null;
    } catch (e) {
      print('Error updating savings goal: $e');
      return null;
    }
  }
  
  // Delete a savings goal
  static Future<bool> deleteSavingsGoal(String id) async {
    try {
      final data = await ApiService.delete('${AppConfig.apiBaseUrl}$_endpoint/$id');
      
      return data != null && data['success'] == true;
    } catch (e) {
      print('Error deleting savings goal: $e');
      return false;
    }
  }
  
  // Add money to a savings goal
  static Future<SavingsGoal?> addMoneyToSavingsGoal(String id, double amount) async {
    try {
      final data = await ApiService.post(
        '${AppConfig.apiBaseUrl}$_endpoint/$id/contribute',
        {'amount': amount}
      );
      
      if (data != null && data['success'] == true && data['data'] != null) {
        return _convertBackendSavingsGoal(data['data']);
      }
      
      return null;
    } catch (e) {
      print('Error adding money to savings goal: $e');
      return null;
    }
  }
  
  // Helper method to convert backend savings goal format to frontend SavingsGoal model
  static SavingsGoal _convertBackendSavingsGoal(Map<String, dynamic> json) {
    // Convert color value to Color object
    Color color;
    try {
      color = Color(json['color'] ?? 0xFF2196F3); // Default to blue if color is missing
    } catch (_) {
      color = Colors.blue; // Fallback color
    }
    
    return SavingsGoal(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      description: json['description'],
      targetAmount: json['targetAmount'].toDouble(),
      currentAmount: json['currentAmount']?.toDouble() ?? 0.0,
      createdDate: DateTime.parse(json['createdDate'] ?? json['createdAt']),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      color: color,
      iconName: json['iconName'],
    );
  }
  
  // Helper method to convert frontend SavingsGoal model to backend format
  static Map<String, dynamic> _convertToBackendFormat(SavingsGoal savingsGoal) {
    return {
      'title': savingsGoal.title,
      'description': savingsGoal.description,
      'targetAmount': savingsGoal.targetAmount,
      'currentAmount': savingsGoal.currentAmount,
      'createdDate': savingsGoal.createdDate.toIso8601String(),
      'targetDate': savingsGoal.targetDate?.toIso8601String(),
      'color': savingsGoal.color.value,
      'iconName': savingsGoal.iconName,
    };
  }
}
